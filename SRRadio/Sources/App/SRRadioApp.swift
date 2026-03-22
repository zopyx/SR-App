import SwiftUI

@main
struct SRRadioApp: App {
    /// The dependency injection container.
    /// Registered once at app launch and shared throughout the app lifecycle.
    private let container: Container
    
    init() {
        // Set up dependency injection container
        self.container = Container.shared
        self.container.registerDefaultServices()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

/// Content view that handles screenshot mode
struct ContentView: View {
    var body: some View {
        if CommandLine.arguments.contains("--generate-screenshots") {
            // In screenshot mode, show a blank view to avoid interference
            Color.black.ignoresSafeArea()
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        ScreenshotGenerator.captureAll()
                    }
                }
        } else {
            PlayerView()
        }
    }
}
