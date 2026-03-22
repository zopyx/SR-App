import XCTest
@testable import SRRadio

final class RadioErrorTests: XCTestCase {

    // MARK: - Error Description Tests

    func testInvalidURLErrorDescription() {
        let error = RadioError.invalidURL("https://invalid-url")
        XCTAssertEqual(error.errorDescription, "Ungültige URL: https://invalid-url")
    }

    func testNetworkErrorDescription() {
        let underlyingError = NSError(domain: "test", code: -1009, userInfo: [NSLocalizedDescriptionKey: "No internet connection"])
        let error = RadioError.networkError(underlyingError)
        XCTAssertTrue(error.errorDescription?.contains("Netzwerkfehler") == true)
    }

    func testNoDataErrorDescription() {
        let error = RadioError.noData
        XCTAssertEqual(error.errorDescription, "Keine Daten erhalten")
    }

    func testStreamLoadFailedErrorDescription() {
        let error = RadioError.streamLoadFailed("sr1")
        XCTAssertEqual(error.errorDescription, "Stream für sr1 konnte nicht geladen werden")
    }

    func testStreamEndedUnexpectedlyErrorDescription() {
        let error = RadioError.streamEndedUnexpectedly
        XCTAssertEqual(error.errorDescription, "Stream unerwartet beendet")
    }

    func testParseErrorDescription() {
        let error = RadioError.parseError("Invalid JSON")
        XCTAssertEqual(error.errorDescription, "Parsing fehlgeschlagen: Invalid JSON")
    }

    func testDataConversionFailedErrorDescription() {
        let error = RadioError.dataConversionFailed
        XCTAssertEqual(error.errorDescription, "Datenkonvertierung fehlgeschlagen")
    }

    func testAudioSessionFailedErrorDescription() {
        let underlyingError = NSError(domain: "AVAudioSession", code: 561017908, userInfo: [NSLocalizedDescriptionKey: "Audio session not active"])
        let error = RadioError.audioSessionFailed(underlyingError)
        XCTAssertTrue(error.errorDescription?.contains("Audio-Session fehlgeschlagen") == true)
    }

    func testLiveActivityFailedErrorDescription() {
        let error = RadioError.liveActivityFailed("Activity request failed")
        XCTAssertEqual(error.errorDescription, "Live Activity fehlgeschlagen: Activity request failed")
    }

    func testLiveActivityNotAuthorizedErrorDescription() {
        let error = RadioError.liveActivityNotAuthorized
        XCTAssertEqual(error.errorDescription, "Live Activities sind nicht autorisiert")
    }

    func testStationNotSupportedErrorDescription() {
        let error = RadioError.stationNotSupported(stationId: "radio_salue", feature: "Now Playing")
        XCTAssertEqual(error.errorDescription, "Station radio_salue unterstützt Now Playing nicht")
    }

    func testContentEmptyErrorDescription() {
        let error = RadioError.contentEmpty
        XCTAssertEqual(error.errorDescription, "Keine Inhalte verfügbar")
    }

    // MARK: - User Message Tests

    func testInvalidURLUserMessage() {
        let error = RadioError.invalidURL("https://invalid-url")
        XCTAssertEqual(error.userMessage, "Verbindungsfehler")
    }

    func testNetworkErrorUserMessage() {
        let error = RadioError.networkError(NSError(domain: "test", code: 0, userInfo: nil))
        XCTAssertEqual(error.userMessage, "Keine Internetverbindung")
    }

    func testNoDataUserMessage() {
        let error = RadioError.noData
        XCTAssertEqual(error.userMessage, "Keine Informationen verfügbar")
    }

    func testStreamLoadFailedUserMessage() {
        let error = RadioError.streamLoadFailed("sr1")
        XCTAssertEqual(error.userMessage, "Stream nicht verfügbar")
    }

    func testStreamEndedUnexpectedlyUserMessage() {
        let error = RadioError.streamEndedUnexpectedly
        XCTAssertEqual(error.userMessage, "Stream nicht verfügbar")
    }

    func testParseErrorUserMessage() {
        let error = RadioError.parseError("reason")
        XCTAssertEqual(error.userMessage, "Datenfehler")
    }

