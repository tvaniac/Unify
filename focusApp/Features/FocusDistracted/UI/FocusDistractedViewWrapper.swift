import SwiftUI

struct FocusDistractedViewWrapper: View {
    var dismissAction: () -> Void
    var stopModeAction: () -> Void
    @EnvironmentObject var coordinator: AppCoordinator

    var body: some View {
        FocusDistractedView(
            dismissAction: dismissAction,
            stopModeAction: stopModeAction
        )
        .environmentObject(coordinator)
    }
}

