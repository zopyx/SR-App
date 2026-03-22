import SwiftUI
import UIKit

// MARK: - Screenshot Generator Configuration

enum ScreenshotGenerator {
    /// Target resolution for App Store screenshots (iPhone 8 Plus / XS Max @3x)
    /// Exact pixel dimensions required by Apple App Store
    static let targetSize = CGSize(width: 1242, height: 2688)

    /// Output directory name in documents
    static let outputDirectoryName = "AppStoreScreenshots"
}

// MARK: - Main Screenshot Capture Function

extension ScreenshotGenerator {
    /// Captures a screenshot of any SwiftUI view at exact target resolution (1242×2688)
    /// - Parameters:
    ///   - view: The SwiftUI view to capture
    ///   - name: Filename (without extension)
    static func capture<Content: View>(
        view: Content,
        name: String
    ) {
        // Use exact target size (no scaling needed)
        let hostingController = UIHostingController(rootView: view)
        let window = UIWindow(frame: CGRect(origin: .zero, size: targetSize))
        window.rootViewController = hostingController
        window.makeKeyAndVisible()

        // Force layout at full resolution
        hostingController.view.frame = window.bounds
        hostingController.view.layoutIfNeeded()

        // Render at 1x scale (already at target resolution)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0
        format.opaque = false
        format.preferredRange = .standard

        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
        let image = renderer.image { context in
            window.layer.render(in: context.cgContext)
        }

        // Save image with exact dimensions in filename
        saveImage(image, name: name)
    }
    
    /// Saves the captured image to the documents directory
    private static func saveImage(_ image: UIImage, name: String) {
        guard let data = image.pngData() else {
            print("❌ Failed to convert image to PNG: \(name)")
            return
        }

        let width = Int(image.size.width)
        let height = Int(image.size.height)
        let filename = "\(name)_\(width)x\(height).png"

        // Get documents directory
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let screenshotsDir = documentsPath.appendingPathComponent(outputDirectoryName)

        // Create directory if needed
        try? FileManager.default.createDirectory(at: screenshotsDir, withIntermediateDirectories: true)

        let filePath = screenshotsDir.appendingPathComponent(filename)

        do {
            try data.write(to: filePath)
            print("✅ Screenshot saved: \(filename)")
            print("   Size: \(width) × \(height) pixels")
            print("   Path: \(filePath.path)")
        } catch {
            print("❌ Failed to save screenshot '\(filename)': \(error)")
        }
    }
    
    /// Captures all App Store screenshots
    static func captureAll() {
        print("\n📸 Generating App Store Screenshots...")
        print("   Target size: \(Int(targetSize.width)) × \(Int(targetSize.height)) pixels\n")
        
        // Create output directory
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let screenshotsDir = documentsPath.appendingPathComponent(outputDirectoryName)
        try? FileManager.default.createDirectory(at: screenshotsDir, withIntermediateDirectories: true)
        
        // Capture each screen
        captureMainScreen()
        captureAboutScreen()
        captureSettingsScreen()
        
        print("\n✅ All screenshots generated in: \(screenshotsDir.path)")
    }
    
    // MARK: - Individual Screen Captures
    
    static func captureMainScreen() {
        let view = MainScreenScreenshotView()
        capture(view: view, name: "01_MainScreen")
    }
    
    static func captureAboutScreen() {
        let view = AboutScreenScreenshotView()
        capture(view: view, name: "02_AboutScreen")
    }
    
    static func captureSettingsScreen() {
        let view = SettingsScreenScreenshotView()
        capture(view: view, name: "03_SettingsScreen")
    }
}

// MARK: - Screenshot Preview Views

/// Main Player Screen Screenshot
struct MainScreenScreenshotView: View {
    @State private var selectedStation: Station = .sr1
    
    var body: some View {
        ZStack {
            DynamicBackground(color: selectedStation.color)
            
            VStack(spacing: 0) {
                // Top Bar
                HStack {
                    Image(systemName: "gear")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.95))
                        .frame(width: 32, height: 32)
                        .background(Color.black.opacity(0.35))
                        .clipShape(Circle())
                    
                    Spacer()
                    
                    // Station selector
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
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.95))
                        .frame(width: 32, height: 32)
                        .background(Color.black.opacity(0.35))
                        .clipShape(Circle())
                }
                .padding(.horizontal, 22)
                .padding(.top, 20)
                
                Spacer()
                
                // Station Logo with glow
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                        )
                        .shadow(color: selectedStation.color.opacity(0.5), radius: 30, x: 0, y: 15)
                        .shadow(color: Color.black.opacity(0.4), radius: 15, x: 0, y: 8)
                    
                    StationLogo(station: selectedStation, size: 170)
                    
                    // Equalizer animation (frozen frame)
                    VStack {
                        Spacer()
                        HStack(spacing: 4) {
                            ForEach(0..<5) { i in
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.white)
                                    .frame(width: 5, height: CGFloat([12, 20, 28, 18, 24][i]))
                            }
                        }
                        .padding(.bottom, 24)
                    }
                }
                .frame(width: 240, height: 240)
                .padding(.vertical, 20)
                
                // Station name and track info
                VStack(spacing: 10) {
                    Text(selectedStation.name)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: Color.black.opacity(0.3), radius: 3, y: 2)
                    
                    Text("ABBA — Dancing Queen")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.white.opacity(0.85))
                }
                .frame(height: 90)
                
                Spacer()
                
                // Volume & Status
                VStack(spacing: 14) {
                    // Volume slider
                    HStack(spacing: 14) {
                        Image(systemName: "speaker.fill")
                            .foregroundColor(.white.opacity(0.6))
                            .font(.system(size: 16))
                        
                        // Slider track
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.white.opacity(0.25))
                                .frame(height: 5)
                            
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.white)
                                .frame(width: 220, height: 5)
                        }
                        .frame(maxWidth: .infinity)
                        
                        Image(systemName: "speaker.wave.3.fill")
                            .foregroundColor(.white.opacity(0.6))
                            .font(.system(size: 16))
                    }
                    .padding(.horizontal, 24)
                    
                    // Live indicator
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                        Text("LIVE")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .padding(.bottom, 6)
                    
                    Text("Saar Streams")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color.white.opacity(0.35))
                        .tracking(3)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 28)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// About Screen Screenshot
