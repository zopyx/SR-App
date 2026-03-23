import XCTest
@testable import SRRadio

/// Comprehensive tests for Analytics tracking.
final class AnalyticsTests: XCTestCase {

    // MARK: - Event Creation Tests

    func testStationChangeEvent() {
        let event: Analytics.Event = .stationChange(stationId: "sr1", stationName: "SR 1")
        
        if case .stationChange(let stationId, let stationName) = event {
            XCTAssertEqual(stationId, "sr1")
            XCTAssertEqual(stationName, "SR 1")
        } else {
            XCTFail("Expected stationChange event")
        }
    }

    func testPlaybackStartEvent() {
        let event: Analytics.Event = .playbackStart(stationId: "sr3")
        
        if case .playbackStart(let stationId) = event {
            XCTAssertEqual(stationId, "sr3")
        } else {
            XCTFail("Expected playbackStart event")
        }
    }

    func testPlaybackErrorEvent() {
        let event: Analytics.Event = .playbackError(stationId: "radio_salue", error: "Stream not available")
        
        if case .playbackError(let stationId, let error) = event {
            XCTAssertEqual(stationId, "radio_salue")
            XCTAssertEqual(error, "Stream not available")
        } else {
            XCTFail("Expected playbackError event")
        }
    }

    func testAppOpenEvent() {
        let event: Analytics.Event = .appOpen
        
        if case .appOpen = event {
            // Success
        } else {
            XCTFail("Expected appOpen event")
        }
    }

    func testAboutViewOpenEvent() {
        let event: Analytics.Event = .aboutViewOpen
        
        if case .aboutViewOpen = event {
            // Success
        } else {
            XCTFail("Expected aboutViewOpen event")
        }
    }

    func testSettingsOpenEvent() {
        let event: Analytics.Event = .settingsOpen
        
        if case .settingsOpen = event {
            // Success
        } else {
            XCTFail("Expected settingsOpen event")
        }
    }

    func testStationSearchEvent() {
        let event: Analytics.Event = .stationSearch(query: "SR")
        
        if case .stationSearch(let query) = event {
            XCTAssertEqual(query, "SR")
        } else {
            XCTFail("Expected stationSearch event")
        }
    }

    func testLiveActivityStartEvent() {
        let event: Analytics.Event = .liveActivityStart(stationId: "sr1")
        
        if case .liveActivityStart(let stationId) = event {
            XCTAssertEqual(stationId, "sr1")
        } else {
            XCTFail("Expected liveActivityStart event")
        }
    }

    // MARK: - Track Method Tests

    func testTrack_StationChange() {
        // This test verifies track doesn't crash
        // Actual output is printed in DEBUG builds
        Analytics.track(.stationChange(stationId: "sr1", stationName: "SR 1"))
    }

    func testTrack_PlaybackStart() {
        Analytics.track(.playbackStart(stationId: "sr3"))
    }

    func testTrack_PlaybackError() {
        Analytics.track(.playbackError(stationId: "bigfm", error: "Network error"))
    }

    func testTrack_AppOpen() {
        Analytics.track(.appOpen)
    }

    func testTrack_AboutViewOpen() {
        Analytics.track(.aboutViewOpen)
    }

    func testTrack_SettingsOpen() {
        Analytics.track(.settingsOpen)
    }

    func testTrack_StationSearch() {
        Analytics.track(.stationSearch(query: "CityRadio"))
    }

    func testTrack_LiveActivityStart() {
        Analytics.track(.liveActivityStart(stationId: "sr_kultur"))
    }

    // MARK: - Record App Launch Tests

    func testRecordAppLaunch() {
        // This test verifies the method doesn't crash
        Analytics.recordAppLaunch()
    }

    // MARK: - Event Equatability Tests

    func testStationChangeEventEquality() {
        let event1: Analytics.Event = .stationChange(stationId: "sr1", stationName: "SR 1")
        let event2: Analytics.Event = .stationChange(stationId: "sr1", stationName: "SR 1")
        let event3: Analytics.Event = .stationChange(stationId: "sr3", stationName: "SR 3")

        // Note: Analytics.Event doesn't conform to Equatable, so we test via pattern matching
        if case .stationChange(let id1, _) = event1,
           case .stationChange(let id2, _) = event2,
           case .stationChange(let id3, _) = event3 {
            XCTAssertEqual(id1, id2)
            XCTAssertNotEqual(id1, id3)
        }
    }

