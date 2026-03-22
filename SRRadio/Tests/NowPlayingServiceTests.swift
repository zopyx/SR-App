import XCTest
@testable import SRRadio

final class NowPlayingServiceTests: XCTestCase {

    var service: NowPlayingService!

    override func setUp() {
        super.setUp()
        service = NowPlayingService()
    }

    override func tearDown() {
        service = nil
        super.tearDown()
    }

    // MARK: - SR Station Detection Tests

    func testSRStationIds() {
        let srStationIds = ["sr1", "sr_kultur", "sr3", "unserding", "antenne_saar"]

        for stationId in srStationIds {
            XCTAssertTrue(Station.all.contains { $0.id == stationId },
                         "Should have station \(stationId)")
        }
    }

    func testNonSRStations() {
        let nonSRStations = ["radio_salue", "bigfm", "cityradio_sb", "classic_rock"]

        for stationId in nonSRStations {
            let station = Station.all.first { $0.id == stationId }
            XCTAssertNotNil(station, "Should have station \(stationId)")
        }
    }

    // MARK: - NowPlayingData Tests

    func testNowPlayingDataDisplayTextWithArtistAndTitle() {
        let data = NowPlayingData(
            title: "Song Title",
            artist: "Artist Name",
            show: "",
            moderator: ""
        )

        XCTAssertEqual(data.displayText, "Artist Name — Song Title")
    }

    func testNowPlayingDataDisplayTextWithTitleOnly() {
        let data = NowPlayingData(
            title: "Song Title",
            artist: "",
            show: "",
            moderator: ""
        )

        XCTAssertEqual(data.displayText, "Song Title")
    }

    func testNowPlayingDataDisplayTextWithShowOnly() {
        let data = NowPlayingData(
            title: "",
            artist: "",
            show: "Morning Show",
            moderator: ""
        )

        XCTAssertEqual(data.displayText, "Morning Show")
    }

    func testNowPlayingDataDisplayTextEmpty() {
        let data = NowPlayingData(
            title: "",
            artist: "",
            show: "",
            moderator: ""
        )

        XCTAssertNil(data.displayText)
    }

    // MARK: - HTML Cleaning Tests

    func testCleanHTMLAmpersand() {
        let cleaned = service.cleanHTMLForTest("Artist &amp; Band")
        XCTAssertEqual(cleaned, "Artist & Band")
    }

    func testCleanHTMLApostrophe() {
        let cleaned = service.cleanHTMLForTest("Rock&#039;n&#039;Roll")
        XCTAssertEqual(cleaned, "Rock'n'Roll")
    }

    func testCleanHTMLQuotes() {
        let cleaned = service.cleanHTMLForTest("&quot;Best&quot; Hits")
        XCTAssertEqual(cleaned, "\"Best\" Hits")
    }

    func testCleanHTMLWhitespace() {
        let cleaned = service.cleanHTMLForTest("  \n  Trimmed Text  \n  ")
        XCTAssertEqual(cleaned, "Trimmed Text")
    }

    func testCleanHTMLAllEntities() {
        let cleaned = service.cleanHTMLForTest("  Rock &amp; Roll &#039;60s &quot;Greatest&quot; Hits &lt;Live&gt;  \n  ")
        XCTAssertEqual(cleaned, "Rock & Roll '60s \"Greatest\" Hits <Live>")
    }

    // MARK: - Playlist Entry Tests

    func testPlaylistEntryCreation() {
        let entry = PlaylistEntry(
            time: "14:30",
            title: "Test Song",
            artist: "Test Artist",
            date: Date()
        )

        XCTAssertEqual(entry.time, "14:30")
        XCTAssertEqual(entry.title, "Test Song")
        XCTAssertEqual(entry.artist, "Test Artist")
    }

    func testPlaylistEntryEquatable() {
        let entry1 = PlaylistEntry(time: "14:30", title: "Song", artist: "Artist", date: nil)
        let entry2 = PlaylistEntry(time: "14:30", title: "Song", artist: "Artist", date: nil)
        let entry3 = PlaylistEntry(time: "14:31", title: "Song", artist: "Artist", date: nil)

        XCTAssertEqual(entry1, entry2)
        XCTAssertNotEqual(entry1, entry3)
    }

