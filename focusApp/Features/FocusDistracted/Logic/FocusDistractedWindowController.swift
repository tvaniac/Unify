import AppKit
import SwiftUI

class FocusDistractedWindowController {
    private var window: NSWindow?

    init(coordinator: AppCoordinator,
         onDismiss: @escaping () -> Void,
         onStopMode: @escaping () -> Void) {

        let hostingView = NSHostingView(rootView:
            FocusDistractedView(dismissAction: {
                DispatchQueue.main.async {
                    onDismiss()
                }
            }, stopModeAction: {
                DispatchQueue.main.async {
                    onStopMode()
                }
            })
            .environmentObject(coordinator)
        )

        let screenFrame = NSScreen.main?.frame ?? NSRect(x: 0, y: 0, width: 1440, height: 900)

        let newWindow = NSWindow(
            contentRect: screenFrame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        newWindow.contentView = hostingView
        newWindow.level = .screenSaver
        newWindow.isOpaque = true
        newWindow.backgroundColor = .clear
        newWindow.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        newWindow.ignoresMouseEvents = false
        newWindow.makeKeyAndOrderFront(nil)

        self.window = newWindow
    }

    func show() {
        window?.makeKeyAndOrderFront(nil)
    }

    func close() {
        if let window = window {
            window.orderOut(nil)
            self.window = nil
        }
    }
}

