import AppKit

class SoundPlayer {
    static let shared = SoundPlayer()

    private init() {}

    /// Memainkan suara sistem bawaan macOS.
    /// - Parameter soundName: Nama suara sistem. Default: "Funk"
    func playSystemSound(named soundName: String = "Funk") {
        if let sound = NSSound(named: NSSound.Name(soundName)) {
            sound.play()
            print("✅ Playing system sound: \(soundName)")
        } else {
            print("⚠️ System sound '\(soundName)' not found.")
        }
    }
}
