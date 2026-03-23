import SwiftUI

/// A visual indicator that displays the current player state.
/// Shows different icons and colors based on whether the player is:
/// - Started (ready, gray dot)
/// - Buffering (spinning arrow, amber)
/// - Playing (animated waveform, station color)
/// - Paused (stop icon, gray)
/// - Muted (slash speaker, red) - overlay on playing or paused
/// - Error (exclamation triangle, red)
struct StatusIndicatorView: View {
    let state: PlayerState
    let stationColor: Color
    
    @State private var pulseAnimation = false
    @State private var rotationAngle: Double = 0
    @State private var barAnimations: [Bool] = [false, false, false, false, false]
    
    var body: some View {
        HStack(spacing: 8) {
            // Dynamic indicator icon based on state
            indicatorIcon
                .frame(width: 16, height: 16)
            
            // Status text
            Text(state.statusText)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(textColor)
                .tracking(1.5)
                .lineLimit(1)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(backgroundColor.opacity(0.15))
                .overlay(
                    Capsule()
                        .stroke(backgroundColor.opacity(0.3), lineWidth: 1)
                )
        )
        .animation(.easeInOut(duration: 0.25), value: state)
        .onAppear {
            startAnimations()
        }
        .onChange(of: state) { _ in
            startAnimations()
        }
    }
    
    // MARK: - Indicator Icon
    
    @ViewBuilder
    private var indicatorIcon: some View {
        switch state {
        case .started:
            startedIndicator
        case .buffering:
            bufferingIndicator
        case .playing:
            playingIndicator
        case .paused:
            pausedIndicator
        case .muted(let underlying):
            mutedIndicator(for: underlying)
        case .error:
            errorIndicator
        }
    }
    
    /// Gray dot for started state
    private var startedIndicator: some View {
        Circle()
            .fill(Color.white.opacity(0.4))
            .frame(width: 8, height: 8)
    }
    
    /// Spinning arrow for buffering state
    private var bufferingIndicator: some View {
        Image(systemName: "arrow.clockwise")
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(amberColor)
            .rotationEffect(.degrees(rotationAngle))
            .onAppear {
                withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
                    rotationAngle = 360
                }
            }
            .onDisappear {
                rotationAngle = 0
            }
    }
    
    /// Animated waveform bars for playing state
    private var playingIndicator: some View {
        HStack(alignment: .center, spacing: 2) {
            ForEach(0..<4) { index in
                RoundedRectangle(cornerRadius: 1)
                    .fill(stationColor)
                    .frame(width: 2.5, height: barHeight(for: index))
                    .animation(
                        .easeInOut(duration: 0.4)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.1),
                        value: barAnimations[index]
                    )
            }
        }
        .frame(height: 12)
    }
    
    /// Stop icon for paused state
    private var pausedIndicator: some View {
        Image(systemName: "stop.fill")
            .font(.system(size: 10, weight: .semibold))
            .foregroundColor(Color.white.opacity(0.6))
    }
    
    /// Slash speaker for muted state
    private func mutedIndicator(for underlying: PlayerState.MutedUnderlyingState) -> some View {
        Image(systemName: "speaker.slash.fill")
            .font(.system(size: 10, weight: .semibold))
            .foregroundColor(mutedColor)
    }
    
    /// Error triangle for error state
    private var errorIndicator: some View {
        Image(systemName: "exclamationmark.triangle.fill")
            .font(.system(size: 10, weight: .semibold))
            .foregroundColor(errorColor)
    }
    
    // MARK: - Helper Methods
    
    private func startAnimations() {
        // Reset and start bar animations for playing state
        if case .playing = state {
            barAnimations = [false, false, false, false, false]
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                barAnimations = [true, true, true, true, true]
            }
        }
    }
    
    private func barHeight(for index: Int) -> CGFloat {
        let heights: [CGFloat] = [6, 10, 7, 11]
        let baseHeight = heights[index % heights.count]
        return barAnimations[index] ? baseHeight : 3
    }
    
    private var textColor: Color {
        switch state {
        case .started:
            return Color.white.opacity(0.6)
        case .buffering:
            return amberColor
        case .playing:
            return .white
        case .paused:
            return Color.white.opacity(0.6)
        case .muted:
            return mutedColor
        case .error:
            return errorColor
        }
    }
    
    private var backgroundColor: Color {
        switch state {
        case .started:
            return Color.white
        case .buffering:
            return amberColor
        case .playing:
            return stationColor
        case .paused:
            return Color.white
        case .muted:
            return mutedColor
        case .error:
            return errorColor
        }
    }
    
    private var amberColor: Color {
        Color(red: 1.0, green: 0.7, blue: 0.0)
    }
    
    private var mutedColor: Color {
        Color(red: 0.9, green: 0.3, blue: 0.3)
    }
    
    private var errorColor: Color {
        Color(red: 1.0, green: 0.27, blue: 0.27)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        StatusIndicatorView(state: .started, stationColor: .blue)
        StatusIndicatorView(state: .buffering, stationColor: .blue)
        StatusIndicatorView(state: .playing, stationColor: .blue)
        StatusIndicatorView(state: .paused, stationColor: .blue)
        StatusIndicatorView(state: .muted(underlying: .playing), stationColor: .blue)
        StatusIndicatorView(state: .muted(underlying: .paused), stationColor: .blue)
        StatusIndicatorView(state: .error("Test"), stationColor: .blue)
    }
    .padding()
    .background(Color.black)
}