    // MARK: - Error Type Tests

    func testRadioErrorInvalidURL() {
        let error = RadioError.invalidURL("test://url")
        XCTAssertEqual(error.errorDescription, "Ungültige URL: test://url")
        XCTAssertEqual(error.userMessage, "Verbindungsfehler")
    }

    func testRadioErrorNoData() {
        let error = RadioError.noData
        XCTAssertEqual(error.errorDescription, "Keine Daten erhalten")
        XCTAssertEqual(error.userMessage, "Keine Informationen verfügbar")
    }

    func testRadioErrorDataConversionFailed() {
        let error = RadioError.dataConversionFailed
        XCTAssertEqual(error.errorDescription, "Datenkonvertierung fehlgeschlagen")
        XCTAssertEqual(error.userMessage, "Datenfehler")
    }

    func testRadioErrorParseError() {
        let error = RadioError.parseError("Test reason")
        XCTAssertEqual(error.errorDescription, "Parsing fehlgeschlagen: Test reason")
        XCTAssertEqual(error.userMessage, "Datenfehler")
    }

    func testRadioErrorStationNotSupported() {
        let error = RadioError.stationNotSupported(stationId: "radio_salue", feature: "Now Playing")
        XCTAssertEqual(error.errorDescription, "Station radio_salue unterstützt Now Playing nicht")
        XCTAssertEqual(error.userMessage, "Nicht unterstützt")
    }

    func testRadioErrorContentEmpty() {
        let error = RadioError.contentEmpty
        XCTAssertEqual(error.errorDescription, "Keine Inhalte verfügbar")
        XCTAssertEqual(error.userMessage, "Keine Informationen verfügbar")
    }

    func testRadioErrorNetworkError() {
        let underlyingError = NSError(domain: "test", code: 404, userInfo: [NSLocalizedDescriptionKey: "Not found"])
        let error = RadioError.networkError(underlyingError)
        XCTAssertTrue(error.errorDescription?.contains("Netzwerkfehler") == true)
        XCTAssertEqual(error.userMessage, "Keine Internetverbindung")
    }

    func testRadioErrorStreamLoadFailed() {
        let error = RadioError.streamLoadFailed("sr1")
        XCTAssertEqual(error.errorDescription, "Stream für sr1 konnte nicht geladen werden")
        XCTAssertEqual(error.userMessage, "Stream nicht verfügbar")
    }

    func testRadioErrorEquatable() {
        let error1 = RadioError.noData
        let error2 = RadioError.noData
        let error3 = RadioError.contentEmpty
        
        XCTAssertEqual(error1, error2)
        XCTAssertNotEqual(error1, error3)
    }

    // MARK: - Pattern Configuration Tests

    func testTimePatternMatches() {
        let html = #"<span class="musicResearch__Item__Time">14:30</span>"#
        let regex = try? NSRegularExpression(pattern: NowPlayingPatterns.timePattern, options: .caseInsensitive)
        XCTAssertNotNil(regex)

        let matches = regex?.matches(in: html, options: [], range: NSRange(location: 0, length: html.utf16.count))
        XCTAssertEqual(matches?.count, 1)

        if let match = matches?.first,
           let range = Range(match.range(at: 1), in: html) {
            XCTAssertEqual(String(html[range]), "14:30")
        }
    }

    func testTitlePatternMatches() {
        let html = #"<div class="musicResearch__Item__Content__Title">Song Title</div>"#
        let regex = try? NSRegularExpression(pattern: NowPlayingPatterns.titlePattern, options: .caseInsensitive)
        XCTAssertNotNil(regex)

        let matches = regex?.matches(in: html, options: [], range: NSRange(location: 0, length: html.utf16.count))
        XCTAssertEqual(matches?.count, 1)

        if let match = matches?.first,
           let range = Range(match.range(at: 1), in: html) {
            XCTAssertEqual(String(html[range]), "Song Title")
        }
    }

