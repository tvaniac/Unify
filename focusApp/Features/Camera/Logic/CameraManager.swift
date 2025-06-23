import Foundation
import AVFoundation
import Vision
import SwiftUI
import AppKit
import CoreML

/// MARK: - Drowsiness State Enum (Now Codable)
enum DrowsinessState: Equatable, Codable {
    
    // Make the nested enum Codable as well.
    enum DistractionType: String, Codable {
        case faceTurned = "Face Turned Away"
        case phoneDetected = "Phone Detected"
    }

    case awake
    case eyesClosed
    case yawning
    case headDown
    case distracted(DistractionType)
    case noFaceDetected
    case onBreak
    case error(String)

    // ... (static func ==, description, color, icon properties are unchanged) ...
    static func == (lhs: DrowsinessState, rhs: DrowsinessState) -> Bool {
        switch (lhs, rhs) {
        case (.awake, .awake): return true
        case (.eyesClosed, .eyesClosed): return true
        case (.yawning, .yawning): return true
        case (.headDown, .headDown): return true
        case (.distracted(let lhsType), .distracted(let rhsType)): return lhsType == rhsType
        case (.noFaceDetected, .noFaceDetected): return true
        case (.error(let lhsError), .error(let rhsError)): return lhsError == rhsError
        default: return false
        }
    }

    var description: String {
        switch self {
        case .awake: return "FOCUS"
        case .eyesClosed: return "DROWSY: Eyes Closed"
        case .yawning: return "DROWSY: Yawning Detected"
        case .headDown: return "DROWSY: Head Down"
        case .distracted(let type): return "DISTRACTED: \(type.rawValue)"
        case .noFaceDetected: return "Searching for face..."
        case .onBreak: return "ON BREAK"
        case .error(let message): return "Error: \(message)"
        }
    }

    var color: Color {
        switch self {
        case .awake: return .green
        case .eyesClosed, .yawning, .headDown: return .yellow
        case .distracted(let type):
            switch type {
            case .faceTurned: return .blue
            case .phoneDetected: return .cyan
            }
        case .onBreak: return .purple
        case .noFaceDetected, .error: return .red
        }
    }
    
    var icon: String {
        switch self {
        case .awake: return "face.smiling"
        case .eyesClosed: return "eye.slash.fill"
        case .yawning: return "mouth.fill"
        case .headDown: return "arrow.down.to.line.circle.fill"
        case .distracted(let type):
            switch type {
            case .faceTurned: return "arrow.turn.right.up"
            case .phoneDetected: return "iphone.gen2"
            }
        case .noFaceDetected: return "questionmark.circle"
        case .error: return "exclamationmark.triangle.fill"
        case .onBreak: return "cup.and.saucer.fill"
        }
    }
    
    // MARK: - Codable Implementation
    // By adding this logic inside the original enum, we fix all errors.
    
    enum CodingKeys: String, CodingKey {
        case caseType
        case associatedValue
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .awake:
            try container.encode("awake", forKey: .caseType)
        case .eyesClosed:
            try container.encode("eyesClosed", forKey: .caseType)
        case .yawning:
            try container.encode("yawning", forKey: .caseType)
        case .headDown:
            try container.encode("headDown", forKey: .caseType)
        case .distracted(let type):
            try container.encode("distracted", forKey: .caseType)
            try container.encode(type, forKey: .associatedValue)
        case .noFaceDetected:
            try container.encode("noFaceDetected", forKey: .caseType)
        case .error(let message):
            try container.encode("error", forKey: .caseType)
            try container.encode(message, forKey: .associatedValue)
        case .onBreak: // ⬅️ ADDED: Encoding logic for the new state.
            try container.encode("onBreak", forKey: .caseType)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let caseType = try container.decode(String.self, forKey: .caseType)

        switch caseType {
        case "awake":
            self = .awake
        case "eyesClosed":
            self = .eyesClosed
        case "yawning":
            self = .yawning
        case "headDown":
            self = .headDown
        case "distracted":
            // The compiler now knows exactly which DistractionType to use.
            let type = try container.decode(DistractionType.self, forKey: .associatedValue)
            self = .distracted(type)
        case "noFaceDetected":
            self = .noFaceDetected
        case "error":
            let message = try container.decode(String.self, forKey: .associatedValue)
            self = .error(message)
        case "onBreak": // ⬅️ ADDED: Decoding logic for the new state.
            self = .onBreak
        default:
            throw DecodingError.dataCorruptedError(forKey: .caseType, in: container, debugDescription: "Invalid DrowsinessState case type")
        }
    }
}

