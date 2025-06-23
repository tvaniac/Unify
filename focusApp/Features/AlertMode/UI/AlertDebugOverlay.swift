import SwiftUI

struct AlertDebugOverlay: View {
    var onTriggerLost: () -> Void
    var onTriggerDistracted: () -> Void

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                VStack(alignment: .trailing, spacing: 8) {
                    Button("🔴 Trigger Lost", action: onTriggerLost)
                    Button("🟠 Trigger Distracted", action: onTriggerDistracted)
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(12)
                .shadow(radius: 4)
                .padding()
            }
        }
    }
}

