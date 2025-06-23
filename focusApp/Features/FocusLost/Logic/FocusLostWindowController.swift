import SwiftUI
import AppKit

class FocusLostWindowController {
    var window: NSWindow?
    var coordinator: AppCoordinator
    var onDismiss: () -> Void
    var onBreak: () -> Void // This seems to be the action for "break"

    init(coordinator: AppCoordinator, onDismiss: @escaping () -> Void, onBreak: @escaping () -> Void) {
        self.coordinator = coordinator
        self.onDismiss = onDismiss
        self.onBreak = onBreak
    }

    func show() {
        DispatchQueue.main.async {
            let contentView = NSHostingView(rootView:
                FocusLostViewWrapper(onDismiss: {
                    self.onDismiss()
                })
                .environmentObject(self.coordinator)
                // Now directly inject, as it's no longer optional
                .environmentObject(self.coordinator.statsManager) // Inject StatsManager into the environment
            )

            let screenSize = NSScreen.main?.frame.size ?? CGSize(width: 800, height: 600)
            self.window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height),
                styleMask: [.borderless],
                backing: .buffered,
                defer: false
            )
            self.window?.isReleasedWhenClosed = false
            self.window?.level = .screenSaver
            self.window?.collectionBehavior = [.fullScreenAuxiliary, .canJoinAllSpaces]
            self.window?.ignoresMouseEvents = false
            self.window?.isOpaque = true
            self.window?.backgroundColor = NSColor(named: "yellow-lost") ?? .yellow
            self.window?.contentView = contentView
            self.window?.makeKeyAndOrderFront(nil)
        }
    }

    func close() {
        DispatchQueue.main.async {
            self.window?.orderOut(nil)
            self.window = nil
        }
    }
}