struct AboutScreenScreenshotView: View {
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color(hex: "#2ab3a6").opacity(0.25), Color.black],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Dialog container
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 10) {
                    // App Logo placeholder
                    ZStack {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(LinearGradient(
                                colors: [Color(hex: "#2ab3a6"), Color(hex: "#1a9386")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 88, height: 88)
                            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                        
                        Image(systemName: "radio")
                            .font(.system(size: 44, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .padding(.bottom, 6)
                    
                    Text("Saar Streams")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Version 1.0")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.6))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 28)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "#2ab3a6").opacity(0.15), Color.clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                // Content
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Current Station Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("AKTUELLER SENDER")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Color(hex: "#2ab3a6"))
                                .tracking(1)
                            
                            AboutRow(label: "Name", value: "SR 1")
                            AboutRow(label: "Beschreibung", value: "Saarlands beste Musik")
                            AboutRow(label: "Läuft gerade", value: "ABBA — Dancing Queen", highlight: true)
                        }
                        
                        Divider()
                            .background(Color.white.opacity(0.12))
                            .padding(.vertical, 8)
                        
                        // App Info Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("APP-INFORMATIONEN")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Color.white.opacity(0.5))
                                .tracking(1)
                            
                            AboutRow(label: "Version", value: "1.0.0")
                            AboutRow(label: "Plattformen", value: "iOS, iPadOS")
                            AboutRow(label: "Autor", value: "Andreas Jung")
                        }
                        
                        // Disclaimer
                        Text("Dies ist eine inoffizielle Drittanbieter-App.")
                            .font(.system(size: 11))
                            .foregroundColor(Color.white.opacity(0.4))
                            .padding(.top, 12)
                    }
                    .padding(.horizontal, 22)
                    .padding(.vertical, 20)
                }
                
                // Footer
                HStack(spacing: 6) {
                    Text("Mit")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.5))
                    Image(systemName: "heart.fill")
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "#e91e63"))
                    Text("für Radioliebhaber gemacht")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.5))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(Color.white.opacity(0.05))
            }
            .background(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(Color(white: 0.12, opacity: 0.92))
                    .overlay(
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 22)
            .padding(.vertical, 70)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// Settings Screen Screenshot
struct SettingsScreenScreenshotView: View {
    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()
            
            NavigationView {
                List {
                    Section(header: settingsSectionHeader("Startverhalten")) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Standard-Sender")
                                    .font(.system(size: 17))
                                    .foregroundColor(.primary)
                                Text("Der Sender, der beim Start automatisch geladen wird")
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(Color(hex: "#2ab3a6"))
                                    .frame(width: 12, height: 12)
                                Text("SR 1")
                                    .foregroundColor(.secondary)
                                Image(systemName: "chevron.up.chevron.down")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    
                    Section(header: settingsSectionHeader("Wiedergabe")) {
                        HStack {
                            Text("Automatische Wiedergabe")
                            Spacer()
                            Toggle("", isOn: .constant(true))
                                .labelsHidden()
                        }
                    }
                    
                    Section(header: settingsSectionHeader("Über")) {
                        HStack {
                            Text("Version")
                            Spacer()
                            Text("1.0.0")
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("Build")
                            Spacer()
                            Text("1")
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func settingsSectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(Color(UIColor.systemGray))
            .textCase(.none)
            .padding(.horizontal, 16)
            .padding(.bottom, 4)
    }
}

/// Helper view for About screen rows
struct AboutRow: View {
    let label: String
    let value: String
    var highlight: Bool = false
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(Color.white.opacity(0.6))
                .font(.system(size: 15))
            Spacer()
            Text(value)
                .foregroundColor(highlight ? Color(hex: "#2ab3a6") : .white)
                .font(.system(size: 15))
                .multilineTextAlignment(.trailing)
        }
    }
}

// MARK: - SwiftUI Previews for Manual Inspection

#if DEBUG
struct ScreenshotPreviews_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MainScreenScreenshotView()
                .previewDisplayName("Main Screen")
                .previewLayout(.fixed(width: 1242, height: 2688))

            AboutScreenScreenshotView()
                .previewDisplayName("About Screen")
                .previewLayout(.fixed(width: 1242, height: 2688))

            SettingsScreenScreenshotView()
                .previewDisplayName("Settings Screen")
                .previewLayout(.fixed(width: 1242, height: 2688))
        }
    }
}
#endif
