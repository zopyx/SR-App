import ActivityKit
import WidgetKit
import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(.sRGB, red: r, green: g, blue: b)
    }
}

// MARK: - Logo View

struct LiveActivityLogoView: View {
    let logoName: String
    let stationColor: Color
    let shortName: String
    let size: CGFloat

    var body: some View {
        if !logoName.isEmpty {
            Image(logoName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size)
                .clipShape(Circle())
        } else {
            ZStack {
                Circle()
                    .fill(stationColor.opacity(0.3))
                Text(initials(from: shortName))
                    .font(.system(size: size * 0.4, weight: .bold))
                    .foregroundColor(stationColor)
            }
            .frame(width: size, height: size)
        }
    }

    private func initials(from name: String) -> String {
        let words = name.split(separator: " ")
        if words.count >= 2 {
            return String(words[0].prefix(1)) + String(words[1].prefix(1))
        } else if let first = name.first {
            return String(first)
        }
        return "?"
    }
}

// MARK: - App Logo View

struct AppLogoView: View {
    let size: CGFloat
    
    var body: some View {
        Image("AppIconLiveActivity")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: size * 0.2))
    }
}

struct SRRadioLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SRRadioAttributes.self) { context in
            // MARK: - Lock Screen Banner
            lockScreenView(context: context)
        } dynamicIsland: { context in
            let stationColor = Color(hex: context.attributes.stationColorHex)

            return DynamicIsland {
                // MARK: - Expanded Dynamic Island
                DynamicIslandExpandedRegion(.leading) {
                    LiveActivityLogoView(
                        logoName: context.attributes.stationLogoName,
                        stationColor: stationColor,
                        shortName: context.attributes.stationShortName,
                        size: 40
                    )
                }
                DynamicIslandExpandedRegion(.center) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(context.attributes.stationName)
                            .font(.headline)
                            .foregroundColor(stationColor)
                        if !context.state.artist.isEmpty {
                            Text(context.state.artist)
                                .font(.subheadline)
                                .lineLimit(1)
                        }
                        if !context.state.title.isEmpty {
                            Text(context.state.title)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    AppLogoView(size: 40)
                }
            } compactLeading: {
                // MARK: - Compact Leading
                LiveActivityLogoView(
                    logoName: context.attributes.stationLogoName,
                    stationColor: stationColor,
                    shortName: context.attributes.stationShortName,
                    size: 24
                )
            } compactTrailing: {
                // MARK: - Compact Trailing
                Image(systemName: context.state.isPlaying ? "waveform" : "pause.fill")
                    .font(.caption)
                    .foregroundColor(stationColor)
            } minimal: {
                // MARK: - Minimal
                LiveActivityLogoView(
                    logoName: context.attributes.stationLogoName,
                    stationColor: stationColor,
                    shortName: context.attributes.stationShortName,
                    size: 20
                )
            }
        }
    }

    // MARK: - Lock Screen View

    @ViewBuilder
    private func lockScreenView(context: ActivityViewContext<SRRadioAttributes>) -> some View {
        let stationColor = Color(hex: context.attributes.stationColorHex)

        HStack(spacing: 12) {
            LiveActivityLogoView(
                logoName: context.attributes.stationLogoName,
                stationColor: stationColor,
                shortName: context.attributes.stationShortName,
                size: 48
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(context.attributes.stationShortName)
                    .font(.headline)
                    .foregroundColor(stationColor)

                if !context.state.show.isEmpty {
                    Text(context.state.show)
                        .font(.subheadline)
                        .lineLimit(1)
                }

                if !context.state.title.isEmpty || !context.state.artist.isEmpty {
                    Text([context.state.artist, context.state.title]
                        .filter { !$0.isEmpty }
                        .joined(separator: " - "))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            AppLogoView(size: 40)
        }
        .padding()
        .widgetURL(URL(string: "streamsaar://open")!)
    }
}
