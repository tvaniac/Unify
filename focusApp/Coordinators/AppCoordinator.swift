import SwiftUI

@MainActor
class AppCoordinator: ObservableObject {
    @Published var currentView: AppPage = .home
    
    public var statsManager: StatsManager = StatsManager()

    var floatingToolbar: FloatingToolbarWindowController?
    var focusDistractedWindow: FocusDistractedWindowController?
    var focusLostWindow: FocusLostWindowController?

    enum AppPage {
        case home, alertMode, quietMode, summary, history
    }

    // MARK: - Start / End Mode
    func startMode(type: AppPage) {
        currentView = type
        showToolbar()
        minimizeApp()
    }

    func endMode() {
        print("🧭 End Mode triggered")
        currentView = .summary
        floatingToolbar?.close()
        floatingToolbar = nil

        closeDistractedOverlay()
        closeLostOverlay()

        restoreApp()
    }

    // MARK: - Floating Toolbar
    private func showToolbar() {
        floatingToolbar = FloatingToolbarWindowController {
            self.endMode()
        }
        floatingToolbar?.show()
    }

    private func minimizeApp() {
        NSApp.mainWindow?.miniaturize(nil)
    }

    private func restoreApp() {
        if let window = NSApp.windows.first(where: { $0.isMiniaturized }) {
            window.deminiaturize(nil) // buka kembali dari minimize
        }

        NSApp.activate(ignoringOtherApps: true) // fokus ke app
    }

    // MARK: - Distracted Overlay

    // Fungsi baru untuk hanya menutup overlay fokus terganggu tanpa stop mode
    func dismissDistractedOverlay() {
        print("⚪️ Dismiss Distracted Overlay")
        closeDistractedOverlay()
    }

    func showDistractedOverlay() {
        print("🟠 Show Distracted Overlay")
        if focusDistractedWindow == nil {
            focusDistractedWindow = FocusDistractedWindowController(
                coordinator: self,
                onDismiss: {
                    self.dismissDistractedOverlay()   // hanya tutup overlay (kembali fokus)
                },
                onStopMode: {
                    self.endMode()                    // stop mode, navigasi summary
                }
            )
            focusDistractedWindow?.show()
        }
    }

    func closeDistractedOverlay() {
        print("⚪️ Close Distracted Overlay")
        focusDistractedWindow?.close()
        focusDistractedWindow = nil
    }

    // MARK: - Lost Overlay (no Stop button)
    func showLostOverlay() {
        print("🔴 Show Lost Overlay")
        if focusLostWindow == nil {
            focusLostWindow = FocusLostWindowController(coordinator: self, onDismiss: {
                self.closeLostOverlay()
            }, onBreak: {
                self.endMode()
            })
            focusLostWindow?.show()
        }
    }

    func closeLostOverlay() {
        print("⚪️ Close Lost Overlay")
        focusLostWindow?.close()
        focusLostWindow = nil
    }
}
