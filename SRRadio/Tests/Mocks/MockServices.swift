import Foundation
import Combine
@testable import SRRadio

// MARK: - Mock Audio Player

/// Mock implementation of AudioPlayerProtocol for testing.
final class MockAudioPlayer: AudioPlayerProtocol {
    @Published var state: PlayerState = .started
    @Published var volume: Double = 0.8
    @Published var isMuted: Bool = false
    @Published var currentError: RadioError?
    @Published var currentStation: Station?
    
    var cancellables = Set<AnyCancellable>()
    
    var loadStationCalled = false
    var loadStationCalledWith: Station?
    var loadStationAutoPlay: Bool = false
    
    var playCalled = false
    var pauseCalled = false
    var togglePlayPauseCalled = false
    var toggleMuteCalled = false
    var retryAfterErrorCalled = false
    
    func loadStation(_ station: Station, autoPlay: Bool) {
        loadStationCalled = true
        loadStationCalledWith = station
        loadStationAutoPlay = autoPlay
        currentStation = station
        if autoPlay {
            state = .started  // Will transition to buffering/playing when play() is called
        } else {
            state = .started
        }
    }
    
    func play() {
        playCalled = true
        if isMuted {
            state = .muted(underlying: .playing)
        } else {
            state = .playing
        }
    }
    
    func pause() {
        pauseCalled = true
        // When paused, always show paused (not muted)
        state = .paused
    }
    
    func togglePlayPause() {
        togglePlayPauseCalled = true
        switch state {
        case .playing:
            pause()
        case .started, .paused, .error:
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
        }
    }
    
    func toggleMute() {
        toggleMuteCalled = true
        isMuted.toggle()
        // Update state to reflect mute change
        switch state {
        case .playing:
            state = isMuted ? .muted(underlying: .playing) : .playing
        case .paused:
            state = isMuted ? .muted(underlying: .paused) : .paused
        case .muted(let underlying):
            // Unmuting - restore to appropriate state
            switch underlying {
            case .playing:
                state = .playing
            case .paused:
                state = .paused
            }
        default:
            break
        }
    }
    
    func retryAfterError() {
        retryAfterErrorCalled = true
        currentError = nil
        state = .started
    }
    
    func reset() {
        state = .started
        volume = 0.8
        isMuted = false
        currentError = nil
        currentStation = nil
        loadStationCalled = false
        loadStationCalledWith = nil
        loadStationAutoPlay = false
        playCalled = false
        pauseCalled = false
        togglePlayPauseCalled = false
        toggleMuteCalled = false
        retryAfterErrorCalled = false
    }
}

// MARK: - Mock Now Playing Service

/// Mock implementation of NowPlayingServiceProtocol for testing.
final class MockNowPlayingService: NowPlayingServiceProtocol {
    @Published var currentData: NowPlayingData?
    @Published var isLoading = false
    @Published var lastError: RadioError?
    
    var startMonitoringCalled = false
    var startMonitoringCalledWith: Station?
    var stopMonitoringCalled = false
    
    func startMonitoring(station: Station) {
        startMonitoringCalled = true
        startMonitoringCalledWith = station
        isLoading = true
    }
    
    func stopMonitoring() {
        stopMonitoringCalled = true
        isLoading = false
        currentData = nil
    }
    
    func reset() {
        currentData = nil
        isLoading = false
        lastError = nil
        startMonitoringCalled = false
        startMonitoringCalledWith = nil
        stopMonitoringCalled = false
    }
    
    func setData(_ data: NowPlayingData?) {
        currentData = data
        isLoading = false
    }
}
