import SwiftUI

//struct FocusDistractedView: View {
//    @EnvironmentObject var coordinator: AppCoordinator
//    var dismissAction: () -> Void        // Untuk tombol "Kembali fokus"
//    var stopModeAction: () -> Void       // Untuk tombol "Stop Mode"
//
//    var body: some View {
//        ZStack {
//            Color("red-distract").ignoresSafeArea()
//
//            VStack(spacing: 20) {
//                topBar
//                Spacer()
//                messageText
//                Spacer()
//                FocusDistractedButton(title: "Back to focus", colorName: "redButtonA", action: dismissAction)
//                Spacer()
//            }
//            .padding(70)
//        }
//        .onAppear {
//            SoundPlayer.shared.playSystemSound(named: "Glass")
//        }
//    }
//
//    // Tombol "Stop Mode"
//    private var topBar: some View {
//        HStack {
//            Spacer()
//            Button(action: stopModeAction) {
//                Text("Stop Mode")
//                    .font(.subheadline)
//                    .foregroundColor(.white)
//                    .padding(.vertical, 10)
//                    .padding(.horizontal, 80)
//                    .background(Color("redButtonB").opacity(0.8))
//                    .cornerRadius(25)
//            }
//            .buttonStyle(PlainButtonStyle())
//            Spacer()
//        }
//        .padding(.top, 10)
//    }
//
//    private var messageText: some View {
//        VStack(spacing: 25) {
//            Text("👋 Heyy... your screen’s calling!")
//                .font(.system(size: 55, weight: .medium))
//                .foregroundColor(.white)
//                .multilineTextAlignment(.center)
//
//            Text("Your task is just chillin’—maybe it’s time we wrap it up?")
//                .font(.system(size: 28, weight: .regular))
//                .foregroundColor(.white.opacity(0.8))
//                .multilineTextAlignment(.center)
//                .padding(.horizontal, 40)
//        }
//    }
//}

struct FocusDistractedView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    var dismissAction: () -> Void
    var stopModeAction: () -> Void

    @State private var showConfirmation = false

    var body: some View {
        ZStack {
            Color("red-distract").ignoresSafeArea()

            VStack(spacing: 20) {
                topBar
                Spacer()
                messageText
                Spacer()
                FocusDistractedButton(title: "Back to focus", colorName: "redButtonA", action: dismissAction)
                Spacer()
            }
            .padding(70)

            // Overlay Confirmation Popup
            if showConfirmation {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()

                FocusStopConfirmationView(
                    onStop: {
                        stopModeAction()
                        showConfirmation = false
                    },
                    onCancel: {
                        showConfirmation = false
                    }
                )
                .transition(.scale)
                .zIndex(1)
            }
        }
        .onAppear {
            SoundPlayer.shared.playSystemSound(named: "Glass")
        }
    }

    private var topBar: some View {
        HStack {
            Spacer()
            Button(action: {
                showConfirmation = true
            }) {
                Text("Stop Mode")
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 80)
                    .background(Color("redButtonB").opacity(0.8))
                    .cornerRadius(25)
            }
            .buttonStyle(PlainButtonStyle())
            Spacer()
        }
        .padding(.top, 10)
    }

    private var messageText: some View {
        VStack(spacing: 25) {
            Text("👋 Heyy... your screen’s calling!")
                .font(.system(size: 55, weight: .medium))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            Text("Your task is just chillin’—maybe it’s time we wrap it up?")
                .font(.system(size: 28, weight: .regular))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}

struct FocusDistractedView_Previews: PreviewProvider {
    static var previews: some View {
        FocusDistractedView(dismissAction: {}, stopModeAction: {})
            .environmentObject(AppCoordinator())
            .frame(width: 1400, height: 800)
    }
}

