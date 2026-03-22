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

struct SRRadioLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SRRadioAttributes.self) { context in
            // MARK: - Lock Screen Banner
            lockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // MARK: - Expanded Dynamic Island
                DynamicIslandExpandedRegion(.leading) {
                    Image(context.attributes.stationLogoName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                }
                DynamicIslandExpandedRegion(.center) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(context.attributes.stationName)
                            .font(.headline)
                            .foregroundColor(Color(hex: context.attributes.stationColorHex))
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
                    Image(systemName: context.state.isPlaying ? "pause.fill" : "play.fill")
                        .font(.title2)
                        .foregroundColor(Color(hex: context.attributes.stationColorHex))
                }
            } compactLeading: {
                // MARK: - Compact Leading
                Image(context.attributes.stationLogoName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .clipShape(Circle())
            } compactTrailing: {
                // MARK: - Compact Trailing
                Image(systemName: context.state.isPlaying ? "waveform" : "pause.fill")
                    .font(.caption)
                    .foregroundColor(Color(hex: context.attributes.stationColorHex))
            } minimal: {
                // MARK: - Minimal
                Image(context.attributes.stationLogoName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                    .clipShape(Circle())
            }
        }
    }

    // MARK: - Lock Screen View

    @ViewBuilder
    private func lockScreenView(context: ActivityViewContext<SRRadioAttributes>) -> some View {
        let stationColor = Color(hex: context.attributes.stationColorHex)

        HStack(spacing: 12) {
            Image(context.attributes.stationLogoName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 48, height: 48)
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

            Image(systemName: context.state.isPlaying ? "pause.fill" : "play.fill")
                .font(.title2)
                .foregroundColor(stationColor)
        }
        .padding()
        .widgetURL(URL(string: "srradio://open")!)
    }
}