// NOTE: This struct is not actively used by the prediction logic anymore,
// but it is kept in case drawing capabilities are re-enabled later.
struct DetectedPhone: Identifiable {
    let id = UUID()
    let boundingBox: CGRect
    let confidence: Float
    let mask: CVPixelBuffer
}

class CameraManager: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {

    // Published properties
    @Published var previewLayer: AVCaptureVideoPreviewLayer?
    @Published var drowsinessState: DrowsinessState = .noFaceDetected
    @Published var faceObservations: [VNFaceObservation] = []
    
    // The simple, lightweight prediction result. This is what the app will use.
    @Published var isPhoneDetected: Bool = false
    
    // This is kept for potential drawing, but will not be populated to save CPU.
    @Published var detectedPhones: [DetectedPhone] = []

    // Capture Session, Model, etc.
    private var captureSession: AVCaptureSession?
    private let videoOutput = AVCaptureVideoDataOutput()
    private let sessionQueue = DispatchQueue(label: "com.drowsiness.sessionQueue")
    private let videoProcessingQueue = DispatchQueue(label: "com.drowsiness.videoProcessingQueue")
    private var yoloModel: VNCoreMLModel?
    private var statsManager: StatsManager?
    private var coordinator: AppCoordinator?
    
    // Throttling properties to process only one frame per second
    private var lastAnalysisTime = Date(timeIntervalSince1970: 0)
    private let analysisInterval: TimeInterval = 1.0
    
    // Drowsiness Detection Parameters
    private let eyeAspectRatioThreshold: CGFloat = 0.1
    private let baseMouthAspectRatioThreshold: CGFloat = 0.5
    private let marIncreasePerDegreeRoll: CGFloat = 0.01
    private let headDownThreshold: CGFloat = 0.08
    private let maxAllowableRollForHeadDown: Double = 10.0
    private let maxAllowableYawForHeadDown: Double = 15.0
    private let distractionYawThreshold: Double = 45.0
    private let distractionPitchThreshold: Double = 25.0
    private var lastEyeClosedTime: Date? = nil
    private let eyeClosureSecondsThreshold: TimeInterval = 1.0
    private var lastYawnStartTime: Date? = nil
    private let yawnSecondsThreshold: TimeInterval = 1.5
    private var lastHeadDownStartTime: Date? = nil
    private let headDownSecondsThreshold: TimeInterval = 3.0
    private var lastDistractionStartTime: Date? = nil
    private let distractionSecondsThreshold: TimeInterval = 5.0
    private var lastPhoneDetectedTime: Date? = nil
    private let phoneDetectionSecondsThreshold: TimeInterval = 2.0

    override init() {
        super.init()
        loadYoloModel()
    }

    private func loadYoloModel() {
        do {
            let model = try YOLO11(configuration: MLModelConfiguration()).model
            self.yoloModel = try VNCoreMLModel(for: model)
            print("YOLO segmentation model loaded successfully.")
        } catch {
            handleError("Failed to load YOLO model: \(error.localizedDescription)")
        }
    }

    func setStatsManager(_ manager: StatsManager) {
        self.statsManager = manager
    }
    
