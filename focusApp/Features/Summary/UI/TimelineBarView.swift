import SwiftUI

struct TimelineSegment: Identifiable {
    let id = UUID()
    let type: SegmentType
    let duration: TimeInterval // Use TimeInterval for consistency
}

enum SegmentType: String { // Make it RawRepresentable for easier mapping
    case fokus, drowsy, distraksi, noFace, onBreak

    var color: Color {
        switch self {
        case .fokus: return .green
        case .drowsy: return .yellow
        case .distraksi: return .blue
        case .noFace: return .red
        case .onBreak: return .purple
        }
    }

    var description: String {
        switch self {
        case .fokus: return "Fokus"
        case .drowsy: return "Drowsy"
        case .distraksi: return "Distraksi"
        case .noFace: return "No Face"
        case .onBreak: return "On Break"
        }
    }
}

struct TimelineBarView: View {
    let session: CompletedSession // Add this property

    private var segments: [TimelineSegment] {
        // Map DrowsinessState to SegmentType
        session.events.map { event in
            let segmentType: SegmentType
            switch event.state {
            case .awake:
                segmentType = .fokus
            case .eyesClosed, .yawning, .headDown:
                segmentType = .drowsy
            case .distracted:
                segmentType = .distraksi
            case .noFaceDetected, .error:
                segmentType = .noFace
            case .onBreak:
                segmentType = .onBreak
            }
            return TimelineSegment(type: segmentType, duration: event.duration)
        }
    }

    private var totalDuration: TimeInterval {
        session.duration
    }

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH.mm"
        return formatter
    }()

    private var startTime: String {
        TimelineBarView.timeFormatter.string(from: session.startTime)
    }

    private var endTime: String {
        TimelineBarView.timeFormatter.string(from: session.endTime)
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Background dengan top corner rounded
            RoundedTopCorners(radius: 30)
                .fill(Color.white)
                .shadow(radius: 3)

            VStack(alignment: .leading, spacing: 12) {
                Text("Timeline")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color("textApp"))
                    .padding(.leading, 16)
                    .padding(.top, 16)

                GeometryReader { geometry in
                    let fullWidth = geometry.size.width - 32 // 16 left + 16 right

                    VStack(spacing: 8) {
                        // TIMELINE BAR
                        HStack(spacing: 0) {
                            ForEach(segments) { segment in
                                let width = fullWidth * (segment.duration / totalDuration)
                                Rectangle()
                                    .fill(segment.type.color)
                                    .frame(width: max(0, width), height: 40) // Ensure width is not negative
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .padding(.horizontal, 16)

                        // LABEL WAKTU
                        HStack {
                            Text(startTime)
                            Spacer()
                            Text(endTime)
                        }
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 16)
                    }
                }
                .frame(height: 70) // cukup untuk bar dan waktu
            }
        }
        .frame(height: 170) // cukup untuk semua konten
    }
}
