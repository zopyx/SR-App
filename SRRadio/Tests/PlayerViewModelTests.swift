import XCTest
@testable import SRRadio

/// Tests for PlayerViewModel dependency injection pattern.
final class PlayerViewModelTests: XCTestCase {

    var mockAudioPlayer: MockAudioPlayer!
    var mockNowPlayingService: MockNowPlayingService!

    override func setUp() {
        super.setUp()
        mockAudioPlayer = MockAudioPlayer()
        mockNowPlayingService = MockNowPlayingService()
    }

    override func tearDown() {
        mockAudioPlayer = nil
        mockNowPlayingService = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testViewModelInitializesWithInjectedDependencies() {
        // Given
        let viewModel = PlayerViewModel(
            audioPlayer: mockAudioPlayer,
            nowPlayingService: mockNowPlayingService
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
    }

    // MARK: - Station Change Tests

    func testChangeStation_UpdatesSelectedStation() {
        // Given
        let viewModel = PlayerViewModel(
            audioPlayer: mockAudioPlayer,
            nowPlayingService: mockNowPlayingService
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
            nowPlayingService: mockNowPlayingService
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
            nowPlayingService: mockNowPlayingService
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
            nowPlayingService: mockNowPlayingService
        )

        // When
        mockAudioPlayer.state = .playing
        viewModel.onPlaybackStateChange() // Sync state from audio player

        // Then
        XCTAssertTrue(viewModel.isPlaying)
    }

    func testIsBuffering_DelegatesToAudioPlayer() {
        // Given
        let viewModel = PlayerViewModel(
            audioPlayer: mockAudioPlayer,
            nowPlayingService: mockNowPlayingService
        )

        // When
        mockAudioPlayer.state = .buffering
        viewModel.onPlaybackStateChange() // Sync state from audio player

        // Then
        XCTAssertTrue(viewModel.isBuffering)
    }

    func testIsMutedState_DelegatesToAudioPlayer() {
        // Given
        let viewModel = PlayerViewModel(
            audioPlayer: mockAudioPlayer,
            nowPlayingService: mockNowPlayingService
        )

        // When
        mockAudioPlayer.state = .muted(isPlaying: true)
        viewModel.onPlaybackStateChange() // Sync state from audio player

        // Then
        XCTAssertTrue(viewModel.isMutedState)
    }

    func testVolume_GetterDelegatesToAudioPlayer() {
        // Given
        let viewModel = PlayerViewModel(
            audioPlayer: mockAudioPlayer,
            nowPlayingService: mockNowPlayingService
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
            nowPlayingService: mockNowPlayingService
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
            nowPlayingService: mockNowPlayingService
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
            nowPlayingService: mockNowPlayingService
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
            nowPlayingService: mockNowPlayingService
        )
        mockAudioPlayer.state = .error("Test error")
        viewModel.onPlaybackStateChange() // Sync state from audio player

        // When
        let errorMessage = viewModel.errorMessage

        // Then
        XCTAssertEqual(errorMessage, "Test error")
    }

    func testDismissError_ClearsUserErrorMessage() {
        // Given
        let viewModel = PlayerViewModel(
            audioPlayer: mockAudioPlayer,
            nowPlayingService: mockNowPlayingService
        )
        viewModel.userErrorMessage = "Test error"

        // When
        viewModel.dismissError()

        // Then
        XCTAssertNil(viewModel.userErrorMessage)
        XCTAssertTrue(mockAudioPlayer.retryAfterErrorCalled)
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
    
    // MARK: - App Startup Tests
    
    /// Test that verifies the app can start up without crashing.
    func testAppStartup_DoesNotCrash() throws {
        // Given
        let container = Container()

        // When - Register all default services (this is what happens at app launch)
        container.registerDefaultServices()

        // Then - Should be able to resolve all services without crashing
        let audioPlayer = container.resolveAudioPlayer()
        XCTAssertNotNil(audioPlayer, "AudioPlayer should resolve without crashing")

        let nowPlayingService = container.resolveNowPlayingService()
        XCTAssertNotNil(nowPlayingService, "NowPlayingService should resolve without crashing")
    }
    
    /// Test that PlayerViewModel can be initialized with default dependencies (simulating app launch).
    func testPlayerViewModel_InitWithDefaultDependencies_DoesNotCrash() throws {
        // Given
        Container.shared.registerDefaultServices()

        // When - Create ViewModel as happens during app launch
        let viewModel = PlayerViewModel()

        // Then - Should initialize without crashing
        XCTAssertNotNil(viewModel, "PlayerViewModel should initialize without crashing")
        XCTAssertNotNil(viewModel.audioPlayer, "AudioPlayer should be injected")
        XCTAssertNotNil(viewModel.nowPlayingService, "NowPlayingService should be injected")
    }

    // MARK: - Computed Property Tests

    func testIsPlaying_DelegatesToPlayerState() {
        let viewModel = PlayerViewModel(
            audioPlayer: mockAudioPlayer,
            nowPlayingService: mockNowPlayingService
        )
        mockAudioPlayer.state = .playing
        viewModel.onPlaybackStateChange()

        XCTAssertTrue(viewModel.isPlaying)
    }

    func testIsBuffering_DelegatesToPlayerState() {
        let viewModel = PlayerViewModel(
            audioPlayer: mockAudioPlayer,
            nowPlayingService: mockNowPlayingService
        )
        mockAudioPlayer.state = .buffering
        viewModel.onPlaybackStateChange()

        XCTAssertTrue(viewModel.isBuffering)
    }

    func testIsMutedState_DelegatesToPlayerState() {
        let viewModel = PlayerViewModel(
            audioPlayer: mockAudioPlayer,
            nowPlayingService: mockNowPlayingService
        )
        mockAudioPlayer.state = .muted(isPlaying: true)
        viewModel.onPlaybackStateChange()

        XCTAssertTrue(viewModel.isMutedState)
    }

    func testErrorMessage_ExtractsFromPlayerState() {
        let viewModel = PlayerViewModel(
            audioPlayer: mockAudioPlayer,
            nowPlayingService: mockNowPlayingService
        )
        mockAudioPlayer.state = .error("Test error message")
        viewModel.onPlaybackStateChange()

        XCTAssertEqual(viewModel.errorMessage, "Test error message")
    }

    func testErrorMessage_WhenNoError() {
        let viewModel = PlayerViewModel(
            audioPlayer: mockAudioPlayer,
            nowPlayingService: mockNowPlayingService
        )
        mockAudioPlayer.state = .playing
        viewModel.onPlaybackStateChange()

        XCTAssertNil(viewModel.errorMessage)
    }

    func testCurrentRadioError_DelegatesToAudioPlayer() {
        let viewModel = PlayerViewModel(
            audioPlayer: mockAudioPlayer,
            nowPlayingService: mockNowPlayingService
        )
        mockAudioPlayer.currentError = .noData

        XCTAssertEqual(viewModel.currentRadioError, .noData)
    }

    func testCurrentRadioError_WhenNil() {
        let viewModel = PlayerViewModel(
            audioPlayer: mockAudioPlayer,
            nowPlayingService: mockNowPlayingService
        )

        XCTAssertNil(viewModel.currentRadioError)
    }

    // MARK: - UI State Tests

    func testShowStationSelector_Toggle() {
        let viewModel = PlayerViewModel(
            audioPlayer: mockAudioPlayer,
            nowPlayingService: mockNowPlayingService
        )
        XCTAssertFalse(viewModel.showStationSelector)
        viewModel.showStationSelector = true
        XCTAssertTrue(viewModel.showStationSelector)
    }

    func testShowAbout_Toggle() {
        let viewModel = PlayerViewModel(
            audioPlayer: mockAudioPlayer,
            nowPlayingService: mockNowPlayingService
        )
        XCTAssertFalse(viewModel.showAbout)
        viewModel.showAbout = true
        XCTAssertTrue(viewModel.showAbout)
    }

    func testShowSettings_Toggle() {
        let viewModel = PlayerViewModel(
            audioPlayer: mockAudioPlayer,
            nowPlayingService: mockNowPlayingService
        )
        XCTAssertFalse(viewModel.showSettings)
        viewModel.showSettings = true
        XCTAssertTrue(viewModel.showSettings)
    }

    func testIsHoveringLogo_Toggle() {
        let viewModel = PlayerViewModel(
            audioPlayer: mockAudioPlayer,
            nowPlayingService: mockNowPlayingService
        )
        XCTAssertFalse(viewModel.isHoveringLogo)
        viewModel.isHoveringLogo = true
        XCTAssertTrue(viewModel.isHoveringLogo)
    }

    // MARK: - Action Method Tests

    func testOpenAbout_SetsShowAboutTrue() {
        let viewModel = PlayerViewModel(
            audioPlayer: mockAudioPlayer,
            nowPlayingService: mockNowPlayingService
        )
        viewModel.openAbout()
        XCTAssertTrue(viewModel.showAbout)
    }

    func testOpenSettings_SetsShowSettingsTrue() {
        let viewModel = PlayerViewModel(
            audioPlayer: mockAudioPlayer,
            nowPlayingService: mockNowPlayingService
        )
        viewModel.openSettings()
        XCTAssertTrue(viewModel.showSettings)
    }

    func testDismissError_ClearsUserErrorMessage() {
        let viewModel = PlayerViewModel(
            audioPlayer: mockAudioPlayer,
            nowPlayingService: mockNowPlayingService
        )
        viewModel.userErrorMessage = "Test error"
        viewModel.dismissError()

        XCTAssertNil(viewModel.userErrorMessage)
        XCTAssertTrue(mockAudioPlayer.retryAfterErrorCalled)
    }

    func testOnViewAppear_LoadsStationAndStartsMonitoring() {
        let viewModel = PlayerViewModel(
            audioPlayer: mockAudioPlayer,
            nowPlayingService: mockNowPlayingService
        )
        let initialStation = viewModel.selectedStation

        viewModel.onViewAppear()

        XCTAssertTrue(mockAudioPlayer.loadStationCalled)
        XCTAssertEqual(mockAudioPlayer.loadStationCalledWith, initialStation)
        XCTAssertTrue(mockAudioPlayer.loadStationAutoPlay)
        XCTAssertTrue(mockNowPlayingService.startMonitoringCalled)
        XCTAssertEqual(mockNowPlayingService.startMonitoringCalledWith, initialStation)
    }

    func testOnPlaybackStateChange_SyncsState() {
        let viewModel = PlayerViewModel(
            audioPlayer: mockAudioPlayer,
            nowPlayingService: mockNowPlayingService
        )
        mockAudioPlayer.state = .playing

        viewModel.onPlaybackStateChange()

        XCTAssertEqual(viewModel.playerState, .playing)
    }

    // MARK: - Station Persistence Tests

    func testChangeStation_SavesLastPlayed() {
        UserDefaults.standard.removeObject(forKey: "lastPlayedStationId")

        let viewModel = PlayerViewModel(
            audioPlayer: mockAudioPlayer,
            nowPlayingService: mockNowPlayingService
        )
        viewModel.changeStation(to: .sr3)

        XCTAssertEqual(Station.lastPlayed.id, Station.sr3.id)

        // Clean up
        UserDefaults.standard.removeObject(forKey: "lastPlayedStationId")
    }

    func testViewModelInitializesWithLastPlayedStation() {
        UserDefaults.standard.removeObject(forKey: "lastPlayedStationId")
        Station.saveLastPlayed(.sr3)

        let viewModel = PlayerViewModel(
            audioPlayer: mockAudioPlayer,
            nowPlayingService: mockNowPlayingService
        )

        XCTAssertEqual(viewModel.selectedStation.id, Station.sr3.id)

        // Clean up
        UserDefaults.standard.removeObject(forKey: "lastPlayedStationId")
    }

    // MARK: - Error Handling Edge Cases

    func testChangeStation_ClearsUserErrorMessage() {
        let viewModel = PlayerViewModel(
            audioPlayer: mockAudioPlayer,
            nowPlayingService: mockNowPlayingService
        )
        viewModel.userErrorMessage = "Previous error"

        viewModel.changeStation(to: .sr1)

        XCTAssertNil(viewModel.userErrorMessage)
    }

    func testUserErrorMessage_Published() {
        let viewModel = PlayerViewModel(
            audioPlayer: mockAudioPlayer,
            nowPlayingService: mockNowPlayingService
        )

        let expectation = XCTestExpectation(description: "Error message published")
        viewModel.$userErrorMessage
            .dropFirst()
            .sink { message in
                XCTAssertEqual(message, "Verbindungsfehler")
                expectation.fulfill()
            }
            .store(in: &viewModel.cancellables)

        mockAudioPlayer.currentError = .invalidURL("test://url")

        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - Volume and Mute Tests

    func testVolume_SetterUpdatesAudioPlayer() {
        let viewModel = PlayerViewModel(
            audioPlayer: mockAudioPlayer,
            nowPlayingService: mockNowPlayingService
        )
        viewModel.volume = 0.5

        XCTAssertEqual(mockAudioPlayer.volume, 0.5, accuracy: 0.01)
    }

    func testIsMuted_SetterTogglesAudioPlayer() {
        let viewModel = PlayerViewModel(
            audioPlayer: mockAudioPlayer,
            nowPlayingService: mockNowPlayingService
        )
        viewModel.isMuted = true

        XCTAssertTrue(mockAudioPlayer.toggleMuteCalled)
    }

    func testIsMuted_SetterNoOpWhenSameValue() {
        let viewModel = PlayerViewModel(
            audioPlayer: mockAudioPlayer,
            nowPlayingService: mockNowPlayingService
        )
        // Initial isMuted is false, setting to false should not call toggle
        viewModel.isMuted = false

        XCTAssertFalse(mockAudioPlayer.toggleMuteCalled)
    }

    // MARK: - Cancellables Tests

    func testCancellables_IsNotEmpty_AfterSetup() {
        let viewModel = PlayerViewModel(
            audioPlayer: mockAudioPlayer,
            nowPlayingService: mockNowPlayingService
        )

        // Should have subscriptions for state and error observation
        XCTAssertFalse(viewModel.cancellables.isEmpty)
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
            ("testAppStartup_DoesNotCrash", testAppStartup_DoesNotCrash),
            ("testPlayerViewModel_InitWithDefaultDependencies_DoesNotCrash", testPlayerViewModel_InitWithDefaultDependencies_DoesNotCrash),
            ("testIsPlaying_DelegatesToPlayerState", testIsPlaying_DelegatesToPlayerState),
            ("testIsBuffering_DelegatesToPlayerState", testIsBuffering_DelegatesToPlayerState),
            ("testErrorMessage_ExtractsFromPlayerState", testErrorMessage_ExtractsFromPlayerState),
            ("testOpenAbout_SetsShowAboutTrue", testOpenAbout_SetsShowAboutTrue),
            ("testDismissError_ClearsUserErrorMessage", testDismissError_ClearsUserErrorMessage),
            ("testChangeStation_SavesLastPlayed", testChangeStation_SavesLastPlayed),
            ("testVolume_SetterUpdatesAudioPlayer", testVolume_SetterUpdatesAudioPlayer),
        ]
    }
}
