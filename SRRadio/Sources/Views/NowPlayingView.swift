import SwiftUI

struct NowPlayingView: View {
    let data: NowPlayingData?
    let isLoading: Bool
    let stationColor: Color

#if os(macOS)
    private let mainFontSize: CGFloat = 16
    private let subFontSize: CGFloat = 14
    private let statusFontSize: CGFloat = 15
    private let maxWidth: CGFloat = 280
#else
    private let mainFontSize: CGFloat = 18
    private let subFontSize: CGFloat = 15
    private let statusFontSize: CGFloat = 16
    private let maxWidth: CGFloat = 320
#endif
    
    var body: some View {
        VStack(spacing: 2) {
            Group {
                if isLoading {
                    Text("Connecting...")
                        .font(.system(size: statusFontSize, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.7))
                } else if let data = data, let parts = buildParts(from: data) {
                    Text(parts.main)
                        .font(.system(size: mainFontSize, weight: .semibold))
                        .foregroundColor(.white)
                    
                    if !parts.sub.isEmpty {
                        Text(parts.sub)
                            .font(.system(size: subFontSize, weight: .medium))
                            .foregroundColor(Color.white.opacity(0.7))
                    }
                } else {
                    Text("Live on Air")
                        .font(.system(size: statusFontSize, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.7))
                }
            }
            .multilineTextAlignment(.center)
            .lineLimit(1)
            .truncationMode(.tail)
        }
        .frame(maxWidth: maxWidth)
    }
    
    private func buildParts(from data: NowPlayingData) -> (main: String, sub: String)? {
        if !data.title.isEmpty {
            return (data.title, data.artist)
        } else if !data.show.isEmpty {
            return (data.show, data.moderator)
        } else if data.displayText != nil {
            return (data.displayText!, "")
        }
        return nil
    }
}

struct StatusIndicator: View {
    let isPlaying: Bool
    let isLoading: Bool
    let stationColor: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(isPlaying && !isLoading ? stationColor : Color.white.opacity(0.4))
                .frame(width: 6, height: 6)
                .shadow(color: isPlaying && !isLoading ? stationColor.opacity(0.6) : .clear, radius: 4)
                .opacity(isLoading ? 0.4 : 1.0)
                .animation(isLoading ? .easeInOut(duration: 0.5).repeatForever(autoreverses: true) : .default, value: isLoading)
            
            Text(isLoading ? "BUFFERING" : (isPlaying ? "ON AIR" : "PAUSED"))
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(isPlaying && !isLoading ? .white : Color.white.opacity(0.6))
                .tracking(1.5)
        }
    }
}
