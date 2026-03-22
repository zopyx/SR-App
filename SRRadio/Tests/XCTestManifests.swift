import XCTest

/// XCTestManifests for test discovery
/// This file ensures all tests are discovered by the test runner

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(StationTests.allTests),
        testCase(ColorHexTests.allTests),
        testCase(NowPlayingServiceTests.allTests),
    ]
}
#endif
