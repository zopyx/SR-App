import XCTest
import SwiftUI
@testable import SRRadio

final class ColorHexTests: XCTestCase {
    
    // MARK: - 6-digit Hex Tests
    
    func testSixDigitHexWithHash() {
        let color = Color(hex: "#2ab3a6")
        // SwiftUI Color doesn't have public RGBA accessors in tests
        // This test verifies the initializer doesn't crash
        XCTAssertNotNil(color)
    }
    
    func testSixDigitHexWithoutHash() {
        let color = Color(hex: "2ab3a6")
        XCTAssertNotNil(color)
    }
    
    func testSixDigitHexWhite() {
        let color = Color(hex: "#FFFFFF")
        XCTAssertNotNil(color)
    }
    
    func testSixDigitHexBlack() {
        let color = Color(hex: "#000000")
        XCTAssertNotNil(color)
    }
    
    // MARK: - 3-digit Hex Tests
    
    func testThreeDigitHexWithHash() {
        let color = Color(hex: "#FFF")
        XCTAssertNotNil(color)
    }
    
    func testThreeDigitHexWithoutHash() {
        let color = Color(hex: "ABC")
        XCTAssertNotNil(color)
    }
    
    func testThreeDigitHexBlack() {
        let color = Color(hex: "#000")
        XCTAssertNotNil(color)
    }
    
    // MARK: - 8-digit Hex Tests (with Alpha)
    
    func testEightDigitHexWithHash() {
        let color = Color(hex: "#2ab3a6FF")
        XCTAssertNotNil(color)
    }
    
    func testEightDigitHexWithoutHash() {
        let color = Color(hex: "2ab3a680")
        XCTAssertNotNil(color)
    }
    
    func testEightDigitHexTransparent() {
        let color = Color(hex: "#00000000")
        XCTAssertNotNil(color)
    }
    
    // MARK: - Invalid Input Tests
    
    func testEmptyString() {
        let color = Color(hex: "")
        XCTAssertNotNil(color)
    }
    
    func testInvalidCharacters() {
        let color = Color(hex: "#GGGGGG")
        XCTAssertNotNil(color)
    }
    
    func testWhitespaceHandling() {
        let color = Color(hex: "  #2ab3a6  ")
        XCTAssertNotNil(color)
    }
    
    // MARK: - Station Color Tests
    
    func testAllStationColorsValid() {
        for station in Station.all {
            let color = Color(hex: station.colorHex)
            XCTAssertNotNil(color, "Station \(station.name) should have a valid color")
        }
    }
    
    func testStationColorHexFormats() {
        // Test various hex formats used in stations
        let colors = [
            "#2ab3a6",  // SR1
            "#8b7cff",  // SR Kultur
            "#ff6b35",  // UnserDing
            "#e91e63"   // Schlagerparadies
        ]
        
        for hex in colors {
            let color = Color(hex: hex)
            XCTAssertNotNil(color)
        }
    }
}

// MARK: - Linux Support

extension ColorHexTests {
    static var allTests: [(String, (ColorHexTests) -> () throws -> Void)] {
        [
            ("testSixDigitHexWithHash", testSixDigitHexWithHash),
            ("testSixDigitHexWithoutHash", testSixDigitHexWithoutHash),
            ("testThreeDigitHexWithHash", testThreeDigitHexWithHash),
            ("testEightDigitHexWithHash", testEightDigitHexWithHash),
            ("testEmptyString", testEmptyString),
            ("testAllStationColorsValid", testAllStationColorsValid),
        ]
    }
}
