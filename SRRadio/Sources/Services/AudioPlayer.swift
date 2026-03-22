import AVFoundation
import Combine

enum PlaybackState: Equatable {
    case idle
    case loading
    case playing
    case paused
    case error(String)
}

final class AudioPlayer: ObservableObject {
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
    
    init() {
        setupAudioSession()
    }

    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
        }
    }
    
    deinit {
        cleanup()
    }
    
    func loadStation(_ station: Station, autoPlay: Bool = false) {
        cleanup()
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
        }
    }
    
    func pause() {
        retryWorkItem?.cancel()
        player?.pause()
        state = .paused
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
