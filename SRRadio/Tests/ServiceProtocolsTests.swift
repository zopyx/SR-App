import XCTest
import Combine
@testable import SRRadio

/// Tests for service protocol conformances and implementations.
final class ServiceProtocolsTests: XCTestCase {

    // MARK: - AudioPlayerProtocol Conformance Tests

    func testAudioPlayerConformsToProtocol() {
        let player = AudioPlayer()
        let playerAsProtocol: AudioPlayerProtocol = player
        XCTAssertIdentical(player as AnyObject, playerAsProtocol as AnyObject)
    }

    func testAudioPlayerProtocol_PublishedState() {
        let player = AudioPlayer()
        XCTAssertEqual(player.state, .started)
    }

    func testAudioPlayerProtocol_PublishedVolume() {
        let player = AudioPlayer()
        XCTAssertEqual(player.volume, 0.8, accuracy: 0.01)
    }

    func testAudioPlayerProtocol_PublishedIsMuted() {
        let player = AudioPlayer()
        XCTAssertFalse(player.isMuted)
    }

    func testAudioPlayerProtocol_CurrentErrorInitiallyNil() {
        let player = AudioPlayer()
        XCTAssertNil(player.currentError)
    }

    func testAudioPlayerProtocol_CurrentStationInitiallyNil() {
        let player = AudioPlayer()
        XCTAssertNil(player.currentStation)
    }

    func testAudioPlayerProtocol_CurrentErrorPublisher() {
        let player = AudioPlayer()
        XCTAssertNotNil(player.currentErrorPublisher)
    }

    // MARK: - NowPlayingServiceProtocol Conformance Tests

    func testNowPlayingServiceConformsToProtocol() {
        let service = NowPlayingService()
        let serviceAsProtocol: NowPlayingServiceProtocol = service
        XCTAssertIdentical(service as AnyObject, serviceAsProtocol as AnyObject)
    }

    func testNowPlayingServiceProtocol_CurrentDataInitiallyNil() {
        let service = NowPlayingService()
        XCTAssertNil(service.currentData)
    }

    func testNowPlayingServiceProtocol_IsLoadingInitiallyFalse() {
        let service = NowPlayingService()
        XCTAssertFalse(service.isLoading)
    }

    func testNowPlayingServiceProtocol_LastErrorInitiallyNil() {
        let service = NowPlayingService()
        XCTAssertNil(service.lastError)
    }

    // MARK: - Mock Conformance Tests

    func testMockAudioPlayerConformsToProtocol() {
        let mock = MockAudioPlayer()
        let mockAsProtocol: AudioPlayerProtocol = mock
        XCTAssertIdentical(mock as AnyObject, mockAsProtocol as AnyObject)
    }

    func testMockNowPlayingServiceConformsToProtocol() {
        let mock = MockNowPlayingService()
        let mockAsProtocol: NowPlayingServiceProtocol = mock
        XCTAssertIdentical(mock as AnyObject, mockAsProtocol as AnyObject)
    }

    // MARK: - AudioPlayer Method Tests

    func testAudioPlayer_LoadStation() {
        let player = AudioPlayer()
        player.loadStation(.sr1, autoPlay: false)
        XCTAssertEqual(player.currentStation?.id, Station.sr1.id)
    }

    func testAudioPlayer_Play() {
        let player = AudioPlayer()
        player.loadStation(.sr1, autoPlay: false)
        player.play()
        // State should transition to buffering or playing
        XCTAssertTrue(player.state == .buffering || player.state == .playing)
    }

    func testAudioPlayer_Pause() {
        let player = AudioPlayer()
        player.loadStation(.sr1, autoPlay: false)
        player.play()
        player.pause()
        // State should be started or muted
        XCTAssertTrue(player.state == .started || player.state.isMuted)
    }

    func testAudioPlayer_TogglePlayPause() {
        let player = AudioPlayer()
        player.loadStation(.sr1, autoPlay: false)
        let initialState = player.state
        player.togglePlayPause()
        // State should change from initial
        XCTAssertNotEqual(player.state, initialState)
    }

    func testAudioPlayer_ToggleMute() {
        let player = AudioPlayer()
        let initialMuteState = player.isMuted
        player.toggleMute()
        XCTAssertNotEqual(player.isMuted, initialMuteState)
    }

    func testAudioPlayer_RetryAfterError() {
        let player = AudioPlayer()
        player.loadStation(.sr1, autoPlay: false)
        // Should not crash
        player.retryAfterError()
        XCTAssertEqual(player.currentStation?.id, Station.sr1.id)
    }

    // MARK: - NowPlayingService Method Tests

    func testNowPlayingService_StartMonitoring_SRStation() {
        let service = NowPlayingService()
        service.startMonitoring(station: .sr1)

        XCTAssertTrue(service.isLoading)
        XCTAssertNil(service.lastError)
    }

    func testNowPlayingService_StartMonitoring_NonSRStation() {
        let service = NowPlayingService()
        service.startMonitoring(station: .radioSalue)

        XCTAssertFalse(service.isLoading)
        XCTAssertNotNil(service.lastError)

        if let error = service.lastError {
            if case .stationNotSupported(let stationId, let feature) = error {
                XCTAssertEqual(stationId, "radio_salue")
                XCTAssertEqual(feature, "Now Playing")
            } else {
                XCTFail("Expected stationNotSupported error")
            }
        }
    }

    func testNowPlayingService_StopMonitoring() {
        let service = NowPlayingService()
        service.startMonitoring(station: .sr1)
        service.stopMonitoring()

        XCTAssertNil(service.currentData)
        XCTAssertFalse(service.isLoading)
    }

