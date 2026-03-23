import XCTest
@testable import SRRadio

/// Comprehensive tests for PlayerState enum.
final class PlayerStateTests: XCTestCase {

    // MARK: - Initial State Tests

    func testStartedState() {
        let state: PlayerState = .started
        XCTAssertEqual(state, .started)
    }

    func testBufferingState() {
        let state: PlayerState = .buffering
        XCTAssertEqual(state, .buffering)
    }

    func testPlayingState() {
        let state: PlayerState = .playing
        XCTAssertEqual(state, .playing)
    }

    func testMutedState() {
        let state: PlayerState = .muted(isPlaying: true)
        if case .muted(let isPlaying) = state {
            XCTAssertTrue(isPlaying)
        } else {
            XCTFail("Expected muted state")
        }
    }

    func testErrorState() {
        let state: PlayerState = .error("Test error")
        if case .error(let message) = state {
            XCTAssertEqual(message, "Test error")
        } else {
            XCTFail("Expected error state")
        }
    }

    // MARK: - Equatable Tests

    func testStartedEquality() {
        XCTAssertEqual(PlayerState.started, PlayerState.started)
    }

    func testBufferingEquality() {
        XCTAssertEqual(PlayerState.buffering, PlayerState.buffering)
    }

    func testPlayingEquality() {
        XCTAssertEqual(PlayerState.playing, PlayerState.playing)
    }

    func testMutedEquality_samePlayingState() {
        XCTAssertEqual(
            PlayerState.muted(isPlaying: true),
            PlayerState.muted(isPlaying: true)
        )
        XCTAssertEqual(
            PlayerState.muted(isPlaying: false),
            PlayerState.muted(isPlaying: false)
        )
    }

    func testMutedInequality_differentPlayingState() {
        XCTAssertNotEqual(
            PlayerState.muted(isPlaying: true),
            PlayerState.muted(isPlaying: false)
        )
    }

    func testErrorEquality_sameMessage() {
        XCTAssertEqual(
            PlayerState.error("Same error"),
            PlayerState.error("Same error")
        )
    }

    func testErrorInequality_differentMessage() {
        XCTAssertNotEqual(
            PlayerState.error("Error 1"),
            PlayerState.error("Error 2")
        )
    }

    func testDifferentStatesNotEqual() {
        XCTAssertNotEqual(PlayerState.started, PlayerState.playing)
        XCTAssertNotEqual(PlayerState.buffering, PlayerState.playing)
        XCTAssertNotEqual(PlayerState.started, PlayerState.buffering)
        XCTAssertNotEqual(PlayerState.playing, PlayerState.muted(isPlaying: true))
        XCTAssertNotEqual(PlayerState.started, PlayerState.error("test"))
    }

    // MARK: - isPlaying Property Tests

    func testIsPlaying_playingState() {
        XCTAssertTrue(PlayerState.playing.isPlaying)
    }

    func testIsPlaying_mutedWhilePlaying() {
        XCTAssertTrue(PlayerState.muted(isPlaying: true).isPlaying)
    }

    func testIsPlaying_startedState() {
        XCTAssertFalse(PlayerState.started.isPlaying)
    }

    func testIsPlaying_bufferingState() {
        XCTAssertFalse(PlayerState.buffering.isPlaying)
    }

    func testIsPlaying_mutedWhileNotPlaying() {
        XCTAssertFalse(PlayerState.muted(isPlaying: false).isPlaying)
    }

    func testIsPlaying_errorState() {
        XCTAssertFalse(PlayerState.error("test").isPlaying)
    }

    // MARK: - isBuffering Property Tests

    func testIsBuffering_bufferingState() {
        XCTAssertTrue(PlayerState.buffering.isBuffering)
    }

    func testIsBuffering_startedState() {
        XCTAssertFalse(PlayerState.started.isBuffering)
    }

    func testIsBuffering_playingState() {
        XCTAssertFalse(PlayerState.playing.isBuffering)
    }

    func testIsBuffering_mutedState() {
        XCTAssertFalse(PlayerState.muted(isPlaying: true).isBuffering)
        XCTAssertFalse(PlayerState.muted(isPlaying: false).isBuffering)
    }

