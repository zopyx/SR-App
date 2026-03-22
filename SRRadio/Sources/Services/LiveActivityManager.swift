import ActivityKit
import Foundation

/// Manages Live Activities for Dynamic Island and Lock Screen.
///
/// LiveActivityManager supports both singleton usage and dependency injection.
/// For production, use the shared singleton. For testing, inject instances.
@available(iOS 16.2, *)
final class LiveActivityManager: LiveActivityManagerProtocol {
    /// Shared singleton instance for production use.
    static let shared = LiveActivityManager()
    
    /// The current active Live Activity, if any.
    private(set) var currentActivity: Activity<SRRadioAttributes>?

    /// The current error state, if any.
    private(set) var currentError: RadioError?
    
    /// Default initializer for singleton or injected usage.
    init() {}

    func startActivity(station: Station, state: SRRadioAttributes.ContentState) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            currentError = .liveActivityNotAuthorized
            print("[LiveActivity] Activities are not enabled")
            return
        }

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
            currentError = nil
            print("[LiveActivity] Successfully started activity for \(station.name)")
        } catch {
            currentError = .liveActivityFailed(error.localizedDescription)
            print("[LiveActivity] Failed to start: \(error)")
        }
    }

    func updateActivity(state: SRRadioAttributes.ContentState) {
        guard let activity = currentActivity else {
            currentError = .liveActivityFailed("Keine aktive Activity")
            return
        }
        let content = ActivityContent(state: state, staleDate: Date().addingTimeInterval(3600))
        Task {
            do {
                try await activity.update(content)
                currentError = nil
            } catch {
                currentError = .liveActivityFailed(error.localizedDescription)
                print("[LiveActivity] Failed to update: \(error)")
            }
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
        currentError = nil
    }
}
