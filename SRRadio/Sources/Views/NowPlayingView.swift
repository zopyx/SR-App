import SwiftUI

struct NowPlayingView: View {
    let data: NowPlayingData?
    let isLoading: Bool
    let stationColor: Color
    
    var body: some View {
        VStack(spacing: 2) {
            Group {
                if isLoading {
                    Text("Connecting...")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.7))
                } else if let data = data {
                    if let displayText = data.displayText {
                        let parts = buildParts(from: data)
                        Text(parts.main)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        if !parts.sub.isEmpty {
                            Text(parts.sub)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color.white.opacity(0.7))
                        }
                    } else {
                        Text("Live on Air")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(Color.white.opacity(0.7))
                    }
                } else {
                    Text("Live on Air")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.7))
                }
            }
            .multilineTextAlignment(.center)
            .lineLimit(1)
            .truncationMode(.tail)
        }
        .frame(maxWidth: 280)
    }
    
    private func buildParts(from data: NowPlayingData) -> (main: String, sub: String) {
        if !data.title.isEmpty {
            return (data.title, data.artist)
        } else if !data.show.isEmpty {
            return (data.show, data.moderator)
        }
        return (data.displayText ?? "", "")
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