    func testPlaybackErrorEventEquality() {
        let error1: Analytics.Event = .playbackError(stationId: "sr1", error: "Error 1")
        let error2: Analytics.Event = .playbackError(stationId: "sr1", error: "Error 1")
        let error3: Analytics.Event = .playbackError(stationId: "sr1", error: "Error 2")

        if case .playbackError(_, let err1) = error1,
           case .playbackError(_, let err2) = error2,
           case .playbackError(_, let err3) = error3 {
            XCTAssertEqual(err1, err2)
            XCTAssertNotEqual(err1, err3)
        }
    }

    // MARK: - Station Integration Tests

    func testTrackWithRealStations() {
        for station in Station.all {
            Analytics.track(.stationChange(stationId: station.id, stationName: station.name))
            Analytics.track(.playbackStart(stationId: station.id))
        }
    }

    func testTrackAllEventTypes() {
        // Test that all event types can be tracked without crashing
        let events: [Analytics.Event] = [
            .stationChange(stationId: "sr1", stationName: "SR 1"),
            .playbackStart(stationId: "sr1"),
            .playbackError(stationId: "sr1", error: "Test error"),
            .appOpen,
            .aboutViewOpen,
            .settingsOpen,
            .stationSearch(query: "Test"),
            .liveActivityStart(stationId: "sr1")
        ]

        for event in events {
            Analytics.track(event)
        }
    }

    // MARK: - Multiple Tracking Tests

    func testTrackMultipleTimes() {
        // Verify tracking can be called multiple times
        for _ in 0..<10 {
            Analytics.track(.appOpen)
        }
    }

    func testTrackRapidSuccession() {
        // Test rapid event tracking
        Analytics.track(.appOpen)
        Analytics.track(.stationChange(stationId: "sr1", stationName: "SR 1"))
        Analytics.track(.playbackStart(stationId: "sr1"))
        Analytics.track(.aboutViewOpen)
        Analytics.track(.settingsOpen)
    }

    // MARK: - Edge Case Tests

    func testTrackWithEmptyStationId() {
        Analytics.track(.stationChange(stationId: "", stationName: "Empty"))
        Analytics.track(.playbackStart(stationId: ""))
        Analytics.track(.playbackError(stationId: "", error: "Error"))
    }

    func testTrackWithLongStationName() {
        let longName = String(repeating: "A", count: 1000)
        Analytics.track(.stationChange(stationId: "sr1", stationName: longName))
    }

    func testTrackWithSpecialCharacters() {
        Analytics.track(.stationSearch(query: "SR & Kultur"))
        Analytics.track(.playbackError(stationId: "sr1", error: "Error: \"Failed\""))
    }

    func testTrackWithUnicodeCharacters() {
        Analytics.track(.stationChange(stationId: "radio_salue", stationName: "Radio Salü"))
        Analytics.track(.stationSearch(query: "🎵"))
    }

    // MARK: - Performance Tests

    func testTrackPerformance() {
        measure {
            for _ in 0..<100 {
                Analytics.track(.appOpen)
            }
        }
    }

    func testTrackStationChangePerformance() {
        let stations = Station.all
        measure {
            for station in stations {
                Analytics.track(.stationChange(stationId: station.id, stationName: station.name))
            }
        }
    }
}

// MARK: - Linux Support

extension AnalyticsTests {
    static var allTests: [(String, (AnalyticsTests) -> () throws -> Void)] {
        [
            ("testStationChangeEvent", testStationChangeEvent),
            ("testPlaybackStartEvent", testPlaybackStartEvent),
            ("testPlaybackErrorEvent", testPlaybackErrorEvent),
            ("testAppOpenEvent", testAppOpenEvent),
            ("testAboutViewOpenEvent", testAboutViewOpenEvent),
            ("testSettingsOpenEvent", testSettingsOpenEvent),
            ("testStationSearchEvent", testStationSearchEvent),
            ("testLiveActivityStartEvent", testLiveActivityStartEvent),
            ("testTrack_StationChange", testTrack_StationChange),
            ("testTrack_PlaybackStart", testTrack_PlaybackStart),
            ("testRecordAppLaunch", testRecordAppLaunch),
            ("testTrackAllEventTypes", testTrackAllEventTypes),
        ]
    }
}
