import SwiftUI

struct FocusLostViewWrapper: View {
    var onDismiss: () -> Void
    @EnvironmentObject var coordinator: AppCoordinator

    var body: some View {
        FocusLostView(dismissAction: {
            DispatchQueue.main.async {
                onDismiss()
            }
        })
        .environmentObject(coordinator)
    }
}



