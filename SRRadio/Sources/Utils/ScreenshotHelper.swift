import SwiftUI
import UIKit

// MARK: - Screenshot Generator
// Run on iPhone 11 Pro Max simulator (1242 × 2688 points at 3x = 414 × 896 points)

struct ScreenshotHelper {
    
    static let screenshotSize = CGSize(width: 414, height: 896) // iPhone 11 Pro Max logical size
    
    /// Captures a screenshot of a SwiftUI view and saves it to the simulator's documents directory
    static func capture<Content: View>(
        view: Content,
        name: String,
        size: CGSize = screenshotSize,
        scale: CGFloat = 3.0
    ) {
        let controller = UIHostingController(rootView: view)
        let window = UIWindow(frame: CGRect(origin: .zero, size: size))
        window.rootViewController = controller
        window.makeKeyAndVisible()
        
        // Layout the view
        controller.view.frame = window.bounds
        controller.view.layoutIfNeeded()
        
        // Capture with specified scale
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        format.opaque = false
        
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        let image = renderer.image { context in
            window.layer.render(in: context.cgContext)
        }
        
        // Save to documents directory
        if let data = image.pngData() {
            let filename = "\(name)_\(Int(size.width * scale))x\(Int(size.height * scale)).png"
            let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent(filename)
            
            do {
                try data.write(to: path)
                print("✅ Screenshot saved: \(path.path)")
            } catch {
                print("❌ Failed to save screenshot: \(error)")
            }
        }
    }
}

// MARK: - Preview Helpers for Screenshots

#if DEBUG
struct ScreenshotPreviews: PreviewProvider {
    
    static var previews: some View {
        Group {
            // Main Player Screen
            PlayerViewScreenshot()
                .previewDisplayName("Main Screen")
                .previewLayout(.fixed(width: 414, height: 896))
            
            // About Screen
            AboutViewScreenshot()
                .previewDisplayName("About Screen")
                .previewLayout(.fixed(width: 414, height: 896))
            
            // Settings Screen
            SettingsViewScreenshot()
                .previewDisplayName("Settings Screen")
                .previewLayout(.fixed(width: 414, height: 896))
        }
    }
}

// MARK: - Screenshot Wrapper Views

struct PlayerViewScreenshot: View {
    @StateObject private var audioPlayer = AudioPlayer()
    @StateObject private var nowPlayingService = NowPlayingService()
    @State private var selectedStation: Station = .sr1
    @State private var showStationSelector = false
    @State private var showAbout = false
    @State private var showSettings = false
    @State private var isHoveringLogo = false
    
    var body: some View {
        ZStack {
            DynamicBackground(color: selectedStation.color)
            
            VStack(spacing: 0) {
                // Simplified top bar for screenshot
                HStack {
                    Image(systemName: "gear")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.95))
                        .frame(width: 28, height: 28)
                        .background(Color.black.opacity(0.35))
                        .clipShape(Circle())
                    
                    Spacer()
                    
                    // Station selector button
                    HStack(spacing: 8) {
                        Circle()
                            .fill(selectedStation.color)
                            .frame(width: 10, height: 10)
                        
                        Text(selectedStation.shortName)
                            .font(.system(size: 16, weight: .bold))
                        
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.35))
                    )
                    
                    Spacer()
                    
