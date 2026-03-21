import SwiftUI

struct VolumeControl: View {
    @Binding var volume: Double
    @Binding var isMuted: Bool
    let stationColor: Color
    let onMuteToggle: () -> Void
    
    @State private var isHovering = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Mute button
            Button(action: onMuteToggle) {
                Image(systemName: isMuted || volume == 0 ? "speaker.slash.fill" : "speaker.fill")
                    .font(.system(size: 14))
                    .foregroundColor(isMuted ? Color(red: 1, green: 0.4, blue: 0.4) : .white)
                    .frame(width: 32, height: 32)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white.opacity(0.15), lineWidth: 0.5))
                    .shadow(color: Color.black.opacity(0.2), radius: 2)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Slider Pill
            HStack(spacing: 8) {
                Image(systemName: "speaker.wave.1.fill")
                    .font(.system(size: 10))
                    .foregroundColor(Color.white.opacity(0.5))
                    .frame(width: 14)
                
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
                    .frame(width: 16)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.08))
                    .overlay(
                        Capsule().stroke(Color.white.opacity(0.15), lineWidth: 0.5)
                    )
            )
            .scaleEffect(isHovering ? 1.02 : 1.0)
            .onHover { isHovering = $0 }
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovering)
        }
    }
}