    func setCoordinator(_ coordinator: AppCoordinator) {
        self.coordinator = coordinator
    }

    
    func setupSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                self.configureSession()
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    if granted {
                        self.configureSession()
                    } else {
                        self.handleError("Camera access was denied.")
                    }
                }
            case .denied, .restricted:
                self.handleError("Camera access is denied or restricted.")
            @unknown default:
                self.handleError("Unknown camera authorization status.")
            }
        }
    }
    
    private func configureSession() {
        self.captureSession = AVCaptureSession()
        guard let session = self.captureSession else {
            handleError("Could not create capture session.")
            return
        }
        
        session.beginConfiguration()
        session.sessionPreset = .hd1280x720

        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .unspecified) else {
            handleError("No built-in camera found.")
            session.commitConfiguration()
            return
        }

        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            handleError("Could not create video device input.")
            session.commitConfiguration()
            return
        }
        
        if session.canAddInput(videoDeviceInput) {
            session.addInput(videoDeviceInput)
        }

        videoOutput.setSampleBufferDelegate(self, queue: videoProcessingQueue)
        videoOutput.alwaysDiscardsLateVideoFrames = true
        
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
        }

        if let connection = videoOutput.connection(with: .video) {
            if connection.isVideoOrientationSupported {
                connection.videoOrientation = .portrait
            }
        }

        session.commitConfiguration()

        DispatchQueue.main.async {
            self.previewLayer = AVCaptureVideoPreviewLayer(session: session)
        }
        
        session.startRunning()
    }

    func stopSession() {
        sessionQueue.async {
            self.captureSession?.stopRunning()
        }
    }
    
    private func handleError(_ message: String) {
        DispatchQueue.main.async {
            self.updateDrowsinessState(to: .error(message))
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // The "gate": If 1 second has not passed, ignore this frame completely.
        let currentTime = Date()
        guard currentTime.timeIntervalSince(lastAnalysisTime) > analysisInterval else {
            return
        }
        // A frame is allowed through. Update the time and process it.
        lastAnalysisTime = currentTime
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let faceLandmarksRequest = VNDetectFaceLandmarksRequest(completionHandler: self.handleFaceLandmarks)
        
        guard let yoloModel = self.yoloModel else {
            try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([faceLandmarksRequest])
            return
        }
        
        let phoneDetectionRequest = VNCoreMLRequest(model: yoloModel, completionHandler: self.handlePhoneDetection)
        phoneDetectionRequest.imageCropAndScaleOption = .scaleFill
        
        do {
            try VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([faceLandmarksRequest, phoneDetectionRequest])
        } catch {
            print("Error performing Vision requests: \(error.localizedDescription)")
        }
    }
    
    private func updateDrowsinessState(to newState: DrowsinessState) {
        DispatchQueue.main.async {
            if self.statsManager?.isOnBreak == true {
                // If the break is active, the ONLY state we want to display is .onBreak.
                // If the UI isn't already showing .onBreak, force it to.
                if self.drowsinessState != .onBreak {
                    self.drowsinessState = .onBreak
                    // We still want to log this initial change to the stats manager.
                    self.statsManager?.logStateChange(to: .onBreak, fromBreakToggle: true)
                }
                // IMPORTANT: Exit the function here to prevent any other state
                // (like .awake, .drowsy) from overwriting the .onBreak status on the UI.
                return
            }
            // Check if the state has actually changed to prevent redundant calls
            if self.drowsinessState == newState {
                return
            }
            
            print("📸 CameraManager: State changed from \(self.drowsinessState.description) to \(newState.description).")
            self.drowsinessState = newState
            self.statsManager?.logStateChange(to: newState)
            
            // --- MODIFIED LOGIC ---
            guard self.statsManager?.isRecording == true else {
                // If the session hasn't started, do not show any pop-ups.
                // Simply log the state and exit.
                return
            }
            
            switch newState {
            case .distracted:
                // Jika terganggu, mulai istirahat dan tampilkan overlay.
                self.coordinator?.showDistractedOverlay()
                
            case .eyesClosed, .yawning, .headDown:
                // Jika mengantuk, mulai istirahat dan tampilkan overlay.
                print("🚨 Popup triggered. Starting break.")// ⬅️ TAMBAHKAN INI
                self.coordinator?.showLostOverlay()
                
            default:
                // Tidak ada tindakan untuk status lain.
                break
            }
            // --- END OF MODIFIED LOGIC ---
        }
    }
    
    /// This function's only job is to find if a phone exists and update the simple `isPhoneDetected` boolean flag.
    /// It does not perform any expensive calculations.
    private func handlePhoneDetection(request: VNRequest, error: Error?) {
        if let error = error {
            print("YOLO Request Error: \(error.localizedDescription)")
            return
        }

        guard let results = request.results as? [VNCoreMLFeatureValueObservation], results.count >= 2 else {
            if isPhoneDetected { DispatchQueue.main.async { self.isPhoneDetected = false } }
            return
        }

        let detectionOutputName = "var_1365"
        guard let rawDetections = results.first(where: { $0.featureName == detectionOutputName })?.featureValue.multiArrayValue else {
            if isPhoneDetected { DispatchQueue.main.async { self.isPhoneDetected = false } }
            return
        }
        
        let numDetections = rawDetections.shape[2].intValue
        var phoneFoundInFrame = false

        for i in 0..<numDetections {
            let confidence = rawDetections[[0, 4, i] as [NSNumber]].floatValue
            if confidence > 0.6 {
                phoneFoundInFrame = true
                break // Exit early, we only need one match
            }
        }
        
        // Update the main prediction flag only if its state has changed
        if self.isPhoneDetected != phoneFoundInFrame {
            DispatchQueue.main.async {
                self.isPhoneDetected = phoneFoundInFrame
            }
        }
    }

    private func handleFaceLandmarks(request: VNRequest, error: Error?) {
        // This function now uses the simple, fast boolean flag for its logic
        let phoneIsDetected = self.isPhoneDetected

        guard let results = request.results as? [VNFaceObservation], !results.isEmpty else {
            // This block handles the case where NO FACE is found.
            if phoneIsDetected {
                // If the phone model sees a phone, we are distracted.
                updateDrowsinessState(to: .distracted(.phoneDetected))
            } else {
                // If the phone model sees no phone, and we see no face...
                // Only update to "No Face" if we weren't JUST in a phone distraction state.
                // This prevents the UI from flickering if the phone model briefly fails while covering the face.
                if self.drowsinessState != .distracted(.phoneDetected) {
                    updateDrowsinessState(to: .noFaceDetected)
                }
            }
            DispatchQueue.main.async { self.faceObservations = [] }
            self.resetAllTimers()
            return
        }

        guard let biggestFace = results.max(by: { $0.boundingBox.width * $0.boundingBox.height < $1.boundingBox.width * $1.boundingBox.height }) else {
            updateDrowsinessState(to: .noFaceDetected)
            DispatchQueue.main.async { self.faceObservations = [] }
            self.resetAllTimers()
            return
        }
        
        DispatchQueue.main.async { self.faceObservations = [biggestFace] }

        let currentTime = Date()
        
        if let landmarks = biggestFace.landmarks, areEyesClosed(landmarks: landmarks) {
            if lastEyeClosedTime == nil { lastEyeClosedTime = currentTime }
            if currentTime.timeIntervalSince(lastEyeClosedTime!) >= eyeClosureSecondsThreshold {
                updateDrowsinessState(to: .eyesClosed)
                self.resetTimers(except: .eyesClosed)
                return
            }
        } else { lastEyeClosedTime = nil }

        if let landmarks = biggestFace.landmarks, isYawning(observation: biggestFace, landmarks: landmarks) {
            if lastYawnStartTime == nil { lastYawnStartTime = currentTime }
            if currentTime.timeIntervalSince(lastYawnStartTime!) >= yawnSecondsThreshold {
                updateDrowsinessState(to: .yawning)
                self.resetTimers(except: .yawning)
                return
            }
        } else { lastYawnStartTime = nil }

        if let landmarks = biggestFace.landmarks, isHeadDown(observation: biggestFace, landmarks: landmarks) {
            if lastHeadDownStartTime == nil { lastHeadDownStartTime = currentTime }
            if currentTime.timeIntervalSince(lastHeadDownStartTime!) >= headDownSecondsThreshold {
                updateDrowsinessState(to: .headDown)
                self.resetTimers(except: .headDown)
                return
            }
        } else { lastHeadDownStartTime = nil }

        if phoneIsDetected {
            if lastPhoneDetectedTime == nil { lastPhoneDetectedTime = currentTime }
            if currentTime.timeIntervalSince(lastPhoneDetectedTime!) >= phoneDetectionSecondsThreshold {
                updateDrowsinessState(to: .distracted(.phoneDetected))
                self.resetTimers(except: .phoneDetected)
                return
            }
        } else { lastPhoneDetectedTime = nil }
        
        if isDistracted(observation: biggestFace) {
            if lastDistractionStartTime == nil { lastDistractionStartTime = currentTime }
            if currentTime.timeIntervalSince(lastDistractionStartTime!) >= distractionSecondsThreshold {
                updateDrowsinessState(to: .distracted(.faceTurned))
                self.resetTimers(except: .faceTurned)
                return
            }
        } else { lastDistractionStartTime = nil }

        updateDrowsinessState(to: .awake)
    }
    
    private enum StatePriority { case eyesClosed, yawning, headDown, phoneDetected, faceTurned }
    private func resetTimers(except confirmedState: StatePriority) {
        if confirmedState != .eyesClosed { lastEyeClosedTime = nil }
        if confirmedState != .yawning { lastYawnStartTime = nil }
        if confirmedState != .headDown { lastHeadDownStartTime = nil }
        if confirmedState != .phoneDetected { lastPhoneDetectedTime = nil }
        if confirmedState != .faceTurned { lastDistractionStartTime = nil }
    }
    private func resetAllTimers() {
        lastEyeClosedTime = nil
        lastYawnStartTime = nil
        lastHeadDownStartTime = nil
        lastDistractionStartTime = nil
        lastPhoneDetectedTime = nil
    }
    
    // MARK: - Calculation Methods
    private func areEyesClosed(landmarks: VNFaceLandmarks2D) -> Bool {
        guard let leftEye = landmarks.leftEye, let rightEye = landmarks.rightEye else { return false }
        let leftEAR = calculateEyeAspectRatio(eye: leftEye)
        let rightEAR = calculateEyeAspectRatio(eye: rightEye)
        return (leftEAR + rightEAR) / 2 < eyeAspectRatioThreshold
    }

    private func isYawning(observation: VNFaceObservation, landmarks: VNFaceLandmarks2D) -> Bool {
        var mar: CGFloat = 0.0
        if let innerLips = landmarks.innerLips {
            mar = calculateMouthAspectRatio(lips: innerLips)
        } else if let outerLips = landmarks.outerLips {
            mar = calculateMouthAspectRatio(lips: outerLips)
        } else {
            return false
        }
        var effectiveMarThreshold = baseMouthAspectRatioThreshold
        if let roll = observation.roll?.doubleValue {
            effectiveMarThreshold += marIncreasePerDegreeRoll * abs(roll * 180.0 / .pi)
        }
        if let pitch = observation.pitch?.doubleValue, let yaw = observation.yaw?.doubleValue {
            if abs(pitch * 180.0 / .pi) > distractionPitchThreshold || abs(yaw * 180.0 / .pi) > distractionYawThreshold {
                return false
            }
        }
        return mar > effectiveMarThreshold
    }

    private func isHeadDown(observation: VNFaceObservation, landmarks: VNFaceLandmarks2D) -> Bool {
        if let roll = observation.roll?.doubleValue, let yaw = observation.yaw?.doubleValue {
            if abs(roll * 180.0 / .pi) > maxAllowableRollForHeadDown || abs(yaw * 180.0 / .pi) > maxAllowableYawForHeadDown {
                return false
            }
        }
        guard let leftEye = landmarks.leftEye, let rightEye = landmarks.rightEye, let faceContour = landmarks.faceContour else { return false }
        let eyePoints = leftEye.normalizedPoints + rightEye.normalizedPoints
        guard !eyePoints.isEmpty else { return false }
        let averageEyeY = eyePoints.map(\.y).reduce(0, +) / CGFloat(eyePoints.count)
        guard let lowestChinY = faceContour.normalizedPoints.max(by: { $0.y < $1.y })?.y else { return false }
        return lowestChinY - averageEyeY > headDownThreshold
    }

    private func isDistracted(observation: VNFaceObservation) -> Bool {
        if let yaw = observation.yaw?.doubleValue {
            return abs(yaw * 180.0 / .pi) > distractionYawThreshold
        }
        return false
    }

    private func calculateEyeAspectRatio(eye: VNFaceLandmarkRegion2D) -> CGFloat {
        let points = eye.normalizedPoints
        guard points.count >= 6 else { return 0.0 }
        let verticalDist1 = distance(points[1], points[5])
        let verticalDist2 = distance(points[2], points[4])
        let horizontalDist = distance(points[0], points[3])
        if horizontalDist == 0 { return 0.0 }
        return (verticalDist1 + verticalDist2) / (2.0 * horizontalDist)
    }

    private func calculateMouthAspectRatio(lips: VNFaceLandmarkRegion2D) -> CGFloat {
        let points = lips.normalizedPoints
        guard points.count >= 10 else {
            let xs = points.map(\.x); let ys = points.map(\.y)
            guard let minX = xs.min(), let maxX = xs.max(), let minY = ys.min(), let maxY = ys.max() else { return 0.0 }
            let hDist = maxX - minX; let vDist = maxY - minY
            return hDist != 0 ? vDist / hDist : 0.0
        }
        let verticalDist1 = distance(points[2], points[8]); let verticalDist2 = distance(points[3], points[7])
        let horizontalDist = distance(points[0], points[5])
        if horizontalDist == 0 { return 0.0 }
        return (verticalDist1 + verticalDist2) / (2.0 * horizontalDist)
    }

    private func distance(_ p1: CGPoint, _ p2: CGPoint) -> CGFloat {
        return sqrt(pow(p2.x - p1.x, 2) + pow(p2.y - p1.y, 2))
    }
}

