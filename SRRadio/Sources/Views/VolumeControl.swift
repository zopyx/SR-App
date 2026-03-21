import SwiftUI

struct VolumeControl: View {
    @Binding var volume: Double
    @Binding var isMuted: Bool
    let stationColor: Color
    let onMuteToggle: () -> Void
    
    @State private var isHovering = false
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: onMuteToggle) {
                Image(systemName: isMuted || volume == 0 ? "speaker.slash.fill" : "speaker.fill")
                    .font(.system(size: 11))
                    .foregroundColor(Color.white.opacity(0.7))
                    .frame(width: 16)
            }
            .buttonStyle(PlainButtonStyle())
            
            Slider(value: $volume, in: 0...1) { editing in
                if !editing && volume > 0 {
                    isMuted = false
                }
            }
            .tint(Color.white)
            .controlSize(.small)
            
            Image(systemName: "speaker.wave.3.fill")
                .font(.system(size: 11))
                .foregroundColor(Color.white.opacity(0.7))
                .frame(width: 18)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.1))
                .overlay(
                    Capsule().stroke(Color.white.opacity(0.15), lineWidth: 0.5)
                )
        )
        .scaleEffect(isHovering ? 1.02 : 1.0)
        .onHover { isHovering = $0 }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovering)
    }
}
