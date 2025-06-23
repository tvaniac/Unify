import SwiftUI

struct FocusStopConfirmationView: View {
    var onStop: () -> Void
    var onCancel: () -> Void

    var body: some View {
        VStack(spacing: 15) {
            // Judul
            Text("😊 Done for now?")
//                .font(.headline)
                .font(.system(size: 35, weight: .medium))
                .multilineTextAlignment(.center)

            // Subjudul
            Text("Just a quick blip? Hit back to focus to keep things rolling.")
//                .font(.subheadline)
                .font(.system(size: 15, weight: .regular))
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            // Tombol
            HStack(spacing: 20) {
                // Tombol Stop 
                Button(action: onStop) {
                    Text("Stop")
                        .font(.body)
                        .foregroundColor(.black)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 20)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())

                // Tombol Back to Focus
                Button(action: onCancel) {
                    Text("Back to focus")
                        .font(.body)
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 20)
                        .background(Color("redButtonA"))
                        .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle()) 
            }
        }
        .padding()
        .frame(width: 600, height: 300)
        .background(Color.white)
        .cornerRadius(25)
        .shadow(radius: 10)
    }
}

#Preview {
    FocusStopConfirmationView(
        onStop: {
            print("❌ Stop tapped in preview")
        },
        onCancel: {
            print("✅ Back to focus tapped in preview")
        }
    )
    .frame(width: 1400, height: 800)
    .background(Color.gray.opacity(0.3))
}
