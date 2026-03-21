import SwiftUI

struct NowPlayingView: View {
    let data: NowPlayingData?
    let isLoading: Bool
    let stationColor: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text("Now Playing")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.secondary.opacity(0.7))
                .tracking(1)
                .textCase(.uppercase)
            
            Group {
                if isLoading {
                    Text("Loading...")
                        .foregroundColor(.secondary)
                } else if let displayText = data?.displayText {
                    Text(displayText)
                        .foregroundColor(stationColor)
                } else {
                    Text("No track information")
                        .foregroundColor(.secondary)
                }
            }
            .font(.system(size: 14, weight: .semibold))
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .minimumScaleFactor(0.8)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .frame(maxWidth: 260)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }
}

struct StatusIndicator: View {
    let isPlaying: Bool
    let isLoading: Bool
    let stationColor: Color
    
    private var statusText: String {
        if isLoading {
            return "Buffering..."
        } else if isPlaying {
            return "On Air"
        } else {
            return "Tap to Play"
        }
    }
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(isPlaying ? stationColor : Color.white.opacity(0.3))
                .frame(width: 6, height: 6)
                .shadow(color: isPlaying ? stationColor.opacity(0.5) : Color.clear, radius: 4)
                .opacity(isLoading ? 0.5 : 1.0)
                .animation(isLoading ? .easeInOut(duration: 0.5).repeatForever(autoreverses: true) : .default, value: isLoading)
            
            Text(statusText)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(isPlaying ? stationColor : .secondary)
                .tracking(0.5)
                .textCase(.uppercase)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }
}
