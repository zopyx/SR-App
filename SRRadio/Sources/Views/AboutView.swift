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
            Color.black.opacity(0.4)
#if os(macOS)
                .background(VisualEffectView(material: .popover, blendingMode: .withinWindow, state: .active))
#else
                .background(VisualEffectView())
#endif
                .ignoresSafeArea()
                .onTapGesture {
                    close()
                }
            
            dialog
                .frame(maxWidth: 400, maxHeight: 540) // Given macOS has some paddings, slightly larger max height
                .padding(20)
        }
        .transition(.opacity)
    }
    
    private var dialog: some View {
        VStack(spacing: 0) {
            header
            
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    stationsSection
                    Divider().background(Color.white.opacity(0.1))
                    currentStationSection
                    Divider().background(Color.white.opacity(0.1))
                    aboutSRSection
                    Divider().background(Color.white.opacity(0.1))
                    appInfoSection
                    disclaimerSection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            
            footer
        }
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(white: 0.1, opacity: 0.8))
#if os(macOS)
                .background(VisualEffectView(material: .hudWindow, blendingMode: .withinWindow, state: .active).clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous)))
#else
                .background(VisualEffectView().clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous)))
#endif
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.5), radius: 30, x: 0, y: 15)
        )
    }
    
    private var header: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white.opacity(0.05))
                    .frame(width: 80, height: 80)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(currentStation.color.opacity(0.5), lineWidth: 1)
                    )
                
                Image(currentStation.logoName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .padding(.bottom, 4)
            
            Text("SR Radio")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            
            Text("Version \(appVersion)")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            LinearGradient(
                colors: [currentStation.color.opacity(0.15), Color.clear],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .overlay(alignment: .topTrailing) {
            Button(action: close) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color.white.opacity(0.7))
                    .frame(width: 28, height: 28)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Circle())
            }
            .buttonStyle(PlainButtonStyle())
            .padding(16)
        }
    }
    
    private var stationsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Available Stations (\(Station.all.count))")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color.white.opacity(0.5))
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
        VStack(alignment: .leading, spacing: 10) {
            Text("Current Station")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(currentStation.color)
                .tracking(0.5)
                .textCase(.uppercase)
            
            InfoRow(label: "Name", value: currentStation.name)
            InfoRow(label: "Tagline", value: currentStation.description)
            
            if let displayText = nowPlayingData?.displayText {
                InfoRow(label: "Now Playing", value: displayText, valueColor: currentStation.color)
            }
            
            InfoRow(label: "Quality", value: "256 kbps MP3")
            
            HStack(alignment: .top) {
                Text("Website")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.6))
                    .frame(width: 100, alignment: .leading)
                
                Link("Visit website \u{2192}", destination: currentStation.website)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(currentStation.color)
            }
            
            HStack(alignment: .top) {
                Text("Stream URL")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.6))
                    .frame(width: 100, alignment: .leading)
                
                Button(action: {
                    copyToClipboard(currentStation.streamUrl.absoluteString)
                }) {
                    Text(copiedUrl == currentStation.streamUrl.absoluteString ? "Copied!" : "Copy URL")
                        .font(.system(size: 13, weight: .semibold))
                }
                .buttonStyle(PlainButtonStyle())
                .foregroundColor(.white)
            }
        }
    }
    
    private var aboutSRSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("About Saarländischer Rundfunk")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color.white.opacity(0.5))
                .tracking(0.5)
                .textCase(.uppercase)
            
            Text("The Saarländischer Rundfunk (SR) is the public broadcaster for Saarland, Germany. SR provides three radio stations offering news, culture, and entertainment programming since 1957.")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color.white.opacity(0.8))
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    private var appInfoSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("App Information")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color.white.opacity(0.5))
                .tracking(0.5)
                .textCase(.uppercase)
            
            InfoRow(label: "Version", value: appVersion)
            InfoRow(label: "Build Date", value: buildDate)
            InfoRow(label: "Built with", value: "SwiftUI + AppKit")
            InfoRow(label: "Platforms", value: "macOS")
            InfoRow(label: "Author", value: "Andreas Jung")
            
            HStack(alignment: .top) {
                Text("Website")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.6))
                    .frame(width: 100, alignment: .leading)
                
                Link("zopyx.com \u{2192}", destination: URL(string: "https://www.zopyx.com")!)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(currentStation.color)
            }
            
            InfoRow(label: "License", value: "MIT")
        }
    }
    
    private var disclaimerSection: some View {
        Text("This is an unofficial third-party app. SR1, SR2, SR3 and Saarländischer Rundfunk are trademarks of Saarländischer Rundfunk.")
            .font(.system(size: 11, weight: .medium))
            .foregroundColor(Color.white.opacity(0.4))
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 10)
            .fixedSize(horizontal: false, vertical: true)
    }
    
    private var footer: some View {
        Text("Made with ♥ for radio lovers")
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(Color.white.opacity(0.5))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.white.opacity(0.05))
    }
    
    private func close() {
        withAnimation(.easeOut(duration: 0.2)) {
            isPresented = false
        }
    }
    
    private func copyToClipboard(_ string: String) {
#if os(macOS)
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(string, forType: .string)
#else
        UIPasteboard.general.string = string
#endif
        withAnimation {
            copiedUrl = string
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                if copiedUrl == string {
                    copiedUrl = nil
                }
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
            HStack(spacing: 12) {
                Circle()
                    .fill(station.color)
                    .frame(width: 10, height: 10)
                    .shadow(color: station.color.opacity(0.6), radius: 3)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(station.name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(station.description)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.6))
                        .lineLimit(1)
                }
                
                Spacer()
                
                if isActive {
                    Text("Active")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color.white.opacity(0.9))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.15))
                        )
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isActive ? Color.white.opacity(0.1) : Color.white.opacity(0.03))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.white.opacity(isActive ? 0.15 : 0.05), lineWidth: 1)
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
        HStack(alignment: .top) {
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color.white.opacity(0.6))
                .frame(width: 100, alignment: .leading)
            
            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(valueColor ?? .white)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
