import Foundation
import Combine

final class BreakCountdownTimer: ObservableObject {
    @Published var remainingTime: TimeInterval
    private var timer: Timer?
    private let totalDuration: TimeInterval
    var onFinish: (() -> Void)?

    init(duration: TimeInterval) {
        self.remainingTime = duration
        self.totalDuration = duration
    }

    func start() {
        stop()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if self.remainingTime > 0 {
                self.remainingTime -= 1
            } else {
                self.stop()
                self.onFinish?()
            }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    deinit {
        stop()
    }
}
