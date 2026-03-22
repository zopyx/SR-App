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

    /// User-friendly error message for display in the UI.
    @Published var userErrorMessage: String?

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

    private let _audioPlayer: any AudioPlayerProtocol
    private let _nowPlayingService: any NowPlayingServiceProtocol
    private let _liveActivityManager: Any?
    
    /// The audio player service.
    var audioPlayer: any AudioPlayerProtocol { _audioPlayer }
    
    /// The now playing service.
    var nowPlayingService: any NowPlayingServiceProtocol { _nowPlayingService }
    
    /// The Live Activity manager (iOS 16.2+).
    var liveActivityManager: Any? {
        guard #available(iOS 16.2, *) else { return nil }
        return _liveActivityManager
    }
    
    /// Returns the Live Activity manager if available.
    @available(iOS 16.2, *)
    func getLiveActivityManager() -> (any LiveActivityManagerProtocol)? {
        return liveActivityManager as? (any LiveActivityManagerProtocol)
    }

    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()

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

    /// The current RadioError, if any.
    var currentRadioError: RadioError? {
        audioPlayer.currentError
    }

    // MARK: - Initialization

    /// Initializes the PlayerViewModel with dependencies.
    ///
    /// - Parameters:
    ///   - audioPlayer: The audio player service (default: shared instance via Container).
    ///   - nowPlayingService: The now-playing service (default: shared instance via Container).
    ///   - liveActivityManager: The Live Activity manager (default: shared instance, iOS 16.2+).
    init(
        audioPlayer: (any AudioPlayerProtocol)? = nil,
        nowPlayingService: (any NowPlayingServiceProtocol)? = nil,
        liveActivityManager: Any? = nil
    ) {
        // Use injected dependencies or resolve from container
        self._audioPlayer = audioPlayer ?? Container.shared.resolveAudioPlayer()
        self._nowPlayingService = nowPlayingService ?? Container.shared.resolveNowPlayingService()
        self._liveActivityManager = liveActivityManager ?? {
            if #available(iOS 16.2, *) {
                return Container.shared.resolveLiveActivityManager() as Any
            }
            return nil
        }()

        // Load last played station
        self.selectedStation = Station.lastPlayed

        // Setup error observation
        setupErrorObservation()
    }
    
    // MARK: - Error Handling

    /// Sets up observation of audio player errors and converts them to user-friendly messages.
    private func setupErrorObservation() {
        audioPlayer.currentErrorPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (error: RadioError?) in
                self?.userErrorMessage = error?.userMessage
            }
            .store(in: &cancellables)
    }

    /// Changes to a new station and starts playback.
    func changeStation(to station: Station) {
        // Clear any existing errors
        userErrorMessage = nil
        
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

    /// Dismisses error state and retries playback.
    func dismissError() {
        userErrorMessage = nil
        audioPlayer.retryAfterError()
    }

    // MARK: - Live Activity

    @available(iOS 16.2, *)
    private func restartLiveActivity(for station: Station) {
        guard let liveActivityManager = getLiveActivityManager() else { return }

        liveActivityManager.endActivity()
        let contentState = SRRadioAttributes.ContentState(
            isPlaying: true,
            title: "",
            artist: "",
            show: ""
        )
        liveActivityManager.startActivity(station: station, state: contentState)
        Analytics.track(.liveActivityStart(stationId: station.id))
    }

    @available(iOS 16.2, *)
    func updateLiveActivity() {
        guard let liveActivityManager = getLiveActivityManager() else { return }

        let data = nowPlayingService.currentData

        switch audioPlayer.state {
        case .playing:
            let contentState = SRRadioAttributes.ContentState(
                isPlaying: true,
                title: data?.title ?? "",
                artist: data?.artist ?? "",
                show: data?.show ?? ""
            )
            if liveActivityManager.currentActivity == nil {
                liveActivityManager.startActivity(station: selectedStation, state: contentState)
            } else {
                liveActivityManager.updateActivity(state: contentState)
            }
        case .paused:
            let contentState = SRRadioAttributes.ContentState(
                isPlaying: false,
                title: data?.title ?? "",
                artist: data?.artist ?? "",
                show: data?.show ?? ""
            )
            liveActivityManager.updateActivity(state: contentState)
        case .idle:
            liveActivityManager.endActivity()
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