                    Image(systemName: "info.circle")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.95))
                        .frame(width: 28, height: 28)
                        .background(Color.black.opacity(0.35))
                        .clipShape(Circle())
                }
                .padding(.horizontal, 22)
                .padding(.top, 16)
                
                Spacer()
                
                // Station logo
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                        )
                        .shadow(color: selectedStation.color.opacity(0.4), radius: 24, x: 0, y: 10)
                    
                    StationLogo(station: selectedStation, size: 170)
                    
                    // Playing indicator
                    VStack {
                        Spacer()
                        HStack(spacing: 3) {
                            ForEach(0..<4) { i in
                                RoundedRectangle(cornerRadius: 1.5)
                                    .fill(Color.white)
                                    .frame(width: 4, height: CGFloat.random(in: 8...24))
                                    .animation(
                                        Animation.easeInOut(duration: 0.4)
                                            .repeatForever(autoreverses: true)
                                            .delay(Double(i) * 0.1),
                                        value: true
                                    )
                            }
                        }
                        .padding(.bottom, 20)
                    }
                }
                .frame(width: 240, height: 240)
                .padding(.vertical, 16)
                
                // Track info
                VStack(spacing: 8) {
                    Text(selectedStation.name)
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("ABBA - Dancing Queen")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.8))
                }
                .frame(height: 90)
                
                Spacer()
                
                // Volume & status
                VStack(spacing: 12) {
                    // Volume slider mock
                    HStack(spacing: 12) {
                        Image(systemName: "speaker.fill")
                            .foregroundColor(.white.opacity(0.6))
                        
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.white.opacity(0.3))
                            .frame(height: 4)
                            .overlay(
                                HStack {
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(Color.white)
                                        .frame(width: 200, height: 4)
                                    Spacer()
                                }
                            )
                        
                        Image(systemName: "speaker.wave.3.fill")
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .padding(.horizontal, 20)
                    
                    // Status
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                        Text("LIVE")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .padding(.bottom, 4)
                    
                    Text("Saar Streams")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color.white.opacity(0.3))
                        .tracking(2)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct AboutViewScreenshot: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "#2ab3a6").opacity(0.3), Color.black],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .ignoresSafeArea()
            
            // Dialog
            VStack(spacing: 0) {
                // Header with logo
                VStack(spacing: 8) {
                    Image("app_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                        .padding(.bottom, 4)
                    
                    Text("Saar Streams")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Version 1.0")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.6))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "#2ab3a6").opacity(0.15), Color.clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                // Content
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        // Current station section
                        VStack(alignment: .leading, spacing: 10) {
                            Text("AKTUELLER SENDER")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Color(hex: "#2ab3a6"))
                                .tracking(0.5)
                            
                            HStack {
                                Text("Name")
                                    .foregroundColor(.white.opacity(0.6))
                                Spacer()
                                Text("SR 1")
                                    .foregroundColor(.white)
                            }
                            
                            HStack {
                                Text("Beschreibung")
                                    .foregroundColor(.white.opacity(0.6))
                                Spacer()
                                Text("Saarlands beste Musik")
                                    .foregroundColor(.white)
                            }
                            
                            HStack {
                                Text("Läuft gerade")
                                    .foregroundColor(.white.opacity(0.6))
                                Spacer()
                                Text("ABBA - Dancing Queen")
                                    .foregroundColor(Color(hex: "#2ab3a6"))
                            }
                        }
                        
                        Divider().background(Color.white.opacity(0.1))
                        
                        // App info section
                        VStack(alignment: .leading, spacing: 10) {
                            Text("APP-INFORMATIONEN")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white.opacity(0.5))
                                .tracking(0.5)
                            
                            HStack {
                                Text("Version")
                                    .foregroundColor(.white.opacity(0.6))
                                Spacer()
                                Text("1.0.0")
                                    .foregroundColor(.white)
                            }
                            
                            HStack {
                                Text("Plattformen")
                                    .foregroundColor(.white.opacity(0.6))
                                Spacer()
                                Text("iOS, iPadOS")
                                    .foregroundColor(.white)
                            }
                            
                            HStack {
                                Text("Autor")
                                    .foregroundColor(.white.opacity(0.6))
                                Spacer()
                                Text("Andreas Jung")
                                    .foregroundColor(.white)
                            }
                        }
                        
                        Text("Dies ist eine inoffizielle Drittanbieter-App.")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.4))
                            .padding(.top, 10)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
                
                // Footer
                Text("Mit ♥ für Radioliebhaber gemacht")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.5))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.white.opacity(0.05))
            }
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color(white: 0.1, opacity: 0.9))
            )
            .padding(.horizontal, 20)
            .padding(.vertical, 60)
        }
    }
}

struct SettingsViewScreenshot: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Startverhalten")) {
                    HStack {
                        Text("Standard-Sender")
                        Spacer()
                        Text("SR 1")
                            .foregroundColor(.secondary)
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Einstellungen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Text("Fertig")
                        .foregroundColor(.blue)
                }
            }
        }
    }
}

#endif
