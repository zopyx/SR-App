import AVFoundation
import Combine
import MediaPlayer

enum PlaybackState: Equatable {
    case idle
    case loading
    case playing
    case paused
    case error(String)
}

final class AudioPlayer: NSObject, ObservableObject {
    @Published var state: PlaybackState = .idle
    @Published var volume: Double = 0.8 {
        didSet {
            guard !isMuted else { return }
            let clampedVolume = max(0, min(1, volume))
            player?.volume = Float(clampedVolume)
        }
    }
    @Published var isMuted: Bool = false

    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var cancellables = Set<AnyCancellable>()
    private var retryCount = 0
    private let maxRetries = 3
    private var retryWorkItem: DispatchWorkItem?
    private var preMuteVolume: Double = 0.8
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
            print("Failed to set up audio session: \(error.localizedDescription)")
        }
    }

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

    func loadStation(_ station: Station, autoPlay: Bool = false) {
        cleanup()
        currentStation = station
        retryCount = 0

        let asset = AVURLAsset(url: station.streamUrl, options: nil)
        playerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: playerItem)

        playerItem?.publisher(for: \.status)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.handlePlayerItemStatus(status)
            }
            .store(in: &cancellables)

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
        case .failed:
            handleError(playerItem?.error)
        default:
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

    func play() {
        guard let player = player else { return }
        state = .loading
        player.play()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            if self.player?.rate ?? 0 > 0 {
                self.state = .playing
                self.retryCount = 0
            } else {
                self.handleError(nil)
            }
            self.updateNowPlayingInfo()
        }
    }

    func pause() {
        retryWorkItem?.cancel()
        player?.pause()
        state = .paused
        updateNowPlayingInfo()
    }

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
        if retryCount < maxRetries {
            retryPlayback()
        } else {
            state = .error(error?.localizedDescription ?? "Playback error")
        }
    }

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

    private func cleanup() {
        retryWorkItem?.cancel()
        cancellables.removeAll()
        player?.pause()
        player = nil
        playerItem = nil
    }
}
