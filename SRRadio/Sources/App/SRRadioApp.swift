import SwiftUI

@main
struct SRRadioApp: App {
    init() {
        // Set up dependency injection container once at app launch
        Container.shared.registerDefaultServices()
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
