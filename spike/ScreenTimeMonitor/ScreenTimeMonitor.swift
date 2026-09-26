import DeviceActivity
import Foundation

/// Runs in its own process whenever the system hits one of the thresholds
/// registered by `ScreenTimeProbe`. It can't send usage data anywhere except the
/// App Group, and it only learns "threshold X was crossed" — never raw numbers.
final class ScreenTimeMonitor: DeviceActivityMonitor {
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        SpikeLog.append("screentime", "interval started (\(activity.rawValue))")
    }

    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        SpikeLog.append("screentime", "interval ended (\(activity.rawValue))")
    }

    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name,
                                         activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        // Event names are "t<minutes>", e.g. "t90" = 1h30 of screen time today.
        SpikeLog.append("screentime", "threshold \(event.rawValue) reached")
        if let minutes = Int(event.rawValue.dropFirst()) {
            let key = SpikeLog.maxThresholdKey()
            let previous = SpikeLog.defaults?.integer(forKey: key) ?? 0
            SpikeLog.defaults?.set(max(previous, minutes), forKey: key)
        }
    }
}
