// CameraFeedView.swift

import SwiftUI
import AVFoundation
import Vision

struct CameraView: View {
    @EnvironmentObject private var cameraManager: CameraManager
    @State private var isFaceOutOfBounds = false
    
    // Define the normalized boundary (centered, 80% of width and height)
    private let guidelineBoundary = CGRect(x: 0.1, y: 0.1, width: 0.8, height: 0.8)

    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geometry in
                ZStack {
                    CameraFeedView(cameraManager: cameraManager)
                    LandmarksView(
                        faceObservations: cameraManager.faceObservations,
                        detectedPhones: cameraManager.detectedPhones,
                        viewSize: geometry.size
                    )
                    
                    // Add the new guideline box overlay
                    guidelineBoxOverlay(viewSize: geometry.size)
                    
                    // The existing status indicator overlay
                    statusOverlay
                    
                    // Show warning if the face is outside the guidelines
                    if isFaceOutOfBounds {
                        outOfBoundsWarningOverlay
                    }
                }
                // Add a modifier to check for face position changes
                .onChange(of: cameraManager.faceObservations) { _, newObservations in
                    // Use the largest detected face for the check
                    guard let face = newObservations.first else {
                        // If no face is detected, hide the warning
                        if isFaceOutOfBounds { isFaceOutOfBounds = false }
                        return
                    }
                    
                    // A face's boundingBox has its origin at the bottom-left,
                    // which matches our normalized guidelineBoundary definition.
                    // The warning is shown if the face box is NOT contained within the boundary.
                    let isContained = guidelineBoundary.contains(face.boundingBox)
                    if isFaceOutOfBounds != !isContained {
                        isFaceOutOfBounds = !isContained
                    }
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
    }

    @ViewBuilder
    private var statusOverlay: some View {
        VStack {
            Spacer()
            HStack {
                statusIndicator(for: cameraManager.drowsinessState)
                Spacer()
            }
            .padding()
        }
    }

    // MARK: - New UI Elements

    /// An overlay that displays a warning message when the user's face is not properly positioned.
    @ViewBuilder
    private var outOfBoundsWarningOverlay: some View {
        VStack(spacing: 12) {
            Text("⚠️")
                .font(.system(size: 50))
            Text("Please Position Your Face Inside The Guideline")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.vertical, 20)
        .background(Color.black.opacity(0.75))
        .cornerRadius(20)
        .shadow(radius: 10)
        .transition(.opacity.animation(.easeInOut(duration: 0.3))) // Smooth fade in/out
    }
    
    /// A visual guideline box drawn on the screen.
    @ViewBuilder
    private func guidelineBoxOverlay(viewSize: CGSize) -> some View {
        // Calculate the absolute pixel frame from the normalized boundary
        let rect = VNImageRectForNormalizedRect(guidelineBoundary, Int(viewSize.width), Int(viewSize.height))
        
        RoundedRectangle(cornerRadius: 15)
            .stroke(style: StrokeStyle(lineWidth: 3, dash: [15, 10]))
            .frame(width: rect.width, height: rect.height)
            .position(x: rect.midX, y: rect.midY)
            .foregroundColor(.white.opacity(0.4))
    }

    @ViewBuilder
    private func statusIndicator(for state: DrowsinessState) -> some View {
        HStack {
            Image(systemName: state.icon)
                .font(.largeTitle)
                .foregroundColor(state.color)
            
            Text(state.description)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .padding()
        .background(Color.black.opacity(0.6))
        .cornerRadius(15)
    }
}

struct CameraFeedView: NSViewRepresentable {
    @ObservedObject var cameraManager: CameraManager

    class Coordinator {
        var previewLayer: AVCaptureVideoPreviewLayer?
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.black.cgColor
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        if let newLayer = cameraManager.previewLayer, newLayer != context.coordinator.previewLayer {
            context.coordinator.previewLayer?.removeFromSuperlayer()
            newLayer.frame = nsView.bounds
            newLayer.videoGravity = .resizeAspectFill
            nsView.layer?.addSublayer(newLayer)
            context.coordinator.previewLayer = newLayer
        }
        context.coordinator.previewLayer?.frame = nsView.bounds
    }
}

// A new dedicated view to render the segmentation mask
struct MaskView: View {
    let id: UUID // Used to trigger view updates
    let mask: CVPixelBuffer
    let boundingBox: CGRect // Bounding box in view coordinates

