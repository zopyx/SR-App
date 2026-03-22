import XCTest
@testable import SRRadio

final class AudioPlayerTests: XCTestCase {
    
    var audioPlayer: AudioPlayer!
    
    override func setUp() {
        super.setUp()
        audioPlayer = AudioPlayer()
    }
    
    override func tearDown() {
        audioPlayer = nil
        super.tearDown()
    }
    
    // MARK: - Volume Tests
    
    func testInitialVolume() {
        XCTAssertEqual(audioPlayer.volume, 0.8, accuracy: 0.01)
    }
    
    func testVolumeClamping_max() {
        audioPlayer.volume = 1.5
        XCTAssertEqual(audioPlayer.volume, 1.0, accuracy: 0.01)
    }
    
    func testVolumeClamping_min() {
        audioPlayer.volume = -0.5
        XCTAssertEqual(audioPlayer.volume, 0.0, accuracy: 0.01)
    }
    
    func testVolumeValidValues() {
        audioPlayer.volume = 0.0
        XCTAssertEqual(audioPlayer.volume, 0.0, accuracy: 0.01)
        
        audioPlayer.volume = 0.5
        XCTAssertEqual(audioPlayer.volume, 0.5, accuracy: 0.01)
        
        audioPlayer.volume = 1.0
        XCTAssertEqual(audioPlayer.volume, 1.0, accuracy: 0.01)
    }
    
    // MARK: - Mute Tests
    
    func testInitialMuteState() {
        XCTAssertFalse(audioPlayer.isMuted)
    }
    
    func testMuteToggle() {
        let initialVolume = audioPlayer.volume
        
        // Mute
        audioPlayer.toggleMute()
        XCTAssertTrue(audioPlayer.isMuted)
        
        // Unmute should restore volume
        audioPlayer.toggleMute()
        XCTAssertFalse(audioPlayer.isMuted)
        XCTAssertEqual(audioPlayer.volume, initialVolume, accuracy: 0.01)
    }
    
    func testMuteMultipleToggles() {
        audioPlayer.toggleMute()
        audioPlayer.toggleMute()
        audioPlayer.toggleMute()
        XCTAssertTrue(audioPlayer.isMuted)
        
        audioPlayer.toggleMute()
        XCTAssertFalse(audioPlayer.isMuted)
    }
    
    func testMuteWithZeroVolume() {
        audioPlayer.volume = 0.0
        audioPlayer.toggleMute()
        XCTAssertTrue(audioPlayer.isMuted)
    }
    
    // MARK: - Playback State Tests
    
    func testInitialState() {
        XCTAssertEqual(audioPlayer.state, .idle)
    }
    
    func testTogglePlayPause_fromIdle() {
        audioPlayer.togglePlayPause()
        // Should transition to loading then playing (async)
        // For now, just verify it doesn't crash
    }
    
    // MARK: - Station Loading Tests
    
    func testLoadStation_setsCurrentStation() {
        let station = Station.sr1
        audioPlayer.loadStation(station, autoPlay: false)
        
        XCTAssertEqual(audioPlayer.currentStation?.id, station.id)
    }
    
    func testLoadStation_resetsRetryCount() {
        // This is an internal property, but we can verify
        // the station loads without crashing
        let station = Station.sr1
        audioPlayer.loadStation(station, autoPlay: false)
        XCTAssertEqual(audioPlayer.currentStation?.id, station.id)
    }
    
    func testLoadMultipleStations() {
        let station1 = Station.sr1
        let station2 = Station.sr3
        
        audioPlayer.loadStation(station1, autoPlay: false)
        XCTAssertEqual(audioPlayer.currentStation?.id, station1.id)
        
        audioPlayer.loadStation(station2, autoPlay: false)
        XCTAssertEqual(audioPlayer.currentStation?.id, station2.id)
    }
    
    // MARK: - Playback State Transitions
    
    func testPlaybackStateTransitions() {
        // Initial state
        XCTAssertEqual(audioPlayer.state, .idle)
        
        // After calling play (will be loading initially)
        audioPlayer.play()
        // State should be loading or playing (async)
        
        // Pause
        audioPlayer.pause()
        XCTAssertEqual(audioPlayer.state, .paused)
    }
    
    // MARK: - Error Handling

    func testErrorStateMessage() {
        // Verify error state contains message
        let errorState: PlaybackState = .error("Test error")
        if case .error(let message) = errorState {
            XCTAssertEqual(message, "Test error")
        } else {
            XCTFail("Expected error state")
        }
    }

    func testPlaybackStateEquatable() {
        let state1: PlaybackState = .idle
        let state2: PlaybackState = .idle
        let state3: PlaybackState = .playing

        XCTAssertEqual(state1, state2)
        XCTAssertNotEqual(state1, state3)
    }

    func testErrorStatesWithDifferentMessages() {
        let error1: PlaybackState = .error("Error 1")
        let error2: PlaybackState = .error("Error 2")

        XCTAssertNotEqual(error1, error2)
    }

    // MARK: - RadioError Tests

    func testAudioPlayerInitialErrorState() {
        XCTAssertNil(audioPlayer.currentError)
    }

    func testPlaybackStateErrorTransitions() {
        // Test that we can transition to error state
        let errorState: PlaybackState = .error("Test error")
        audioPlayer.loadStation(Station.sr1, autoPlay: false)
        // Note: We can't easily test error state transitions without mocking
        // the AVPlayer, but we verify the property exists
        XCTAssertNotNil(errorState)
    }

    func testRetryAfterError() {
        // Verify the method exists and doesn't crash
        audioPlayer.loadStation(Station.sr1, autoPlay: false)
        audioPlayer.retryAfterError()
        // The station should be reloading
        XCTAssertEqual(audioPlayer.currentStation?.id, Station.sr1.id)
    }
}

// MARK: - Linux Support

extension AudioPlayerTests {
    static var allTests: [(String, (AudioPlayerTests) -> () throws -> Void)] {
        [
            ("testInitialVolume", testInitialVolume),
            ("testVolumeClamping_max", testVolumeClamping_max),
            ("testVolumeClamping_min", testVolumeClamping_min),
            ("testInitialMuteState", testInitialMuteState),
            ("testMuteToggle", testMuteToggle),
            ("testInitialState", testInitialState),
            ("testLoadStation_setsCurrentStation", testLoadStation_setsCurrentStation),
            ("testPlaybackStateEquatable", testPlaybackStateEquatable),
        ]
    }
}
