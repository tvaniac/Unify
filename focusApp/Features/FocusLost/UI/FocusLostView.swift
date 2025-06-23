import SwiftUI

struct FocusLostView: View {
    var dismissAction: () -> Void
    @EnvironmentObject var coordinator: AppCoordinator
    @State private var showBreakOptionView = false

    var body: some View {
        ZStack {
            if showBreakOptionView {
                BreakOptionView()
                    .environmentObject(coordinator)
            } else {
                Color("yellow-lost").ignoresSafeArea()

                VStack(spacing: 30) {
                    Spacer()

                    Text("😴 Feeling drowsy?")
                        .font(.system(size: 55, weight: .medium))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    Text("All good — take a break if needed, or hit back to focus when you’re set.")
                        .font(.system(size: 28, weight: .regular))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    

                    FocusLostButtons(
                        onBreakTapped: {
                            print("Tombol Break diklik")
                            showBreakOptionView = true
                        },
                        onFocusTapped: {
                            print("Tombol Kembali fokus diklik")
                            dismissAction()
                        }
                    
                    )
                    .padding(.top, 70)
                    Spacer()
                }
                .padding(30)
            }
        }
        .onAppear {
            SoundPlayer.shared.playSystemSound(named: "Funk")
        }
    }
}

struct FocusLostView_Previews: PreviewProvider {
    static var previews: some View {
        FocusLostView(dismissAction: {})
            .frame(width: 1400, height: 800)
            .environmentObject(AppCoordinator())
    }
}


