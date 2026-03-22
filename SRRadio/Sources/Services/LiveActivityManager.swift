import ActivityKit
import Foundation

@available(iOS 16.2, *)
final class LiveActivityManager {
    static let shared = LiveActivityManager()

    private(set) var currentActivity: Activity<SRRadioAttributes>?

    func startActivity(station: Station, state: SRRadioAttributes.ContentState) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        endActivity()

        let attributes = SRRadioAttributes(
            stationName: station.name,
            stationShortName: station.shortName,
            stationLogoName: station.logoName,
            stationColorHex: station.colorHex
        )

        let content = ActivityContent(state: state, staleDate: Date().addingTimeInterval(3600))

        do {
            currentActivity = try Activity.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )
        } catch {
            print("[LiveActivity] Failed to start: \(error)")
        }
    }

    func updateActivity(state: SRRadioAttributes.ContentState) {
        guard let activity = currentActivity else { return }
        let content = ActivityContent(state: state, staleDate: Date().addingTimeInterval(3600))
        Task {
            await activity.update(content)
        }
    }

    func endActivity() {
        guard let activity = currentActivity else { return }
        let finalState = SRRadioAttributes.ContentState(
            isPlaying: false, title: "", artist: "", show: ""
        )
        let content = ActivityContent(state: finalState, staleDate: nil)
        Task {
            await activity.end(content, dismissalPolicy: .immediate)
        }
        currentActivity = nil
    }
}