    func testIsBuffering_errorState() {
        XCTAssertFalse(PlayerState.error("test").isBuffering)
    }

    // MARK: - isMuted Property Tests

    func testIsMuted_mutedPlayingState() {
        XCTAssertTrue(PlayerState.muted(isPlaying: true).isMuted)
    }

    func testIsMuted_mutedNotPlayingState() {
        XCTAssertTrue(PlayerState.muted(isPlaying: false).isMuted)
    }

    func testIsMuted_startedState() {
        XCTAssertFalse(PlayerState.started.isMuted)
    }

    func testIsMuted_bufferingState() {
        XCTAssertFalse(PlayerState.buffering.isMuted)
    }

    func testIsMuted_playingState() {
        XCTAssertFalse(PlayerState.playing.isMuted)
    }

    func testIsMuted_errorState() {
        XCTAssertFalse(PlayerState.error("test").isMuted)
    }

    // MARK: - isError Property Tests

    func testIsError_errorState() {
        XCTAssertTrue(PlayerState.error("test").isError)
    }

    func testIsError_startedState() {
        XCTAssertFalse(PlayerState.started.isError)
    }

    func testIsError_bufferingState() {
        XCTAssertFalse(PlayerState.buffering.isError)
    }

    func testIsError_playingState() {
        XCTAssertFalse(PlayerState.playing.isError)
    }

    func testIsError_mutedState() {
        XCTAssertFalse(PlayerState.muted(isPlaying: true).isError)
        XCTAssertFalse(PlayerState.muted(isPlaying: false).isError)
    }

    // MARK: - statusText Property Tests

    func testStatusText_started() {
        XCTAssertEqual(PlayerState.started.statusText, "BEREIT")
    }

    func testStatusText_buffering() {
        XCTAssertEqual(PlayerState.buffering.statusText, "PUFFERN")
    }

    func testStatusText_playing() {
        XCTAssertEqual(PlayerState.playing.statusText, "AUF SENDUNG")
    }

    func testStatusText_mutedPlaying() {
        XCTAssertEqual(PlayerState.muted(isPlaying: true).statusText, "STUMM")
    }

    func testStatusText_mutedNotPlaying() {
        XCTAssertEqual(PlayerState.muted(isPlaying: false).statusText, "PAUSIERT")
    }

    func testStatusText_error() {
        XCTAssertEqual(PlayerState.error("test").statusText, "FEHLER")
    }

    func testStatusText_errorWithGermanMessage() {
        XCTAssertEqual(PlayerState.error("Stream nicht verfügbar").statusText, "FEHLER")
    }

    // MARK: - indicatorIcon Property Tests

    func testIndicatorIcon_started() {
        XCTAssertEqual(PlayerState.started.indicatorIcon, "circle.fill")
    }

    func testIndicatorIcon_buffering() {
        XCTAssertEqual(PlayerState.buffering.indicatorIcon, "arrow.clockwise.circle.fill")
    }

    func testIndicatorIcon_playing() {
        XCTAssertEqual(PlayerState.playing.indicatorIcon, "waveform")
    }

    func testIndicatorIcon_muted() {
        XCTAssertEqual(PlayerState.muted(isPlaying: true).indicatorIcon, "speaker.slash.fill")
        XCTAssertEqual(PlayerState.muted(isPlaying: false).indicatorIcon, "speaker.slash.fill")
    }

    func testIndicatorIcon_error() {
        XCTAssertEqual(PlayerState.error("test").indicatorIcon, "exclamationmark.triangle.fill")
    }

    // MARK: - State Transition Tests

    func testStateTransition_startedToBuffering() {
        var state: PlayerState = .started
        state = .buffering
        XCTAssertEqual(state, .buffering)
        XCTAssertTrue(state.isBuffering)
    }

    func testStateTransition_bufferingToPlaying() {
        var state: PlayerState = .buffering
        state = .playing
        XCTAssertEqual(state, .playing)
        XCTAssertTrue(state.isPlaying)
    }

    func testStateTransition_playingToMuted() {
        var state: PlayerState = .playing
        state = .muted(isPlaying: true)
        XCTAssertEqual(state, .muted(isPlaying: true))
        XCTAssertTrue(state.isMuted)
        XCTAssertTrue(state.isPlaying)
    }