    func testDataConversionFailedUserMessage() {
        let error = RadioError.dataConversionFailed
        XCTAssertEqual(error.userMessage, "Datenfehler")
    }

    func testAudioSessionFailedUserMessage() {
        let error = RadioError.audioSessionFailed(NSError(domain: "test", code: 0, userInfo: nil))
        XCTAssertEqual(error.userMessage, "Audio-Fehler")
    }

    func testLiveActivityFailedUserMessage() {
        let error = RadioError.liveActivityFailed("reason")
        XCTAssertEqual(error.userMessage, "Live Activity nicht verfügbar")
    }

    func testLiveActivityNotAuthorizedUserMessage() {
        let error = RadioError.liveActivityNotAuthorized
        XCTAssertEqual(error.userMessage, "Live Activity nicht verfügbar")
    }

    func testStationNotSupportedUserMessage() {
        let error = RadioError.stationNotSupported(stationId: "radio_salue", feature: "Now Playing")
        XCTAssertEqual(error.userMessage, "Nicht unterstützt")
    }

    func testContentEmptyUserMessage() {
        let error = RadioError.contentEmpty
        XCTAssertEqual(error.userMessage, "Keine Informationen verfügbar")
    }

    // MARK: - Equatable Tests

    func testInvalidURLEquality() {
        let error1 = RadioError.invalidURL("url1")
        let error2 = RadioError.invalidURL("url1")
        let error3 = RadioError.invalidURL("url2")

        XCTAssertEqual(error1, error2)
        XCTAssertNotEqual(error1, error3)
    }

    func testNetworkErrorEquality() {
        let error1 = RadioError.networkError(NSError(domain: "test", code: 0, userInfo: nil))
        let error2 = RadioError.networkError(NSError(domain: "test", code: 0, userInfo: nil))

        XCTAssertEqual(error1, error2)
    }

    func testNoDataEquality() {
        let error1 = RadioError.noData
        let error2 = RadioError.noData

        XCTAssertEqual(error1, error2)
    }

    func testStreamLoadFailedEquality() {
        let error1 = RadioError.streamLoadFailed("sr1")
        let error2 = RadioError.streamLoadFailed("sr1")
        let error3 = RadioError.streamLoadFailed("sr3")

        XCTAssertEqual(error1, error2)
        XCTAssertNotEqual(error1, error3)
    }

    func testParseErrorEquality() {
        let error1 = RadioError.parseError("reason1")
        let error2 = RadioError.parseError("reason1")
        let error3 = RadioError.parseError("reason2")

        XCTAssertEqual(error1, error2)
        XCTAssertNotEqual(error1, error3)
    }

    func testDifferentErrorTypesNotEqual() {
        let error1 = RadioError.noData
        let error2 = RadioError.contentEmpty

        XCTAssertNotEqual(error1, error2)
    }

    // MARK: - Error Conversion Tests

    func testErrorFromRadioError() {
        let originalError = RadioError.noData
        let converted = RadioError.from(originalError)
        XCTAssertEqual(converted, originalError)
    }

    func testErrorFromGenericError() {
        let genericError = NSError(domain: "test", code: 404, userInfo: [NSLocalizedDescriptionKey: "Not found"])
        let converted = RadioError.from(genericError)

        if case .networkError = converted {
            // Success
        } else {
            XCTFail("Expected networkError")
        }
    }

    // MARK: - Debug Description Tests

    func testDebugDescription() {
        let error = RadioError.invalidURL("https://test.com")
        XCTAssertTrue(error.debugDescription.hasPrefix("[RadioError]"))
    }
}

// MARK: - Linux Support

extension RadioErrorTests {
    static var allTests: [(String, (RadioErrorTests) -> () throws -> Void)] {
        [
            ("testInvalidURLErrorDescription", testInvalidURLErrorDescription),
            ("testNoDataErrorDescription", testNoDataErrorDescription),
            ("testInvalidURLUserMessage", testInvalidURLUserMessage),
            ("testNoDataUserMessage", testNoDataUserMessage),
            ("testInvalidURLEquality", testInvalidURLEquality),
            ("testNoDataEquality", testNoDataEquality),
            ("testErrorFromRadioError", testErrorFromRadioError),
        ]
    }
}
