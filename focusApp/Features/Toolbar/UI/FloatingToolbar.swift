import SwiftUI

struct FloatingToolbar: View {
    var onStop: () -> Void
    @State private var elapsedSeconds: Int = 0
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack(spacing: 20) {
            // Stopwatch
            Text(formattedTime)
                .font(.title3)
                .monospacedDigit()
                .frame(width: 70, alignment: .leading)

            Spacer()

            // Stop Button
            Button(action: {
                onStop()
            }) {
                Image(systemName: "stop.circle.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.red)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(12)
        .frame(width: 220, height: 60)
        .onReceive(timer) { _ in
            elapsedSeconds += 1
        }
    }

    private var formattedTime: String {
        let minutes = elapsedSeconds / 60
        let seconds = elapsedSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