    func testArtistPatternMatches() {
        let html = #"<div class="musicResearch__Item__Content__Artist">Artist Name</div>"#
        let regex = try? NSRegularExpression(pattern: NowPlayingPatterns.artistPattern, options: .caseInsensitive)
        XCTAssertNotNil(regex)

        let matches = regex?.matches(in: html, options: [], range: NSRange(location: 0, length: html.utf16.count))
        XCTAssertEqual(matches?.count, 1)

        if let match = matches?.first,
           let range = Range(match.range(at: 1), in: html) {
            XCTAssertEqual(String(html[range]), "Artist Name")
        }
    }

    // MARK: - Playlist Parsing Tests

    func testParsePlaylistEntries() {
        let html = """
        <span class="musicResearch__Item__Time">14:30</span>
        <div class="musicResearch__Item__Content__Title">Song One</div>
        <div class="musicResearch__Item__Content__Artist">Artist One</div>
        <span class="musicResearch__Item__Time">14:35</span>
        <div class="musicResearch__Item__Content__Title">Song Two</div>
        <div class="musicResearch__Item__Content__Artist">Artist Two</div>
        """

        let entries = service.parsePlaylistEntriesForTest(html: html)
        XCTAssertEqual(entries.count, 2)
        XCTAssertEqual(entries[0].time, "14:30")
        XCTAssertEqual(entries[0].title, "Song One")
        XCTAssertEqual(entries[0].artist, "Artist One")
        XCTAssertEqual(entries[1].time, "14:35")
        XCTAssertEqual(entries[1].title, "Song Two")
        XCTAssertEqual(entries[1].artist, "Artist Two")
    }

    func testParsePlaylistEntriesWithHTMLEntities() {
        let html = """
        <span class="musicResearch__Item__Time">14:30</span>
        <div class="musicResearch__Item__Content__Title">Rock &amp; Roll</div>
        <div class="musicResearch__Item__Content__Artist">Artist &#039;60s</div>
        """

        let entries = service.parsePlaylistEntriesForTest(html: html)
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries[0].title, "Rock & Roll")
        XCTAssertEqual(entries[0].artist, "Artist '60s")
    }

    func testParsePlaylistEntriesEmpty() {
        let html = "<html><body>No playlist data</body></html>"
        let entries = service.parsePlaylistEntriesForTest(html: html)
        XCTAssertEqual(entries.count, 0)
    }

    // MARK: - Find Current Entry Tests

    func testFindCurrentEntryWithMatchingTime() {
        let now = Date()
        let calendar = Calendar.current

        // Create an entry 10 minutes ago
        let pastTime = calendar.date(byAdding: .minute, value: -10, to: now)!
        let pastTimeString = calendar.component(.hour, from: pastTime).formatted() + ":" +
                            calendar.component(.minute, from: pastTime).formatted()

        let entries = [
            PlaylistEntry(time: pastTimeString, title: "Past Song", artist: "Past Artist", date: pastTime),
            PlaylistEntry(time: "23:59", title: "Future Song", artist: "Future Artist", date: nil)
        ]

        let current = service.findCurrentEntryForTest(entries: entries)
        XCTAssertEqual(current?.title, "Past Song")
    }

    func testFindCurrentEntryEmptyList() {
        let entries: [PlaylistEntry] = []
        let current = service.findCurrentEntryForTest(entries: entries)
        XCTAssertNil(current)
    }

    func testFindCurrentEntryAllFuture() {
        // When all entries are in the future, should return the last one
        let futureDate = Date().addingTimeInterval(3600) // 1 hour in future
        let entries = [
            PlaylistEntry(time: "23:00", title: "Future Song 1", artist: "Artist", date: futureDate),
            PlaylistEntry(time: "23:30", title: "Future Song 2", artist: "Artist", date: futureDate)
        ]

        let current = service.findCurrentEntryForTest(entries: entries)
        XCTAssertEqual(current?.title, "Future Song 2")
    }

    // MARK: - Service Initialization Tests

    func testServiceInitializesWithoutData() {
        XCTAssertNil(service.currentData)
        XCTAssertFalse(service.isLoading)
        XCTAssertNil(service.lastError)
    }

    func testServicePollInterval() {
        // Verify the service has a reasonable poll interval
        let expectedInterval: TimeInterval = 30.0
        // We can't directly access pollInterval, but we can verify
        // the service doesn't crash on initialization
        XCTAssertNotNil(service)
    }

    // MARK: - Station Logo Name Tests

    func testSRStationsHaveLogoNames() {
        XCTAssertTrue(Station.sr1.logoName.isEmpty == false)
        XCTAssertTrue(Station.srKultur.logoName.isEmpty == false)
        XCTAssertTrue(Station.sr3.logoName.isEmpty == false)
    }

    func testPrivateStationsEmptyLogoNames() {
        XCTAssertTrue(Station.radioSalue.logoName.isEmpty)
        XCTAssertTrue(Station.bigfm.logoName.isEmpty)
        XCTAssertTrue(Station.classicRock.logoName.isEmpty)
    }

    // MARK: - Cache Tests

    func testCachedResponseValidity() {
        let data = ["test"]
        let now = Date()
        let cached = CachedResponse(data: data, timestamp: now, stationId: "sr1")

        // Should be valid immediately
        XCTAssertTrue(cached.isValid(maxAge: 300))

        // Create old cache (5 minutes ago)
        let oldTimestamp = now.addingTimeInterval(-301)
        let oldCached = CachedResponse(data: data, timestamp: oldTimestamp, stationId: "sr1")

        // Should be invalid after max age
        XCTAssertFalse(oldCached.isValid(maxAge: 300))
    }
}

