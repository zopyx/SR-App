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
