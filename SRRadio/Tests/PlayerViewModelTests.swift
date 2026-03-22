import XCTest
@testable import SRRadio

/// Tests for PlayerViewModel dependency injection pattern.
final class PlayerViewModelTests: XCTestCase {

    var mockAudioPlayer: MockAudioPlayer!
    var mockNowPlayingService: MockNowPlayingService!
    var mockLiveActivityManager: MockLiveActivityManager!

    override func setUp() {
        super.setUp()
        mockAudioPlayer = MockAudioPlayer()
        mockNowPlayingService = MockNowPlayingService()
        
        if #available(iOS 16.2, *) {
            mockLiveActivityManager = MockLiveActivityManager()
        }
    }

    override func tearDown() {
        mockAudioPlayer = nil
        mockNowPlayingService = nil
        mockLiveActivityManager = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testViewModelInitializesWithInjectedDependencies() {
        // Given
        let viewModel = PlayerViewModel(
            audioPlayer: mockAudioPlayer,
            nowPlayingService: mockNowPlayingService,
            liveActivityManager: mockLiveActivityManager
        )

        // Then
        XCTAssertIdentical(viewModel.audioPlayer as? MockAudioPlayer, mockAudioPlayer)
        XCTAssertIdentical(viewModel.nowPlayingService as? MockNowPlayingService, mockNowPlayingService)
    }

    func testViewModelInitializesWithDefaultDependencies() {
        // Given
        Container.shared.registerDefaultServices()

        // When
        let viewModel = PlayerViewModel()

        // Then
        XCTAssertNotNil(viewModel.audioPlayer)
        XCTAssertNotNil(viewModel.nowPlayingService)
        if #available(iOS 16.2, *) {
            XCTAssertNotNil(viewModel.liveActivityManager)
        }
    }

    // MARK: - Station Change Tests

    func testChangeStation_UpdatesSelectedStation() {
        // Given
        let viewModel = PlayerViewModel(
            audioPlayer: mockAudioPlayer,
            nowPlayingService: mockNowPlayingService,
            liveActivityManager: mockLiveActivityManager
        )
        let newStation = Station.sr3

        // When
        viewModel.changeStation(to: newStation)

        // Then
        XCTAssertEqual(viewModel.selectedStation, newStation)
        XCTAssertEqual(mockAudioPlayer.loadStationCalledWith, newStation)
        XCTAssertEqual(mockNowPlayingService.startMonitoringCalledWith, newStation)
    }

    func testChangeStation_CallsAudioPlayerLoadStation() {
        // Given
        let viewModel = PlayerViewModel(
            audioPlayer: mockAudioPlayer,
            nowPlayingService: mockNowPlayingService,
            liveActivityManager: mockLiveActivityManager
        )

        // When
        viewModel.changeStation(to: .sr1)

        // Then
        XCTAssertTrue(mockAudioPlayer.loadStationCalled)
        XCTAssertTrue(mockAudioPlayer.loadStationAutoPlay)
    }

    func testChangeStation_CallsNowPlayingServiceStartMonitoring() {
        // Given
        let viewModel = PlayerViewModel(
            audioPlayer: mockAudioPlayer,
            nowPlayingService: mockNowPlayingService,
            liveActivityManager: mockLiveActivityManager
        )

        // When
        viewModel.changeStation(to: .sr1)

        // Then
        XCTAssertTrue(mockNowPlayingService.startMonitoringCalled)
    }

    // MARK: - Playback Control Tests

    func testIsPlaying_DelegatesToAudioPlayer() {
        // Given
        let viewModel = PlayerViewModel(
            audioPlayer: mockAudioPlayer,
            nowPlayingService: mockNowPlayingService,
            liveActivityManager: mockLiveActivityManager
        )

        // When
        mockAudioPlayer.state = .playing

        // Then
        XCTAssertTrue(viewModel.isPlaying)
    }

    func testIsLoading_DelegatesToAudioPlayer() {
        // Given
        let viewModel = PlayerViewModel(
            audioPlayer: mockAudioPlayer,
            nowPlayingService: mockNowPlayingService,
            liveActivityManager: mockLiveActivityManager
        )

        // When
        mockAudioPlayer.state = .loading

        // Then
        XCTAssertTrue(viewModel.isLoading)
    }

    func testVolume_GetterDelegatesToAudioPlayer() {
        // Given
        let viewModel = PlayerViewModel(
            audioPlayer: mockAudioPlayer,
            nowPlayingService: mockNowPlayingService,
            liveActivityManager: mockLiveActivityManager
        )
        mockAudioPlayer.volume = 0.5

        // When
        let volume = viewModel.volume

        // Then
        XCTAssertEqual(volume, 0.5, accuracy: 0.01)
    }

    func testVolume_SetterDelegatesToAudioPlayer() {
        // Given
        let viewModel = PlayerViewModel(
            audioPlayer: mockAudioPlayer,
            nowPlayingService: mockNowPlayingService,
            liveActivityManager: mockLiveActivityManager
        )

        // When
        viewModel.volume = 0.6

        // Then
        XCTAssertEqual(mockAudioPlayer.volume, 0.6, accuracy: 0.01)
    }

    func testIsMuted_GetterDelegatesToAudioPlayer() {
        // Given
        let viewModel = PlayerViewModel(
            audioPlayer: mockAudioPlayer,
            nowPlayingService: mockNowPlayingService,
            liveActivityManager: mockLiveActivityManager
        )
        mockAudioPlayer.isMuted = true

        // When
        let isMuted = viewModel.isMuted

        // Then
        XCTAssertTrue(isMuted)
    }

    func testIsMuted_SetterDelegatesToAudioPlayer() {
        // Given
        let viewModel = PlayerViewModel(
            audioPlayer: mockAudioPlayer,
            nowPlayingService: mockNowPlayingService,
            liveActivityManager: mockLiveActivityManager
        )

        // When
        viewModel.isMuted = true

        // Then
        XCTAssertTrue(mockAudioPlayer.toggleMuteCalled)
    }

    // MARK: - Error Handling Tests

    func testErrorMessage_ExtractsFromAudioPlayerState() {
        // Given
        let viewModel = PlayerViewModel(
            audioPlayer: mockAudioPlayer,
            nowPlayingService: mockNowPlayingService,
            liveActivityManager: mockLiveActivityManager
        )
        mockAudioPlayer.state = .error("Test error")

        // When
        let errorMessage = viewModel.errorMessage

        // Then
        XCTAssertEqual(errorMessage, "Test error")
    }

    func testDismissError_ClearsUserErrorMessage() {
        // Given
        let viewModel = PlayerViewModel(
            audioPlayer: mockAudioPlayer,
            nowPlayingService: mockNowPlayingService,
            liveActivityManager: mockLiveActivityManager
        )
        viewModel.userErrorMessage = "Test error"

        // When
        viewModel.dismissError()

        // Then
        XCTAssertNil(viewModel.userErrorMessage)
        XCTAssertTrue(mockAudioPlayer.retryAfterErrorCalled)
    }

    // MARK: - Live Activity Tests

    @available(iOS 16.2, *)
    func testChangeStation_RestartsLiveActivity() {
        // Given
        let viewModel = PlayerViewModel(
            audioPlayer: mockAudioPlayer,
            nowPlayingService: mockNowPlayingService,
            liveActivityManager: mockLiveActivityManager
        )

        // When
        viewModel.changeStation(to: .sr1)

        // Then
        XCTAssertTrue(mockLiveActivityManager.endActivityCalled)
        XCTAssertTrue(mockLiveActivityManager.startActivityCalled)
    }

    @available(iOS 16.2, *)
    func testUpdateLiveActivity_UpdatesWithPlayingState() {
        // Given
        let viewModel = PlayerViewModel(
            audioPlayer: mockAudioPlayer,
            nowPlayingService: mockNowPlayingService,
            liveActivityManager: mockLiveActivityManager
        )
        mockAudioPlayer.state = .playing
        mockNowPlayingService.setData(NowPlayingData(
            title: "Test Song",
            artist: "Test Artist",
            show: "Test Show",
            moderator: "Test Moderator"
        ))

        // When
        viewModel.updateLiveActivity()

        // Then
        XCTAssertTrue(mockLiveActivityManager.updateActivityCalled)
    }

    @available(iOS 16.2, *)
    func testUpdateLiveActivity_EndsActivityOnIdle() {
        // Given
        let viewModel = PlayerViewModel(
            audioPlayer: mockAudioPlayer,
            nowPlayingService: mockNowPlayingService,
            liveActivityManager: mockLiveActivityManager
        )
        mockAudioPlayer.state = .idle

        // When
        viewModel.updateLiveActivity()

        // Then
        XCTAssertTrue(mockLiveActivityManager.endActivityCalled)
    }

    // MARK: - Container Tests

    func testContainer_RegistersAndResolvesServices() {
        // Given
        let container = Container()

        // When
        container.register(AudioPlayerProtocol.self) {
            MockAudioPlayer()
        }
        let audioPlayer = container.resolve(AudioPlayerProtocol.self)

        // Then
        XCTAssertNotNil(audioPlayer)
        XCTAssertTrue(audioPlayer is MockAudioPlayer)
    }

    func testContainer_SingletonLifetime() {
        // Given
        let container = Container()
        container.registerSingleton(AudioPlayerProtocol.self) {
            MockAudioPlayer()
        }

        // When
        let instance1 = container.resolve(AudioPlayerProtocol.self)
        let instance2 = container.resolve(AudioPlayerProtocol.self)

        // Then
        XCTAssertIdentical(instance1 as? MockAudioPlayer, instance2 as? MockAudioPlayer)
    }

    func testContainer_TransientLifetime() {
        // Given
        let container = Container()
        container.register(AudioPlayerProtocol.self) {
            MockAudioPlayer()
        }

        // When
        let instance1 = container.resolve(AudioPlayerProtocol.self)
        let instance2 = container.resolve(AudioPlayerProtocol.self)

        // Then
        XCTAssertNotIdentical(instance1 as? MockAudioPlayer, instance2 as? MockAudioPlayer)
    }

    func testContainer_UnregisteredServiceThrowsFatalError() {
        // Given
        let container = Container()

        // When/Then
        XCTAssertThrowsError(try {
            _ = container.resolve(AudioPlayerProtocol.self)
        }())
    }
}

// MARK: - Linux Support

extension PlayerViewModelTests {
    static var allTests: [(String, (PlayerViewModelTests) -> () throws -> Void)] {
        [
            ("testViewModelInitializesWithInjectedDependencies", testViewModelInitializesWithInjectedDependencies),
            ("testChangeStation_UpdatesSelectedStation", testChangeStation_UpdatesSelectedStation),
            ("testIsPlaying_DelegatesToAudioPlayer", testIsPlaying_DelegatesToAudioPlayer),
            ("testVolume_GetterDelegatesToAudioPlayer", testVolume_GetterDelegatesToAudioPlayer),
            ("testContainer_RegistersAndResolvesServices", testContainer_RegistersAndResolvesServices),
            ("testContainer_SingletonLifetime", testContainer_SingletonLifetime),
        ]
    }
}
