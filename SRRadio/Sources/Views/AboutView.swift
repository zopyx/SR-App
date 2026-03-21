import SwiftUI

struct AboutView: View {
    @Binding var isPresented: Bool
    let currentStation: Station
    let nowPlayingData: NowPlayingData?
    let onStationChange: (Station) -> Void
    
    @State private var copiedUrl: String? = nil
    
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    private var buildDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: Date())
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    close()
                }
            
            dialog
                .frame(maxWidth: 400, maxHeight: 500)
                .padding(20)
        }
        .transition(.opacity)
    }
    
    private var dialog: some View {
        VStack(spacing: 0) {
            header
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    stationsSection
                    Divider()
                    currentStationSection
                    Divider()
                    aboutSRSection
                    Divider()
                    appInfoSection
                    disclaimerSection
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            
            footer
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.5), radius: 25, x: 0, y: 12)
        )
    }
    
    private var header: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black.opacity(0.3))
                    .frame(width: 80, height: 80)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(currentStation.color, lineWidth: 2)
                    )
                
                Image(currentStation.logoName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 56, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            Text("SR Radio Player")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.white.opacity(0.98), Color.white.opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            Text("Version \(appVersion)")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            LinearGradient(
                colors: [currentStation.color.opacity(0.1), Color.clear],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .overlay(alignment: .topTrailing) {
            Button(action: close) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
                    .frame(width: 28, height: 28)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.1))
                    )
            }
            .buttonStyle(PlainButtonStyle())
            .padding(12)
        }
    }
    
    private var stationsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Available Stations (\(Station.all.count))")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.secondary)
                .tracking(0.5)
                .textCase(.uppercase)
            
            VStack(spacing: 6) {
                ForEach(Station.all) { station in
                    StationCard(
                        station: station,
                        isActive: station.id == currentStation.id,
                        onSelect: {
                            onStationChange(station)
                            close()
                        }
                    )
                }
            }
        }
    }
    
    private var currentStationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Current Station")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(currentStation.color)
                .tracking(0.5)
                .textCase(.uppercase)
            
            InfoRow(label: "Name", value: currentStation.name)
            InfoRow(label: "Tagline", value: currentStation.description)
            
            if let displayText = nowPlayingData?.displayText {
                InfoRow(label: "Now Playing", value: displayText, valueColor: currentStation.color)
            }
            
            InfoRow(label: "Quality", value: "256 kbps MP3")
            
            HStack {
                Text("Website")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .frame(width: 80, alignment: .leading)
                
                Link("Visit →", destination: currentStation.website)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(currentStation.color)
            }
            
            HStack {
                Text("Stream URL")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .frame(width: 80, alignment: .leading)
                
                Button(action: {
                    copyToClipboard(currentStation.streamUrl.absoluteString)
                }) {
                    Text(copiedUrl == currentStation.streamUrl.absoluteString ? "Copied!" : "Copy URL")
                        .font(.system(size: 13, weight: .medium))
                }
                .buttonStyle(PlainButtonStyle())
                .foregroundColor(.primary)
            }
        }
    }
    
    private var aboutSRSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("About Saarländischer Rundfunk")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.secondary)
                .tracking(0.5)
                .textCase(.uppercase)
            
            Text("The Saarländischer Rundfunk (SR) is the public broadcaster for Saarland, Germany. SR provides three radio stations offering news, culture, and entertainment programming since 1957.")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .lineSpacing(2)
        }
    }
    
    private var appInfoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("App Information")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.secondary)
                .tracking(0.5)
                .textCase(.uppercase)
            
            InfoRow(label: "Version", value: appVersion)
            InfoRow(label: "Build Date", value: buildDate)
            InfoRow(label: "Built with", value: "SwiftUI + AppKit")
            InfoRow(label: "Platforms", value: "macOS")
            InfoRow(label: "Author", value: "Andreas Jung")
            
            HStack {
                Text("Website")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .frame(width: 80, alignment: .leading)
                
                Link("www.zopyx.com →", destination: URL(string: "https://www.zopyx.com")!)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(currentStation.color)
            }
            
            InfoRow(label: "License", value: "MIT")
        }
    }
    
    private var disclaimerSection: some View {
        Text("This is an unofficial third-party app. SR1, SR2, SR3 and Saarländischer Rundfunk are trademarks of Saarländischer Rundfunk. All rights reserved.")
            .font(.system(size: 10))
            .foregroundColor(.secondary.opacity(0.7))
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 8)
    }
    
    private var footer: some View {
        Text("Made with ♥ for radio lovers")
            .font(.system(size: 11, weight: .medium))
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                Rectangle()
                    .fill(Color.white.opacity(0.03))
            )
    }
    
    private func close() {
        withAnimation(.easeOut(duration: 0.2)) {
            isPresented = false
        }
    }
    
    private func copyToClipboard(_ string: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(string, forType: .string)
        withAnimation {
            copiedUrl = string
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                copiedUrl = nil
            }
        }
    }
}

struct StationCard: View {
    let station: Station
    let isActive: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 10) {
                Circle()
                    .fill(station.color)
                    .frame(width: 10, height: 10)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(station.name)
                        .font(.system(size: 13, weight: .semibold))
                    
                    Text(station.description)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                if isActive {
                    Text("Active")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.1))
                        )
                }
            }
            .foregroundColor(.primary)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isActive ? Color.white.opacity(0.1) : Color.clear)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isActive)
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    var valueColor: Color? = nil
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .leading)
            
            Text(value)
                .font(.system(size: 13))
                .foregroundColor(valueColor ?? .primary)
                .lineLimit(1)
        }
    }
}