    func testStateTransition_playingToError() {
        var state: PlayerState = .playing
        state = .error("Stream error")
        XCTAssertEqual(state, .error("Stream error"))
        XCTAssertTrue(state.isError)
    }

    func testStateTransition_errorToStarted() {
        var state: PlayerState = .error("test")
        state = .started
        XCTAssertEqual(state, .started)
        XCTAssertFalse(state.isError)
    }

    // MARK: - Comprehensive State Matrix Tests

    func testAllStatesHaveCorrectIsPlayingValue() {
        let states: [PlayerState] = [
            .started, .buffering, .playing,
            .muted(isPlaying: true), .muted(isPlaying: false),
            .error("test")
        ]

        for state in states {
            switch state {
            case .playing, .muted(isPlaying: true):
                XCTAssertTrue(state.isPlaying, "\(state) should have isPlaying=true")
            default:
                XCTAssertFalse(state.isPlaying, "\(state) should have isPlaying=false")
            }
        }
    }

    func testAllStatesHaveCorrectIsBufferingValue() {
        let states: [PlayerState] = [
            .started, .buffering, .playing,
            .muted(isPlaying: true), .muted(isPlaying: false),
            .error("test")
        ]

        for state in states {
            switch state {
            case .buffering:
                XCTAssertTrue(state.isBuffering)
            default:
                XCTAssertFalse(state.isBuffering)
            }
        }
    }

    func testAllStatesHaveCorrectIsMutedValue() {
        let states: [PlayerState] = [
            .started, .buffering, .playing,
            .muted(isPlaying: true), .muted(isPlaying: false),
            .error("test")
        ]

        for state in states {
            switch state {
            case .muted:
                XCTAssertTrue(state.isMuted)
            default:
                XCTAssertFalse(state.isMuted)
            }
        }
    }

    func testAllStatesHaveCorrectIsErrorValue() {
        let states: [PlayerState] = [
            .started, .buffering, .playing,
            .muted(isPlaying: true), .muted(isPlaying: false),
            .error("test")
        ]

        for state in states {
            switch state {
            case .error:
                XCTAssertTrue(state.isError)
            default:
                XCTAssertFalse(state.isError)
            }
        }
    }

    // MARK: - Status Text German Language Tests

    func testAllStatusTextsAreInGerman() {
        let germanWords = ["BEREIT", "PUFFERN", "AUF SENDUNG", "STUMM", "PAUSIERT", "FEHLER"]
        let states: [PlayerState] = [
            .started, .buffering, .playing,
            .muted(isPlaying: true), .muted(isPlaying: false),
            .error("test")
        ]

        for (index, state) in states.enumerated() {
            XCTAssertTrue(
                germanWords.contains(state.statusText),
                "Status text '\(state.statusText)' should be in German"
            )
        }
    }
}

// MARK: - Linux Support

extension PlayerStateTests {
    static var allTests: [(String, (PlayerStateTests) -> () throws -> Void)] {
        [
            ("testStartedState", testStartedState),
            ("testStartedEquality", testStartedEquality),
            ("testIsPlaying_playingState", testIsPlaying_playingState),
            ("testIsBuffering_bufferingState", testIsBuffering_bufferingState),
            ("testIsMuted_mutedPlayingState", testIsMuted_mutedPlayingState),
            ("testIsError_errorState", testIsError_errorState),
            ("testStatusText_started", testStatusText_started),
            ("testStatusText_buffering", testStatusText_buffering),
            ("testStatusText_playing", testStatusText_playing),
            ("testStatusText_mutedPlaying", testStatusText_mutedPlaying),
            ("testStatusText_mutedNotPlaying", testStatusText_mutedNotPlaying),
            ("testStatusText_error", testStatusText_error),
            ("testIndicatorIcon_started", testIndicatorIcon_started),
            ("testIndicatorIcon_buffering", testIndicatorIcon_buffering),
            ("testIndicatorIcon_playing", testIndicatorIcon_playing),
            ("testIndicatorIcon_muted", testIndicatorIcon_muted),
            ("testIndicatorIcon_error", testIndicatorIcon_error),
            ("testAllStatesHaveCorrectIsPlayingValue", testAllStatesHaveCorrectIsPlayingValue),
        ]
    }
}
