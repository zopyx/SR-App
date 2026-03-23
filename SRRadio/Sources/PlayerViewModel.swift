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
    
    /// The current player state - published so UI updates when state changes
    @Published var playerState: PlayerState = .started
    
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
    
    /// The audio player service.
    var audioPlayer: any AudioPlayerProtocol { _audioPlayer }
    
    /// The now playing service.
    var nowPlayingService: any NowPlayingServiceProtocol { _nowPlayingService }
    
    // MARK: - Private Properties
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    
    /// Returns true when audio is actively playing (not buffering, not paused)
    var isPlaying: Bool {
        playerState.isPlaying
    }
    
    /// Returns true when the player is in buffering state
    var isBuffering: Bool {
        playerState.isBuffering
    }
    
    /// Returns true when the player is paused
    var isPaused: Bool {
        playerState.isPaused
    }
    
    /// Returns true when the player is muted
    var isMutedState: Bool {
        playerState.isMuted
    }
    
    /// Returns any error message from the player state
    var errorMessage: String? {
        if case .error(let msg) = playerState { return msg }
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
    init(
        audioPlayer: (any AudioPlayerProtocol)? = nil,
        nowPlayingService: (any NowPlayingServiceProtocol)? = nil
    ) {
        // Use injected dependencies or resolve from container
        self._audioPlayer = audioPlayer ?? Container.shared.resolveAudioPlayer()
        self._nowPlayingService = nowPlayingService ?? Container.shared.resolveNowPlayingService()
        
        // Load last played station
        self.selectedStation = Station.lastPlayed
        
        // Initialize playerState from audioPlayer
        self.playerState = self._audioPlayer.state
        
        // Setup observations
        setupErrorObservation()
        setupStateObservation()
    }
    
    // MARK: - Setup
    
    /// Sets up observation of audio player state changes.
    private func setupStateObservation() {
        // Observe the concrete AudioPlayer's state publisher
        // Since we know the concrete type is AudioPlayer, we can observe its @Published state
        if let audioPlayer = _audioPlayer as? AudioPlayer {
            audioPlayer.$state
                .receive(on: DispatchQueue.main)
                .sink { [weak self] newState in
                    self?.playerState = newState
                }
                .store(in: &cancellables)
        }
        #if DEBUG
        // For mocks in tests, we rely on manual state sync via onPlaybackStateChange()
        // or immediate sync in methods like changeStation()
        #endif
    }
    
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
        
        // Sync state immediately
        playerState = audioPlayer.state
        
        // Track analytics
        Analytics.track(.stationChange(stationId: station.id, stationName: station.name))
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
    
    // MARK: - Lifecycle
    
    func onViewAppear() {
        audioPlayer.loadStation(selectedStation, autoPlay: true)
        nowPlayingService.startMonitoring(station: selectedStation)
        Analytics.recordAppLaunch()
    }
    
    func onPlaybackStateChange() {
        // Sync state from audio player
        playerState = audioPlayer.state
    }
    
    func onNowPlayingChange() {
        // Now playing updates are automatically published
    }
}
