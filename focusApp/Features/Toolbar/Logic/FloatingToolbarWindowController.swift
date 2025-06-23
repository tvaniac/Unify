import AppKit
import SwiftUI

class FloatingToolbarWindowController {
    private var window: NSPanel!

    init(onStop: @escaping () -> Void) {
        let hostingView = NSHostingView(rootView:
            FloatingToolbar(onStop: {
                print("🛑 STOP pressed from toolbar")
                onStop()
            })
        )
        window = NSPanel(
            contentRect: NSRect(x: 100, y: 100, width: 220, height: 60),
            styleMask: [.nonactivatingPanel, .borderless],
            backing: .buffered,
            defer: false
        )
        window.contentView = hostingView
        window.level = .mainMenu     // atau .screenSaver
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = true
        window.isMovableByWindowBackground = true
        window.collectionBehavior = [
            .canJoinAllSpaces,
            .fullScreenAuxiliary,
            .stationary,
            .ignoresCycle
        ]
    }

    func show() {
        window.orderFrontRegardless()
    }

    func close() {
        window.close()
    }
}
