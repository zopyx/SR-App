import SwiftUI
import Combine

/// ViewModel for the main player view.
///
/// PlayerViewModel manages the state and business logic for the player screen,
/// including station selection, playback control, and UI state management.
final class PlayerViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var selectedStation: Station = Station.defaultStation
    @Published var showStationSelector = false
    @Published var showAbout = false
    @Published var showSettings = false
    @Published var isHoveringLogo = false
    
    // Proxy bindings for AudioPlayer properties
    var volume: Double {
        get { audioPlayer.volume }
        set { audioPlayer.volume = newValue }
    }
    
    var isMuted: Bool {
        get { audioPlayer.isMuted }
        set { 
            if newValue != audioPlayer.isMuted {
                audioPlayer.toggleMute()
            }
        }
    }

    // MARK: - Dependencies

    let audioPlayer: AudioPlayer
    let nowPlayingService: NowPlayingService

    // MARK: - Computed Properties

    var isPlaying: Bool {
        if case .playing = audioPlayer.state { return true }
        return false
    }

    var isLoading: Bool {
        if case .loading = audioPlayer.state { return true }
        return false
    }

    var errorMessage: String? {
        if case .error(let msg) = audioPlayer.state { return msg }
        return nil
    }

    // MARK: - Initialization

    init(audioPlayer: AudioPlayer = .init(), nowPlayingService: NowPlayingService = .init()) {
        self.audioPlayer = audioPlayer
        self.nowPlayingService = nowPlayingService

        // Load last played station
        self.selectedStation = Station.lastPlayed
    }

    // MARK: - Public Methods

    /// Changes to a new station and starts playback.
    func changeStation(to station: Station) {
        selectedStation = station
        audioPlayer.loadStation(station, autoPlay: true)
        nowPlayingService.startMonitoring(station: station)
        Station.saveLastPlayed(station)
        Haptics.stationChange()

        // Track analytics
        Analytics.track(.stationChange(stationId: station.id, stationName: station.name))

        if #available(iOS 16.2, *) {
            restartLiveActivity(for: station)
        }
    }

    /// Opens the about dialog.
    func openAbout() {
        showAbout = true
        Analytics.track(.aboutViewOpen)
    }

    /// Opens the settings screen.
    func openSettings() {
        showSettings = true
        Analytics.track(.settingsOpen)
    }

    /// Dismisses error state.
    func dismissError() {
        audioPlayer.state = .idle
    }

    // MARK: - Live Activity

    @available(iOS 16.2, *)
    private func restartLiveActivity(for station: Station) {
        LiveActivityManager.shared.endActivity()
        let contentState = SRRadioAttributes.ContentState(
            isPlaying: true,
            title: "",
            artist: "",
            show: ""
        )
        LiveActivityManager.shared.startActivity(station: station, state: contentState)
        Analytics.track(.liveActivityStart(stationId: station.id))
    }

    @available(iOS 16.2, *)
    func updateLiveActivity() {
        let data = nowPlayingService.currentData

        switch audioPlayer.state {
        case .playing:
            let contentState = SRRadioAttributes.ContentState(
                isPlaying: true,
                title: data?.title ?? "",
                artist: data?.artist ?? "",
                show: data?.show ?? ""
            )
            if LiveActivityManager.shared.currentActivity == nil {
                LiveActivityManager.shared.startActivity(station: selectedStation, state: contentState)
            } else {
                LiveActivityManager.shared.updateActivity(state: contentState)
            }
        case .paused:
            let contentState = SRRadioAttributes.ContentState(
                isPlaying: false,
                title: data?.title ?? "",
                artist: data?.artist ?? "",
                show: data?.show ?? ""
            )
            LiveActivityManager.shared.updateActivity(state: contentState)
        case .idle:
            LiveActivityManager.shared.endActivity()
        case .loading, .error:
            break
        }
    }

    // MARK: - Lifecycle

    func onViewAppear() {
        audioPlayer.loadStation(selectedStation, autoPlay: true)
        nowPlayingService.startMonitoring(station: selectedStation)
        Analytics.recordAppLaunch()
    }

    func onPlaybackStateChange() {
        if #available(iOS 16.2, *) {
            updateLiveActivity()
        }
    }

    func onNowPlayingChange() {
        if #available(iOS 16.2, *) {
            updateLiveActivity()
        }
    }
}
