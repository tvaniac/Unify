import Foundation
import SwiftUI

// MARK: - State Event Model
/// Defines a single period of a detected state. Moved here to be with other models.
struct StateEvent: Identifiable, Codable, Equatable {
    let id: UUID
    let state: DrowsinessState
    var startTime: Date
    var endTime: Date?

    var duration: TimeInterval {
        (endTime ?? Date()).timeIntervalSince(startTime)
    }
    
    // Add Equatable conformance for easier comparisons/testing
    static func == (lhs: StateEvent, rhs: StateEvent) -> Bool {
        lhs.id == rhs.id
    }
}


struct CompletedSession: Identifiable, Codable {
    let id: UUID
    let startTime: Date
    let endTime: Date
    let events: [StateEvent]

    var duration: TimeInterval {
        return endTime.timeIntervalSince(startTime)
    }

    /// Calculates the total duration spent in each StatCategory for the session.
    func calculateCategoryDurations() -> [StatCategory: TimeInterval] {
        var categoryTotals: [StatCategory: TimeInterval] = [:]
        
        // Initialize all categories to 0
        for category in StatCategory.allCases {
            categoryTotals[category] = 0
        }

        for event in events {
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
                // Decide if you want "noFace" in the summary or just ignore it
                category = .noFace
            case .onBreak:
                category = .onBreak
            }
            
            // Ensure event has an end time, if not, use session's end time (for the last event)
            let eventEndTime = event.endTime ?? self.endTime
            let duration = eventEndTime.timeIntervalSince(event.startTime)
            
            if duration > 0 {
                categoryTotals[category, default: 0] += duration
            }
        }
        return categoryTotals
    }
}
