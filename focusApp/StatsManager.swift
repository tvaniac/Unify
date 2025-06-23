// StatsManager.swift

import Foundation
import SwiftUI
import Combine

// NOTE: The `StateEvent` struct has been moved to Models/CodableModels.swift

enum StatCategory: String, CaseIterable {
    case focus = "Focus"
    case drowsy = "Drowsy"
    case distracted = "Distracted"
    case phoneDistracted = "Phone Use"
    case noFace = "No Face"
    case onBreak = "On Break"
    
    var color: Color {
        switch self {
        case .focus: return .green
        case .drowsy: return .yellow
        case .distracted: return .blue
        case .phoneDistracted: return .cyan
        case .noFace: return .clear
        case .onBreak: return .purple
        }
    }
}

enum TimePeriod: String, CaseIterable, Identifiable {
    case minute = "Per Minute"
    case hour = "Per Hour"
    case day = "Per Day"
    
    var id: String { self.rawValue }
    
    var durationInSeconds: TimeInterval {
        switch self {
        case .minute: return 60
        case .hour: return 3600
        case .day: return 86400
        }
    }
}


@MainActor
class StatsManager: ObservableObject {
    @Published var lastCompletedSession: CompletedSession?
    @Published private(set) var events: [StateEvent] = []
    @Published private(set) var isRecording = false
    @Published private(set) var isOnBreak = false
    
    private var sessionStartTime: Date?

    /// Starts a new statistics recording session.
    func startSession(initialState: DrowsinessState) {
        // Clear out any old data
        events.removeAll()
        sessionStartTime = Date()
        isRecording = true
        
        print("📊 StatsManager: Session STARTED. isRecording = \(isRecording)")
        
        // MODIFICATION 2: Immediately log the initial state as the first event.
        // This is the key to the entire fix.
        logStateChange(to: initialState)
    }

    /// Ends the current statistics recording session and saves it to disk.
    func endSession() {
        // ... this function remains the same, but we will add the "stretching" fix from before
        guard isRecording, let startTime = sessionStartTime else { return }

        if !events.isEmpty {
            // Set the end time for the very last event
            events[events.count - 1].endTime = Date()
            
            // Stretch the first event back to the session's true start time
            if events.indices.contains(0) {
                events[0].startTime = startTime
            }
        }

        isRecording = false
        print("📊 StatsManager: Session ENDED. Recorded \(events.count) events.")
        
        let completedSession = CompletedSession(
            id: UUID(),
            startTime: startTime,
            endTime: Date(),
            events: self.events
        )
        
        lastCompletedSession = completedSession
        HistoryStorage.shared.save(session: completedSession)
        
        events.removeAll()
        sessionStartTime = nil
    }
    
/// /// 🛑 Call this when a break starts.
    func startBreak() {
        guard isRecording, !isOnBreak else { return }
        print("📊 StatsManager: Starting break.")
        self.isOnBreak = true
        // This is the key call. It uses the `fromBreakToggle` to bypass the guard
        // inside logStateChange and forcefully logs the start of the break.
        self.logStateChange(to: .onBreak, fromBreakToggle: true)
    }

    /// ✅ Call this when a break ends.
    func endBreak() {
        guard isRecording, isOnBreak else { return }
        print("📊 StatsManager: Ending break.")
        self.isOnBreak = false
        // End the break event. The next state will be logged automatically
        // by the first frame the CameraManager processes after the break ends.
        if let lastEvent = events.last, lastEvent.state == .onBreak {
            events[events.count - 1].endTime = Date()
        }
    }


    // Modified logStateChange to handle the isOnBreak flag
    func logStateChange(to newState: DrowsinessState, fromBreakToggle: Bool = false) {
        guard isRecording else { return }
        
        // If a break is active, ignore any incoming states from CameraManager.
        // Only allow changes from startBreak/endBreak methods.
        if isOnBreak && !fromBreakToggle {
             print("📊 StatsManager: Ignoring state change '\(newState.description)' because a break is active.")
            return
        }
        
        if case .error = newState { return }
        
        print("➡️ StatsManager: Received log request for state '\(newState.description)'")

        if let lastEvent = events.last {
            // Do not log the same state sequentially
            if lastEvent.state == newState {
                return
            }
            // End the previous event
            events[events.count - 1].endTime = Date()
        }
        
        // Append the new event
        let newEvent = StateEvent(id: UUID(), state: newState, startTime: Date(), endTime: nil)
        events.append(newEvent)
        print("✅ StatsManager: Event appended. Total events now: \(events.count)")
    }
    
    func calculateStats(for period: TimePeriod) -> [StatCategory: TimeInterval] {
        let now = Date()
        let startTime = now.addingTimeInterval(-period.durationInSeconds)
        
        var categoryTotals: [StatCategory: TimeInterval] = StatCategory.allCases.reduce(into: [:]) { $0[$1] = 0 }
        
        let relevantEvents = events.filter { $0.startTime < now && ($0.endTime ?? now) > startTime }
        
        for event in relevantEvents {
            let category: StatCategory
            switch event.state {
            case .awake:
                category = .focus
            case .eyesClosed, .yawning, .headDown:
                category = .drowsy
            case .distracted(let type):
                switch type {
                case .faceTurned:
                    category = .distracted
                case .phoneDetected:
                    category = .phoneDistracted
                }
            case .noFaceDetected, .error:
                category = .noFace
            case .onBreak: // ⬅️ ADDED: Handle the new break state.
                category = .onBreak
            }
            
            let eventStartInWindow = max(event.startTime, startTime)
            let eventEndInWindow = min(event.endTime ?? now, now)
            let durationInWindow = eventEndInWindow.timeIntervalSince(eventStartInWindow)
            
            if durationInWindow > 0 {
                categoryTotals[category, default: 0] += durationInWindow
            }
        }
        
        return categoryTotals
    }
}
