import Foundation

class HistoryStorage {
    static let shared = HistoryStorage()
    private let fileManager = FileManager.default
    private var historyDirectoryURL: URL

    private init() {
        // Create a dedicated directory for history files to keep things organized.
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        historyDirectoryURL = documentsDirectory.appendingPathComponent("SessionHistory")

        if !fileManager.fileExists(atPath: historyDirectoryURL.path) {
            try? fileManager.createDirectory(at: historyDirectoryURL, withIntermediateDirectories: true, attributes: nil)
        }
    }

    /// Saves a single completed session to a JSON file.
    func save(session: CompletedSession) {
        let fileName = "\(session.id.uuidString).json"
        let fileURL = historyDirectoryURL.appendingPathComponent(fileName)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601 // Use a standard date format

        do {
            let data = try encoder.encode(session)
            try data.write(to: fileURL)
            print("💾 Session saved successfully at \(fileURL.path)")
        } catch {
            print("❌ Error saving session \(session.id): \(error.localizedDescription)")
        }
    }

    /// Loads all completed sessions from the history directory.
    func loadAllSessions() -> [CompletedSession] {
        var sessions: [CompletedSession] = []
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: historyDirectoryURL, includingPropertiesForKeys: nil)
            for url in fileURLs where url.pathExtension == "json" {
                do {
                    let data = try Data(contentsOf: url)
                    let session = try decoder.decode(CompletedSession.self, from: data)
                    sessions.append(session)
                } catch {
                    print("❌ Error decoding session from file \(url.lastPathComponent): \(error.localizedDescription)")
                }
            }
        } catch {
            print("❌ Error loading session files: \(error.localizedDescription)")
        }

        // Return sessions sorted from newest to oldest.
        return sessions.sorted { $0.startTime > $1.startTime }
    }
}
