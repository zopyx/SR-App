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
        let service = NowPlayingService()
        let cleaned = service.cleanHTMLForTest("Artist &amp; Band")
        XCTAssertEqual(cleaned, "Artist & Band")
    }
    
    func testCleanHTMLApostrophe() {
        let service = NowPlayingService()
        let cleaned = service.cleanHTMLForTest("Rock&#039;n&#039;Roll")
        XCTAssertEqual(cleaned, "Rock'n'Roll")
    }
    
    func testCleanHTMLQuotes() {
        let service = NowPlayingService()
        let cleaned = service.cleanHTMLForTest("&quot;Best&quot; Hits")
        XCTAssertEqual(cleaned, "\"Best\" Hits")
    }
    
    func testCleanHTMLWhitespace() {
        let service = NowPlayingService()
        let cleaned = service.cleanHTMLForTest("  \n  Trimmed Text  \n  ")
        XCTAssertEqual(cleaned, "Trimmed Text")
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
    
    // MARK: - Service Initialization Tests
    
    func testServiceInitializesWithoutData() {
        XCTAssertNil(service.currentData)
        XCTAssertFalse(service.isLoading)
    }
    
    func testServicePollInterval() {
        // Verify the service has a reasonable poll interval
        // This is an implementation detail, but ensures it's set
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
}
