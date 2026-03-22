import XCTest

// MARK: - Screenshot UI Tests
// Run on iPhone 11 Pro Max simulator (414 × 896 points @3x = 1242 × 2688 pixels)

class ScreenshotUITests: XCTestCase {
    
    let app = XCUIApplication()
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app.launch()
    }
    
    func testGenerateScreenshots() {
        let screenshotsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Screenshots")
        
        try? FileManager.default.createDirectory(at: screenshotsDir, withIntermediateDirectories: true)
        
        // Wait for app to fully load
        sleep(2)
        
        // 1. Main Screen Screenshot
        captureScreenshot(name: "01_MainScreen", to: screenshotsDir)
        
        // 2. Open About Screen
        app.buttons["info.circle"].tap()
        sleep(1)
        captureScreenshot(name: "02_AboutScreen", to: screenshotsDir)
        
        // Close About
        app.buttons["xmark"].tap()
        sleep(1)
        
        // 3. Open Settings Screen
        app.buttons["gear"].tap()
        sleep(1)
        captureScreenshot(name: "03_SettingsScreen", to: screenshotsDir)
        
        // Close Settings
        app.buttons["Fertig"].tap()
        
        print("Screenshots saved to: \(screenshotsDir.path)")
    }
    
    private func captureScreenshot(name: String, to directory: URL) {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
        
        // Save to documents
        let path = directory.appendingPathComponent("\(name).png")
        do {
            try screenshot.pngRepresentation.write(to: path)
            print("✅ Screenshot saved: \(path.path)")
        } catch {
            print("❌ Failed to save: \(error)")
        }
    }
}
