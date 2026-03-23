import AVFoundation
import Combine
import MediaPlayer

/// Represents the current playback state of the audio player.
enum PlaybackState: Equatable {
    case idle
    case loading
    case playing
    case paused
    case error(String)
}

/// Manages audio playback for radio streams.
///
/// `AudioPlayer` is responsible for:
/// - Loading and playing radio station streams
/// - Managing playback state (idle, loading, playing, paused, error)
/// - Volume control and mute functionality
/// - Handling remote commands from Control Center and lock screen
/// - Automatic retry on stream failures
final class AudioPlayer: NSObject, ObservableObject {
    /// The current playback state.
    @Published var state: PlaybackState = .idle

    /// The current volume level (0.0 to 1.0).
    @Published var volume: Double = 0.8 {
        didSet {
            guard !isMuted else { return }
            let clampedVolume = max(0, min(1, volume))
            player?.volume = Float(clampedVolume)
        }
    }

    /// Whether audio is currently muted.
    @Published var isMuted: Bool = false

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
    private var preMuteVolume: Double = 0.8
    private var loadingTimeoutWorkItem: DispatchWorkItem?
    private var timeControlObservation: AnyCancellable?

    /// The currently playing station, if any.
    /// This is public to support the AudioPlayerProtocol.
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
            print("Failed to set up audio session: \(error.localizedDescription)")
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
        info[MPNowPlayingInfoPropertyPlaybackRate] = state == .playing ? 1.0 : 0.0
        
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

        let asset = AVURLAsset(url: station.streamUrl, options: nil)
        playerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: playerItem)

        playerItem?.publisher(for: \.status)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.handlePlayerItemStatus(status)
            }
            .store(in: &cancellables)

        // Observe player timeControlStatus to detect when playback actually starts
        // timeControlStatus is more reliable than rate for live streams
        timeControlObservation = player?.publisher(for: \.timeControlStatus)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self = self else { return }
                print("[AudioPlayer] timeControlStatus: \(status), state: \(self.state)")
                if status == .playing && self.state == .loading {
                    self.loadingTimeoutWorkItem?.cancel()
                    self.state = .playing
                    self.retryCount = 0
                    print("[AudioPlayer] Transitioned to .playing via timeControlStatus")
                    if let station = self.currentStation {
                        Analytics.track(.playbackStart(stationId: station.id))
                    }
                    self.updateNowPlayingInfo()
                }
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.play()
            }
        }
    }

    private func handlePlayerItemStatus(_ status: AVPlayerItem.Status) {
        switch status {
        case .readyToPlay:
            // Player item is ready to play - for live streams this means we're playing
            print("[AudioPlayer] readyToPlay received, state: \(state)")
            loadingTimeoutWorkItem?.cancel()
            if state == .loading {
                state = .playing
                retryCount = 0
                print("[AudioPlayer] Transitioned to .playing via readyToPlay")
                if let station = currentStation {
                    Analytics.track(.playbackStart(stationId: station.id))
                }
                updateNowPlayingInfo()
            }
        case .failed:
            handleError(playerItem?.error)
        case .unknown:
            // Wait for status to change to readyToPlay or failed
            print("[AudioPlayer] Status unknown, waiting...")
            break
        @unknown default:
            break
        }
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
        
        state = .loading
        player.play()
        
        // Set a timeout to transition to playing after 5 seconds
        // This is a fallback for streams that don't report readyToPlay or rate changes
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            // Only transition if still loading (no readyToPlay or rate event received)
            if self.state == .loading {
                print("[AudioPlayer] Timeout: forcing transition to .playing")
                self.state = .playing
                self.retryCount = 0
                if let station = self.currentStation {
                    Analytics.track(.playbackStart(stationId: station.id))
                }
                self.updateNowPlayingInfo()
            }
        }
        loadingTimeoutWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: workItem)
    }

    /// Pauses the current playback.
    func pause() {
        retryWorkItem?.cancel()
        loadingTimeoutWorkItem?.cancel()
        player?.pause()
        state = .paused
        updateNowPlayingInfo()
    }

    /// Toggles between play and pause states.
    func togglePlayPause() {
        switch state {
        case .playing:
            pause()
        case .paused, .idle, .error:
            play()
        case .loading:
            pause()
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
            // Check for specific AVFoundation error codes
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
            // Track playback error
            if let station = currentStation {
                Analytics.track(.playbackError(stationId: station.id, error: errorMessage))
            }
        }
    }

    /// Toggles the mute state.
    ///
    /// When muting, stores the current volume for restoration on unmute.
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