    @State private var maskImage: CGImage?
    private static let context = CIContext()

    var body: some View {
        Group {
            if let cgImage = maskImage {
                Image(cgImage, scale: 1.0, label: Text("Mask"))
                    .resizable()
                    .frame(width: boundingBox.width, height: boundingBox.height)
                    .position(x: boundingBox.midX, y: boundingBox.midY)
            }
        }
        .onAppear(perform: processMask)
        .onChange(of: id) { _, _ in processMask() } // Re-process if the object changes
    }

    private func processMask() {
        // Create a CIImage from the mask pixel buffer
        let sourceMask = CIImage(cvPixelBuffer: mask)
        
        // 1. CORRECTED: Create an NSColor with an alpha component first.
        let translucentCyan = NSColor.cyan.withAlphaComponent(0.4)
        
        //    Then create a CIImage from a CIColor.
        let color = CIImage(color: CIColor(color: translucentCyan)!)
            .cropped(to: sourceMask.extent)

        // 2. CORRECTED: Initialize the filter by name and set values using keys.
        guard let filter = CIFilter(name: "CIBlendWithMask") else {
            return
        }
        filter.setValue(color, forKey: kCIInputImageKey)
        filter.setValue(sourceMask, forKey: kCIInputMaskImageKey)

        // Create a CGImage from the filter's output
        if let outputImage = filter.outputImage,
           let cgImage = MaskView.context.createCGImage(outputImage, from: sourceMask.extent) {
            maskImage = cgImage
        }
    }
}


struct LandmarksView: View {
    let faceObservations: [VNFaceObservation]
    let detectedPhones: [DetectedPhone] // Updated property
    let viewSize: CGSize

    var body: some View {
        ZStack {
            // --- Draw Face Landmarks ---
            ForEach(faceObservations, id: \.uuid) { observation in
                let boundingBox = convert(rect: observation.boundingBox)
                Rectangle()
                    .stroke(Color.yellow, lineWidth: 2)
                    .frame(width: boundingBox.width, height: boundingBox.height)
                    .position(x: boundingBox.midX, y: boundingBox.midY)

                if let landmarks = observation.landmarks {
                    let allPoints = landmarks.allPoints?.normalizedPoints ?? []
                    Path { path in
                        for point in allPoints {
                            let viewPoint = convert(point: point, in: boundingBox)
                            path.addEllipse(in: CGRect(x: viewPoint.x - 2, y: viewPoint.y - 2, width: 4, height: 4))
                        }
                    }
                    .fill(Color.red)
                }
            }
            
            // --- Draw Phone Detections (Mask, Bounding Box, and Label) ---
            ForEach(detectedPhones) { phone in
                let boundingBox = convert(rect: phone.boundingBox)
                
                // Draw the segmentation mask first (behind the box stroke)
                MaskView(id: phone.id, mask: phone.mask, boundingBox: boundingBox)
                
                // Draw the bounding box
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.cyan, lineWidth: 3)
                    .frame(width: boundingBox.width, height: boundingBox.height)
                    .position(x: boundingBox.midX, y: boundingBox.midY)
                
                // Draw the label and confidence
                Text("phone \(String(format: "%.0f%%", phone.confidence * 100))")
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(4)
                    .background(Color.cyan)
                    .foregroundColor(.black)
                    .cornerRadius(5)
                    .position(x: boundingBox.minX + 55, y: boundingBox.minY - 10)
            }
        }
    }

    // Convert landmark point from its bounding box to the view's coordinate space
    private func convert(point: CGPoint, in boundingBox: CGRect) -> CGPoint {
        let x = boundingBox.origin.x + point.x * boundingBox.size.width
        let y = boundingBox.origin.y + (1 - point.y) * boundingBox.size.height
        return CGPoint(x: x, y: y)
    }

    // Convert a normalized rectangle (origin at bottom-left) to the view's coordinate space (origin at top-left)
    private func convert(rect: CGRect) -> CGRect {
        let flippedRect = CGRect(x: rect.origin.x, y: 1 - rect.origin.y - rect.height, width: rect.width, height: rect.height)
        return VNImageRectForNormalizedRect(flippedRect, Int(viewSize.width), Int(viewSize.height))
    }
}

//#Preview{
//    CameraView()
//}
