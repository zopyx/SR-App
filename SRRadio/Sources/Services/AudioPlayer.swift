import AVFoundation
import Combine
import MediaPlayer

/// Manages audio playback for radio streams with proper state synchronization.
///
/// `AudioPlayer` handles:
/// - Loading and playing radio station streams
/// - Managing playback state (started, buffering, playing, paused, muted, error)
/// - Volume control and mute functionality
/// - Handling remote commands from Control Center and lock screen
/// - Automatic retry on stream failures
final class AudioPlayer: NSObject, ObservableObject {
    /// The current playback state.
    @Published var state: PlayerState = .started
    
    /// The current volume level (0.0 to 1.0).
    @Published var volume: Double = 0.8 {
        didSet {
            guard !isMuted else { return }
            let clampedVolume = max(0, min(1, volume))
            player?.volume = Float(clampedVolume)
        }
    }
    
    /// Whether audio is currently muted.
    @Published var isMuted: Bool = false {
        didSet {
            updateStateForMuteChange()
        }
    }
    
    /// The current error state, if any.
    @Published var currentError: RadioError?
    
    /// Publisher for currentError changes (required by AudioPlayerProtocol).
    var currentErrorPublisher: Published<RadioError?>.Publisher {
        self.$currentError
    }
    
    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var cancellables = Set<AnyCancellable>()
    private var retryCount = 0
    private let maxRetries = 3
    private var retryWorkItem: DispatchWorkItem?
    private var loadingTimeoutWorkItem: DispatchWorkItem?
    private var timeControlObservation: AnyCancellable?
    private var preMuteVolume: Double = 0.8
    
    /// The currently playing station, if any.
    private(set) var currentStation: Station?
    
