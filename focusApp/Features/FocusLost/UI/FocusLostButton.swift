import SwiftUI

struct FocusLostButtons: View {
    // 1. Declare StatsManager as an EnvironmentObject
    @EnvironmentObject var statsManager: StatsManager

    var onBreakTapped: () -> Void
    var onFocusTapped: () -> Void

    var body: some View {
        HStack(spacing: 20) {
            Button(action: {
                // 2. Call the passed-in action
                onBreakTapped()
                // 3. Call the statsManager method
//                statsManager.startBreak()
            }) {
                Text("Break")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.vertical, 20)
                    .padding(.horizontal, 70)
                    .background(Color("brownButtonB"))
                    .cornerRadius(45)
                    .shadow(radius: 5)
            }
            .buttonStyle(PlainButtonStyle())

            Button(action: {
                // 4. Call the passed-in action
                onFocusTapped()
            }) {
                Text("Back to focus")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.vertical, 20)
                    .padding(.horizontal, 70)
                    .background(Color("brownButtonA"))
                    .cornerRadius(45)
                    .shadow(radius: 5)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}
