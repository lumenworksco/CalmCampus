import Foundation

/// Append-only event log in the shared App Group container.
///
/// The app and the Screen Time extension both write here, so the app can show
/// *when* background events actually happened (observer wake-ups, threshold
/// crossings, background refreshes) — which is most of what the spike measures.
enum SpikeLog {
    static let appGroup = "group.co.lumenworks.calmcampus.spike"

    private static var fileURL: URL? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroup)?
            .appendingPathComponent("spike-log.txt")
    }

    static func append(_ tag: String, _ message: String) {
        guard let url = fileURL else { return }
        let stamp = Date.now.formatted(.dateTime.month(.twoDigits).day(.twoDigits)
            .hour(.twoDigits(amPM: .omitted)).minute(.twoDigits).second(.twoDigits))
        let data = Data("\(stamp) [\(tag)] \(message)\n".utf8)
        if let handle = try? FileHandle(forWritingTo: url) {
            defer { try? handle.close() }
            _ = try? handle.seekToEnd()
            try? handle.write(contentsOf: data)
        } else {
            try? data.write(to: url)
        }
    }

    /// All log lines, newest first, optionally only those with [tag].
    static func entries(tag: String? = nil) -> [String] {
        guard let url = fileURL,
              let text = try? String(contentsOf: url, encoding: .utf8) else { return [] }
        let lines = text.split(separator: "\n").map(String.init).reversed()
        guard let tag else { return Array(lines) }
        return lines.filter { $0.contains("[\(tag)]") }
    }

    static func clear() {
        if let url = fileURL { try? FileManager.default.removeItem(at: url) }
    }

    /// Shared defaults, for small values the extension and app both need.
    static var defaults: UserDefaults? { UserDefaults(suiteName: appGroup) }

    /// Key for the highest screen-time threshold (in minutes) crossed on a day.
    static func maxThresholdKey(for date: Date = .now) -> String {
        let c = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return "maxThresholdMinutes-\(c.year!)-\(c.month!)-\(c.day!)"
    }
}
