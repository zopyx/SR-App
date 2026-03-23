import SwiftUI

/// A loading spinner that syncs with the buffering state.
/// Displays an animated circular progress indicator with the station's accent color.
struct LoadingSpinnerView: View {
    let isVisible: Bool
    let color: Color
    
    @State private var rotation: Double = 0
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Background track
            Circle()
                .stroke(color.opacity(0.2), lineWidth: 4)
            
            // Animated arc
            Circle()
                .trim(from: 0, to: 0.75)
                .stroke(
                    AngularGradient(
                        colors: [color, color.opacity(0.5)],
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360)
                    ),
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .rotationEffect(.degrees(rotation))
        }
        .frame(width: 56, height: 56)
        .opacity(isVisible ? 1 : 0)
        .scaleEffect(isVisible ? 1 : 0.8)
        .animation(.easeInOut(duration: 0.3), value: isVisible)
        .onChange(of: isVisible) { visible in
            if visible {
                startAnimation()
            } else {
                stopAnimation()
            }
        }
        .onAppear {
            if isVisible {
                startAnimation()
            }
        }
        .onDisappear {
            stopAnimation()
        }
    }
    
    private func startAnimation() {
        guard !isAnimating else { return }
        isAnimating = true
        
        // Continuous rotation animation
        withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
            rotation = 360
        }
    }
    
    private func stopAnimation() {
        isAnimating = false
        rotation = 0
    }
}

// MARK: - Alternative: Pulsing Ring Spinner

/// A pulsing ring spinner for buffering indication.
/// Provides a subtle breathing animation that indicates activity.
struct PulsingSpinnerView: View {
    let isVisible: Bool
    let color: Color
    
    @State private var pulseScale: CGFloat = 1.0
    @State private var pulseOpacity: Double = 0.6
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Outer pulsing ring
            Circle()
                .stroke(color.opacity(pulseOpacity), lineWidth: 3)
                .scaleEffect(pulseScale)
            
            // Inner solid ring
            Circle()
                .stroke(color, lineWidth: 3)
                .frame(width: 40, height: 40)
            
            // Center dot
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
        }
        .frame(width: 56, height: 56)
        .opacity(isVisible ? 1 : 0)
        .animation(.easeInOut(duration: 0.3), value: isVisible)
        .onChange(of: isVisible) { visible in
            if visible {
                startAnimation()
            } else {
                stopAnimation()
            }
        }
        .onAppear {
            if isVisible {
                startAnimation()
            }
        }
        .onDisappear {
            stopAnimation()
        }
    }
    
    private func startAnimation() {
        guard !isAnimating else { return }
        isAnimating = true
        
        // Pulsing animation
        withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
            pulseScale = 1.3
            pulseOpacity = 0.2
        }
    }
    
    private func stopAnimation() {
        isAnimating = false
        pulseScale = 1.0
        pulseOpacity = 0.6
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 40) {
        LoadingSpinnerView(isVisible: true, color: .blue)
        PulsingSpinnerView(isVisible: true, color: .green)
    }
    .padding()
    .background(Color.black)
}