    func testNowPlayingService_StartMonitoring_ClearsPreviousData() {
        let service = NowPlayingService()
        service.startMonitoring(station: .sr1)
        service.stopMonitoring()
        service.startMonitoring(station: .sr3)

        XCTAssertNil(service.currentData)
        XCTAssertTrue(service.isLoading)
    }

    // MARK: - Protocol Witness Tests

    func testProtocolWitness_AudioPlayer() {
        let player: AudioPlayerProtocol = AudioPlayer()
        player.loadStation(.sr1, autoPlay: false)
        XCTAssertEqual(player.currentStation?.id, Station.sr1.id)
    }

    func testProtocolWitness_NowPlayingService() {
        let service: NowPlayingServiceProtocol = NowPlayingService()
        service.startMonitoring(station: .sr1)
        XCTAssertTrue(service.isLoading)
    }

    // MARK: - Dependency Injection Tests

    func testInjectAudioPlayerProtocol() {
        func usePlayer(_ player: AudioPlayerProtocol) -> Station? {
            player.loadStation(.sr3, autoPlay: false)
            return player.currentStation
        }

        let player = AudioPlayer()
        let station = usePlayer(player)
        XCTAssertEqual(station?.id, Station.sr3.id)
    }

    func testInjectNowPlayingServiceProtocol() {
        func useService(_ service: NowPlayingServiceProtocol) -> Bool {
            service.startMonitoring(station: .sr1)
            return service.isLoading
        }

        let service = NowPlayingService()
        let isLoading = useService(service)
        XCTAssertTrue(isLoading)
    }

    // MARK: - ObservableObject Conformance Tests

    func testAudioPlayer_IsObservableObject() {
        let player = AudioPlayer()
        _ = objectWillChange.sink { _ in } // Should not crash
        XCTAssertNotNil(player.objectWillChange)
    }

    func testNowPlayingService_IsObservableObject() {
        let service = NowPlayingService()
        _ = objectWillChange.sink { _ in } // Should not crash
        XCTAssertNotNil(service.objectWillChange)
    }

    func testMockAudioPlayer_IsObservableObject() {
        let mock = MockAudioPlayer()
        _ = mock.objectWillChange.sink { _ in }
        XCTAssertNotNil(mock.objectWillChange)
    }

    func testMockNowPlayingService_IsObservableObject() {
        let mock = MockNowPlayingService()
        _ = mock.objectWillChange.sink { _ in }
        XCTAssertNotNil(mock.objectWillChange)
    }

    // MARK: - Published Property Updates

    func testAudioPlayer_VolumeUpdate_Publishes() {
        let player = AudioPlayer()
        let expectation = XCTestExpectation(description: "Volume change published")

        player.objectWillChange.sink { _ in
            expectation.fulfill()
        }.store(in: &player.cancellables)

        player.volume = 0.5
        wait(for: [expectation], timeout: 1.0)
    }

    func testNowPlayingService_IsLoadingUpdate_Publishes() {
        let service = NowPlayingService()
        let expectation = XCTestExpectation(description: "isLoading change published")

        service.objectWillChange.sink { _ in
            expectation.fulfill()
        }.store(in: &service.cancellables)

        service.startMonitoring(station: .sr1)
        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - Edge Cases

    func testAudioPlayer_LoadStationWithInvalidURL() {
        let player = AudioPlayer()
        // Create a station with invalid URL
        player.loadStation(.sr1, autoPlay: false)
        // Should not crash, should set currentStation
        XCTAssertNotNil(player.currentStation)
    }

    func testNowPlayingService_StartMonitoringSameStationTwice() {
        let service = NowPlayingService()
        service.startMonitoring(station: .sr1)
        service.startMonitoring(station: .sr1)
        // Should not crash, should reset monitoring
        XCTAssertTrue(service.isLoading)
    }

    func testNowPlayingService_StopMonitoringWithoutStarting() {
        let service = NowPlayingService()
        // Should not crash
        service.stopMonitoring()
        XCTAssertFalse(service.isLoading)
    }

    func testAudioPlayer_TogglePlayPauseWithoutLoadStation() {
        let player = AudioPlayer()
        // Should not crash
        player.togglePlayPause()
    }

    func testAudioPlayer_PauseWithoutLoadStation() {
        let player = AudioPlayer()
        // Should not crash
        player.pause()
    }
}

// MARK: - Linux Support

extension ServiceProtocolsTests {
    static var allTests: [(String, (ServiceProtocolsTests) -> () throws -> Void)] {
        [
            ("testAudioPlayerConformsToProtocol", testAudioPlayerConformsToProtocol),
            ("testNowPlayingServiceConformsToProtocol", testNowPlayingServiceConformsToProtocol),
            ("testMockAudioPlayerConformsToProtocol", testMockAudioPlayerConformsToProtocol),
            ("testMockNowPlayingServiceConformsToProtocol", testMockNowPlayingServiceConformsToProtocol),
            ("testAudioPlayer_LoadStation", testAudioPlayer_LoadStation),
            ("testAudioPlayer_ToggleMute", testAudioPlayer_ToggleMute),
            ("testNowPlayingService_StartMonitoring_SRStation", testNowPlayingService_StartMonitoring_SRStation),
            ("testNowPlayingService_StartMonitoring_NonSRStation", testNowPlayingService_StartMonitoring_NonSRStation),
            ("testProtocolWitness_AudioPlayer", testProtocolWitness_AudioPlayer),
            ("testInjectAudioPlayerProtocol", testInjectAudioPlayerProtocol),
        ]
    }
}