    override init() {
        super.init()
        setupAudioSession()
        setupRemoteCommands()
    }
    
    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
        } catch {
            currentError = .audioSessionFailed(error)
            print("[AudioPlayer] Failed to set up audio session: \(error.localizedDescription)")
        }
    }
    
    /// Configures remote command handlers for Control Center and lock screen controls.
    private func setupRemoteCommands() {
        let center = MPRemoteCommandCenter.shared()
        
        center.playCommand.isEnabled = true
        center.playCommand.addTarget(self, action: #selector(handlePlayCommand(_:)))
        
        center.pauseCommand.isEnabled = true
        center.pauseCommand.addTarget(self, action: #selector(handlePauseCommand(_:)))
        
        center.togglePlayPauseCommand.isEnabled = true
        center.togglePlayPauseCommand.addTarget(self, action: #selector(handleTogglePlayPauseCommand(_:)))
        
        center.stopCommand.isEnabled = true
        center.stopCommand.addTarget(self, action: #selector(handleStopCommand(_:)))
    }
    
    @objc private func handlePlayCommand(_ command: MPRemoteCommand) -> MPRemoteCommandHandlerStatus {
        play()
        return .success
    }
    
    @objc private func handlePauseCommand(_ command: MPRemoteCommand) -> MPRemoteCommandHandlerStatus {
        pause()
        return .success
    }
    
    @objc private func handleTogglePlayPauseCommand(_ command: MPRemoteCommand) -> MPRemoteCommandHandlerStatus {
        togglePlayPause()
        return .success
    }
    
    @objc private func handleStopCommand(_ command: MPRemoteCommand) -> MPRemoteCommandHandlerStatus {
        pause()
        return .success
    }
    
    private func updateNowPlayingInfo() {
        var info = [String: Any]()
        info[MPMediaItemPropertyTitle] = currentStation?.name ?? "Saar Streams"
        info[MPMediaItemPropertyArtist] = currentStation?.description ?? ""
        info[MPNowPlayingInfoPropertyIsLiveStream] = true
        info[MPNowPlayingInfoPropertyPlaybackRate] = state.isPlaying ? 1.0 : 0.0
        
        // Set app logo as artwork
        if let artworkImage = UIImage(named: "app_logo") {
            let artwork = MPMediaItemArtwork(boundsSize: artworkImage.size) { _ in artworkImage }
            info[MPMediaItemPropertyArtwork] = artwork
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
    
    deinit {
        cleanup()
    }
    
    /// Loads a radio station and optionally starts playback.
    ///
    /// - Parameters:
    ///   - station: The station to load
    ///   - autoPlay: Whether to automatically start playback after loading (default: `false`)
    func loadStation(_ station: Station, autoPlay: Bool = false) {
        // Validate station URL before attempting to load
        guard station.isValidStreamURL else {
            currentError = .invalidURL(station.streamUrl.absoluteString)
            state = .error("Ungültige Stream-URL")
            return
        }
        
        cleanup()
        currentStation = station
        retryCount = 0
        currentError = nil
        
        // Always start in .started state when loading a new station
        state = .started
        
        let asset = AVURLAsset(url: station.streamUrl, options: nil)
        playerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: playerItem)
        
        // Observe player item status
        playerItem?.publisher(for: \.status)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.handlePlayerItemStatus(status)
            }
            .store(in: &cancellables)
        
        // Observe player timeControlStatus for actual playback detection
        timeControlObservation = player?.publisher(for: \.timeControlStatus)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self = self else { return }
                self.handleTimeControlStatus(status)
            }
        
        NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.handlePlaybackEnded()
            }
            .store(in: &cancellables)
        
        playerItem?.publisher(for: \.error)
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.handleError(error)
            }
            .store(in: &cancellables)
        
        // Set initial volume
        player?.volume = isMuted ? 0 : Float(volume)
        
        updateNowPlayingInfo()
        
        if autoPlay {
            // Start playback - will transition to .buffering when AVPlayer reports waiting
            player?.play()
            print("[AudioPlayer] Auto-play started for \(station.name)")
        }
    }
    
    private func handleTimeControlStatus(_ status: AVPlayer.TimeControlStatus) {
        print("[AudioPlayer] timeControlStatus: \(status), current state: \(state)")
        
        switch status {
        case .playing:
            loadingTimeoutWorkItem?.cancel()
            if state.isBuffering || (!state.isPlaying && !state.isMuted) {
                transitionToPlaying()
            }
        case .paused:
            // Player was paused - state is handled by pause() method
            break
        case .waitingToPlayAtSpecifiedRate:
            // Player is actually waiting/buffering - only now show buffering state
            if state == .started || (!state.isPlaying && !state.isMuted) {
                transitionToBuffering()
            }
        @unknown default:
            break
        }
    }
    
    private func transitionToBuffering() {
        state = .buffering
        print("[AudioPlayer] Transitioned to .buffering")
        
        // Set a timeout as fallback for streams that don't report status properly
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            if self.state.isBuffering {
                print("[AudioPlayer] Timeout: forcing transition to .playing")
                self.transitionToPlaying()
            }
        }
        loadingTimeoutWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: workItem)
    }
    
    private func handlePlayerItemStatus(_ status: AVPlayerItem.Status) {
        print("[AudioPlayer] playerItem status: \(status), current state: \(state)")
        
        switch status {
        case .readyToPlay:
            loadingTimeoutWorkItem?.cancel()
            if state.isBuffering {
                transitionToPlaying()
            }
        case .failed:
            handleError(playerItem?.error)
        case .unknown:
            // Still loading, wait for status change
            break
        @unknown default:
            break
        }
    }
    
    private func transitionToPlaying() {
        retryCount = 0
        
        if isMuted {
            state = .muted(underlying: .playing)
        } else {
            state = .playing
        }
        
        if let station = currentStation {
            Analytics.track(.playbackStart(stationId: station.id))
        }
        updateNowPlayingInfo()
        print("[AudioPlayer] Transitioned to playing state")
    }
    
    private func handlePlaybackEnded() {
        if retryCount < maxRetries {
            retryPlayback()
        } else {
            state = .error("Stream ended unexpectedly")
        }
    }
    
    /// Starts or resumes audio playback.
    func play() {
        guard let player = player else { return }
        
        // Cancel any existing timeout
        loadingTimeoutWorkItem?.cancel()
        
        player.play()
        
        // Note: We don't set .buffering here - wait for timeControlStatus to tell us
        // The state remains .started until AVPlayer reports .waitingToPlayAtSpecifiedRate
        print("[AudioPlayer] play() called, waiting for timeControlStatus...")
    }
    
    /// Pauses the current playback.
    func pause() {
        retryWorkItem?.cancel()
        loadingTimeoutWorkItem?.cancel()
        player?.pause()
        
        // Always go to .paused state when user explicitly stops/pauses
        // Mute state is separate - we don't show .muted when just paused
        state = .paused
        
        updateNowPlayingInfo()
        print("[AudioPlayer] Paused, state: \(state)")
    }
    
    /// Toggles between play and pause states.
    func togglePlayPause() {
        switch state {
        case .playing:
            pause()
        case .started:
            play()
        case .paused:
            play()
        case .buffering:
            pause()
        case .muted(let underlying):
            switch underlying {
            case .playing:
                pause()
            case .paused:
                play()
            }
        case .error:
            play()
        }
    }
    
    private func retryPlayback() {
        retryWorkItem?.cancel()
        retryCount += 1
        state = .error("Retrying... (\(retryCount)/\(maxRetries))")
        
        let workItem = DispatchWorkItem { [weak self] in
            self?.play()
        }
        retryWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: workItem)
    }
    
    private func handleError(_ error: Error?) {
        let radioError: RadioError
        if let underlyingError = error {
            let nsError = underlyingError as NSError
            if nsError.domain == AVFoundationErrorDomain {
                radioError = .streamLoadFailed(currentStation?.id ?? "unknown")
            } else {
                radioError = .networkError(underlyingError)
            }
        } else {
            radioError = .streamLoadFailed(currentStation?.id ?? "unknown")
        }
        
        if retryCount < maxRetries {
            retryPlayback()
        } else {
            currentError = radioError
            let errorMessage = error?.localizedDescription ?? "Wiedergabefehler"
            state = .error(errorMessage)
            if let station = currentStation {
                Analytics.track(.playbackError(stationId: station.id, error: errorMessage))
            }
        }
    }
    
    /// Toggles the mute state.
    func toggleMute() {
        isMuted.toggle()
        if isMuted {
            preMuteVolume = volume
            player?.volume = 0
        } else {
            let newVolume = preMuteVolume > 0 ? preMuteVolume : 0.8
            volume = newVolume
            player?.volume = Float(newVolume)
        }
        print("[AudioPlayer] Mute toggled: \(isMuted), state: \(state)")
    }
    
    private func updateStateForMuteChange() {
        switch state {
        case .playing:
            state = .muted(underlying: .playing)
        case .paused:
            state = .muted(underlying: .paused)
        case .muted(let underlying):
            // Unmuting - restore to appropriate state
            switch underlying {
            case .playing:
                state = .playing
            case .paused:
                state = .paused
            }
        default:
            // Buffering, started, and error states remain unchanged
            break
        }
        updateNowPlayingInfo()
    }
    
    /// Clears the current error state and attempts to reload the station.
    func retryAfterError() {
        currentError = nil
        if let station = currentStation {
            loadStation(station, autoPlay: true)
        }
    }
    
    private func cleanup() {
        retryWorkItem?.cancel()
        loadingTimeoutWorkItem?.cancel()
        timeControlObservation?.cancel()
        cancellables.removeAll()
        player?.pause()
        player = nil
        playerItem = nil
    }
}
