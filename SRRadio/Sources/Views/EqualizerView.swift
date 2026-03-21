import SwiftUI

struct EqualizerView: View {
    let color: Color
    @State private var animationPhase = 0.0
    
    private let barHeights: [CGFloat] = [8, 16, 12, 18, 10]
    private let delays: [Double] = [0, 0.1, 0.2, 0.15, 0.05]
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 3) {
            ForEach(0..<5) { index in
                Capsule()
                    .fill(color)
                    .frame(width: 4, height: animatedHeight(for: index))
                    .animation(
                        .spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0.2)
                        .repeatForever(autoreverses: true)
                        .delay(delays[index]),
                        value: animationPhase
                    )
            }
        }
        .frame(height: 20)
        .onAppear {
            animationPhase = 1.0
        }
    }
    
    private func animatedHeight(for index: Int) -> CGFloat {
        barHeights[index] * (0.4 + 0.6 * animationPhase)
    }
}

struct PlayingIndicatorRing: View {
    let color: Color
    @State private var rotation: Double = 0
    
    var body: some View {
        Circle()
            .stroke(
                AngularGradient(
                    colors: [.clear, color.opacity(0.6), color, color.opacity(0.6), .clear],
                    center: .center
                ),
                lineWidth: 2
            )
            .blur(radius: 2)
            .rotationEffect(.degrees(rotation))
            .onAppear {
                withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            }
    }
}

struct VolumeIcon: View {
    let volume: Double
    let isMuted: Bool
    
    var body: some View {
        Image(systemName: iconName)
            .font(.system(size: 14))
            .foregroundColor(.primary)
    }
    
    private var iconName: String {
        if isMuted || volume == 0 {
            return "speaker.slash.fill"
        } else if volume < 0.3 {
            return "speaker.fill"
        } else if volume < 0.7 {
            return "speaker.wave.2.fill"
        } else {
            return "speaker.wave.3.fill"
        }
    }
}
