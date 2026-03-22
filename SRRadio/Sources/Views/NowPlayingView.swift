import SwiftUI

struct NowPlayingView: View {
    let data: NowPlayingData?
    let isLoading: Bool
    let stationColor: Color

    private let mainFontSize: CGFloat = 18
    private let subFontSize: CGFloat = 15
    private let statusFontSize: CGFloat = 16
    private let maxWidth: CGFloat = 320

    var body: some View {
        VStack(spacing: 2) {
            if isLoading {
                // Show loading skeleton animation
                LoadingSkeletonView(lineCount: 2, stationColor: stationColor)
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
                Text(NSLocalizedString("Live auf Sendung", comment: "Status when no track info available"))
                    .font(.system(size: statusFontSize, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.7))
            }
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

/// Animated loading skeleton placeholder for now-playing information.
struct LoadingSkeletonView: View {
    let lineCount: Int
    let stationColor: Color
    
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 6) {
            ForEach(0..<lineCount, id: \.self) { index in
                SkeletonLine(
                    width: index == 0 ? 180 : 120,
                    height: index == 0 ? 22 : 18,
                    stationColor: stationColor,
                    isAnimating: isAnimating
                )
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

/// Single skeleton line with shimmer animation.
struct SkeletonLine: View {
    let width: CGFloat
    let height: CGFloat
    let stationColor: Color
    let isAnimating: Bool
    
    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.1),
                        Color.white.opacity(isAnimating ? 0.25 : 0.15),
                        Color.white.opacity(0.1)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: width, height: height)
    }
}

struct StatusIndicator: View {
    let isPlaying: Bool
    let isLoading: Bool
    let stationColor: Color

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(isPlaying ? stationColor : Color.white.opacity(0.4))
                .frame(width: 6, height: 6)
                .shadow(color: isPlaying ? stationColor.opacity(0.6) : .clear, radius: 4)
                .opacity(isLoading && !isPlaying ? 0.4 : 1.0)
                .animation(isLoading && !isPlaying ? .easeInOut(duration: 0.5).repeatForever(autoreverses: true) : .default, value: isLoading)

            Text(statusText)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(isPlaying ? .white : Color.white.opacity(0.6))
                .tracking(1.5)
        }
    }
    
    private var statusText: String {
        // Priority: playing > loading > paused
        if isPlaying {
            return NSLocalizedString("AUF SENDUNG", comment: "On air status")
        } else if isLoading {
            return NSLocalizedString("PUFFERN", comment: "Buffering status")
        } else {
            return NSLocalizedString("PAUSIERT", comment: "Paused status")
        }
    }
}
