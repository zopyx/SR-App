import SwiftUI

struct AboutView: View {
    @Binding var isPresented: Bool
    let currentStation: Station
    let nowPlayingData: NowPlayingData?

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
                .background(VisualEffectView())
                .ignoresSafeArea()
                .onTapGesture {
                    close()
                }

            dialog
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
        }
        .transition(.opacity)
    }

    private var dialog: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    currentStationSection
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
                .background(VisualEffectView().clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous)))
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.5), radius: 30, x: 0, y: 15)
        )
    }

    private var header: some View {
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

    private var currentStationSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(NSLocalizedString("AKTUELLER SENDER", comment: "Current station section header"))
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(currentStation.color)
                .tracking(0.5)
                .textCase(.uppercase)

            InfoRow(label: NSLocalizedString("Name", comment: "Station name label"), value: currentStation.name)
            InfoRow(label: NSLocalizedString("Beschreibung", comment: "Station description label"), value: currentStation.description)

            if let displayText = nowPlayingData?.displayText {
                InfoRow(label: NSLocalizedString("Läuft gerade", comment: "Now playing label"), value: displayText, valueColor: currentStation.color)
            }

            HStack(alignment: .top) {
                Text(NSLocalizedString("Website", comment: "Website label"))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.6))
                    .frame(width: 100, alignment: .leading)

                Link(NSLocalizedString("Webseite besuchen →", comment: "Visit website link"), destination: currentStation.website)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(currentStation.color)
            }

            HStack(alignment: .top) {
                Text(NSLocalizedString("Stream URL", comment: "Stream URL label"))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.6))
                    .frame(width: 100, alignment: .leading)

                Button(action: {
                    copyToClipboard(currentStation.streamUrl.absoluteString)
                }) {
                    Text(copiedUrl == currentStation.streamUrl.absoluteString ? NSLocalizedString("Kopiert!", comment: "Copied confirmation") : NSLocalizedString("URL kopieren", comment: "Copy URL action"))
                        .font(.system(size: 13, weight: .semibold))
                }
                .buttonStyle(PlainButtonStyle())
                .foregroundColor(.white)
            }
        }
    }

    private var appInfoSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(NSLocalizedString("APP-INFORMATIONEN", comment: "App information section header"))
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color.white.opacity(0.5))
                .tracking(0.5)
                .textCase(.uppercase)

            InfoRow(label: NSLocalizedString("Version", comment: "Version label"), value: appVersion)
            InfoRow(label: NSLocalizedString("Erstelldatum", comment: "Build date label"), value: buildDate)
            InfoRow(label: NSLocalizedString("Erstellt mit", comment: "Built with label"), value: "SwiftUI")
            InfoRow(label: NSLocalizedString("Plattformen", comment: "Platforms label"), value: "iOS, iPadOS")
            InfoRow(label: NSLocalizedString("Autor", comment: "Author label"), value: "Andreas Jung")

            HStack(alignment: .top) {
                Text(NSLocalizedString("Website", comment: "Website label"))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.6))
                    .frame(width: 100, alignment: .leading)

                Link("zopyx.com \u{2192}", destination: URL(string: "https://www.zopyx.com")!)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(currentStation.color)
            }

            InfoRow(label: NSLocalizedString("Lizenz", comment: "License label"), value: "MIT")
        }
    }

    private var disclaimerSection: some View {
        Text(NSLocalizedString("Dies ist eine inoffizielle Drittanbieter-App. Alle Sender und Marken gehören ihren jeweiligen Eigentümern.", comment: "Disclaimer text"))
            .font(.system(size: 11, weight: .medium))
            .foregroundColor(Color.white.opacity(0.4))
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 10)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var footer: some View {
        Text(NSLocalizedString("Mit ♥ für Radioliebhaber gemacht", comment: "Footer tagline"))
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
        UIPasteboard.general.string = string
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
