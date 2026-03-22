import XCTest
@testable import SRRadio

final class StationTests: XCTestCase {
    
    // MARK: - Station Count Tests
    
    func testAllStationsCount() {
        XCTAssertEqual(Station.all.count, 15, "Should have 15 radio stations")
    }
    
    func testAllStationsUniqueIds() {
        let ids = Station.all.map { $0.id }
        let uniqueIds = Set(ids)
        XCTAssertEqual(ids.count, uniqueIds.count, "All station IDs should be unique")
    }
    
    // MARK: - Station Properties Tests
    
    func testStationHasRequiredProperties() {
        let station = Station.sr1
        XCTAssertFalse(station.name.isEmpty)
        XCTAssertFalse(station.shortName.isEmpty)
        XCTAssertFalse(station.description.isEmpty)
        XCTAssertNotNil(station.streamUrl)
        XCTAssertNotNil(station.website)
    }
    
    func testStationColorHex() {
        let station = Station.sr1
        XCTAssertEqual(station.colorHex, "#2ab3a6")
    }
    
    func testStationColorHexValues() {
        XCTAssertEqual(Station.srKultur.colorHex, "#8b7cff")
        XCTAssertEqual(Station.sr3.colorHex, "#44a1ff")
        XCTAssertEqual(Station.unserding.colorHex, "#ff6b35")
        XCTAssertEqual(Station.antenneSaar.colorHex, "#e4002b")
    }
    
    // MARK: - Logo Tests
    
    func testSRStationsHaveLogos() {
        XCTAssertTrue(Station.sr1.hasLogo)
        XCTAssertTrue(Station.srKultur.hasLogo)
        XCTAssertTrue(Station.sr3.hasLogo)
    }
    
    func testPrivateStationsNoLogos() {
        XCTAssertFalse(Station.radioSalue.hasLogo)
        XCTAssertFalse(Station.bigfm.hasLogo)
        XCTAssertFalse(Station.cityradioSB.hasLogo)
    }
    
    // MARK: - Default Station Persistence Tests
    
    func testDefaultStationIdDefaultValue() {
        // Clean up before test
        UserDefaults.standard.removeObject(forKey: "defaultStationId")
        
        XCTAssertEqual(Station.defaultStationId, Station.default.id)
    }
    
    func testSaveAndRetrieveDefaultStation() {
        let testStation = Station.sr3
        Station.saveDefaultStation(id: testStation.id)
        
        XCTAssertEqual(Station.defaultStationId, testStation.id)
        
        // Clean up
        UserDefaults.standard.removeObject(forKey: "defaultStationId")
    }
    
    func testDefaultStationReturnsCorrectStation() {
        let testStation = Station.antenneSaar
        Station.saveDefaultStation(id: testStation.id)
        
        let retrieved = Station.defaultStation
        XCTAssertEqual(retrieved.id, testStation.id)
        
        // Clean up
        UserDefaults.standard.removeObject(forKey: "defaultStationId")
    }
    
    func testDefaultStationFallbackToDefault() {
        UserDefaults.standard.set("invalid_id", forKey: "defaultStationId")
        
        let retrieved = Station.defaultStation
        XCTAssertEqual(retrieved.id, Station.default.id)
        
        // Clean up
        UserDefaults.standard.removeObject(forKey: "defaultStationId")
    }
    
    // MARK: - Last Played Persistence Tests
    
    func testLastPlayedWithNoPreviousValue() {
        UserDefaults.standard.removeObject(forKey: "lastPlayedStationId")
        
        let lastPlayed = Station.lastPlayed
        XCTAssertEqual(lastPlayed.id, Station.default.id)
    }
    
    func testSaveAndRetrieveLastPlayed() {
        let testStation = Station.bigfm
        Station.saveLastPlayed(testStation)
        
        let lastPlayed = Station.lastPlayed
        XCTAssertEqual(lastPlayed.id, testStation.id)
        
        // Clean up
        UserDefaults.standard.removeObject(forKey: "lastPlayedStationId")
    }
    
    func testLastPlayedWithInvalidId() {
        UserDefaults.standard.set("invalid_station", forKey: "lastPlayedStationId")
        
        let lastPlayed = Station.lastPlayed
        XCTAssertEqual(lastPlayed.id, Station.default.id)
        
        // Clean up
        UserDefaults.standard.removeObject(forKey: "lastPlayedStationId")
    }
    
    // MARK: - Station Equatable Tests
    
    func testStationEquality() {
        let sr1a = Station.sr1
        let sr1b = Station.sr1
        
        XCTAssertEqual(sr1a, sr1b)
    }
    
    func testStationInequality() {
        XCTAssertNotEqual(Station.sr1, Station.sr3)
    }
    
    // MARK: - Stream URL Tests
    
    func testAllStationsHaveValidStreamURLs() {
        for station in Station.all {
            XCTAssertNotNil(URL(string: station.streamUrl.absoluteString), 
                          "Station \(station.name) should have a valid stream URL")
        }
    }
    
    func testAllStationsHaveValidWebsiteURLs() {
        for station in Station.all {
            XCTAssertNotNil(URL(string: station.website.absoluteString), 
                          "Station \(station.name) should have a valid website URL")
        }
    }
}

// MARK: - Linux Support

extension StationTests {
    static var allTests: [(String, (StationTests) -> () throws -> Void)] {
        [
            ("testAllStationsCount", testAllStationsCount),
            ("testAllStationsUniqueIds", testAllStationsUniqueIds),
            ("testStationHasRequiredProperties", testStationHasRequiredProperties),
            ("testStationColorHex", testStationColorHex),
            ("testSRStationsHaveLogos", testSRStationsHaveLogos),
            ("testPrivateStationsNoLogos", testPrivateStationsNoLogos),
            ("testDefaultStationIdDefaultValue", testDefaultStationIdDefaultValue),
            ("testSaveAndRetrieveDefaultStation", testSaveAndRetrieveDefaultStation),
            ("testLastPlayedWithNoPreviousValue", testLastPlayedWithNoPreviousValue),
            ("testSaveAndRetrieveLastPlayed", testSaveAndRetrieveLastPlayed),
            ("testStationEquality", testStationEquality),
        ]
    }
}
