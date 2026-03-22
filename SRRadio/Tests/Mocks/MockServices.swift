import Foundation
import Combine
@testable import SRRadio

// MARK: - Mock Audio Player

/// Mock implementation of AudioPlayerProtocol for testing.
final class MockAudioPlayer: AudioPlayerProtocol {
    @Published var state: PlaybackState = .idle
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
            state = .playing
        }
    }
    
    func play() {
        playCalled = true
        state = .playing
    }
    
    func pause() {
        pauseCalled = true
        state = .paused
    }
    
    func togglePlayPause() {
        togglePlayPauseCalled = true
        state = state == .playing ? .paused : .playing
    }
    
    func toggleMute() {
        toggleMuteCalled = true
        isMuted.toggle()
    }
    
    func retryAfterError() {
        retryAfterErrorCalled = true
        currentError = nil
    }
    
    func reset() {
        state = .idle
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