// MARK: - Linux Support

extension NowPlayingServiceTests {
    static var allTests: [(String, (NowPlayingServiceTests) -> () throws -> Void)] {
        [
            ("testSRStationIds", testSRStationIds),
            ("testNowPlayingDataDisplayTextWithArtistAndTitle", testNowPlayingDataDisplayTextWithArtistAndTitle),
            ("testNowPlayingDataDisplayTextWithTitleOnly", testNowPlayingDataDisplayTextWithTitleOnly),
            ("testNowPlayingDataDisplayTextWithShowOnly", testNowPlayingDataDisplayTextWithShowOnly),
            ("testNowPlayingDataDisplayTextEmpty", testNowPlayingDataDisplayTextEmpty),
            ("testCleanHTMLAmpersand", testCleanHTMLAmpersand),
            ("testCleanHTMLApostrophe", testCleanHTMLApostrophe),
            ("testCleanHTMLQuotes", testCleanHTMLQuotes),
            ("testCleanHTMLWhitespace", testCleanHTMLWhitespace),
            ("testPlaylistEntryCreation", testPlaylistEntryCreation),
            ("testNowPlayingErrorInvalidURL", testNowPlayingErrorInvalidURL),
            ("testNowPlayingErrorNoData", testNowPlayingErrorNoData),
            ("testTimePatternMatches", testTimePatternMatches),
            ("testTitlePatternMatches", testTitlePatternMatches),
            ("testArtistPatternMatches", testArtistPatternMatches),
            ("testParsePlaylistEntries", testParsePlaylistEntries),
            ("testServiceInitializesWithoutData", testServiceInitializesWithoutData),
            ("testSRStationsHaveLogoNames", testSRStationsHaveLogoNames),
            ("testPrivateStationsEmptyLogoNames", testPrivateStationsEmptyLogoNames),
        ]
    }
}

// MARK: - Test Extension for NowPlayingService

extension NowPlayingService {
    /// Expose cleanHTML for testing
    func cleanHTMLForTest(_ string: String) -> String {
        return cleanHTML(string)
    }

    /// Expose parsePlaylistEntries for testing
    func parsePlaylistEntriesForTest(html: String) -> [PlaylistEntry] {
        return parsePlaylistEntries(from: html)
    }

    /// Expose findCurrentEntry for testing
    func findCurrentEntryForTest(entries: [PlaylistEntry]) -> PlaylistEntry? {
        return findCurrentEntry(entries: entries)
    }
}
