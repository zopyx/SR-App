import SwiftUI

struct VolumeControl: View {
    @Binding var volume: Double
    @Binding var isMuted: Bool
    let stationColor: Color
    let onMuteToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            // Mute button
            Button(action: onMuteToggle) {
                VolumeIcon(volume: volume, isMuted: isMuted)
                    .frame(width: 24, height: 24)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.05))
                    )
            }
            .buttonStyle(PlainButtonStyle())
            
            // Native Slider - works better on macOS
            Slider(value: $volume, in: 0...1) { editing in
                if !editing && volume > 0 {
                    isMuted = false
                }
            }
            .tint(stationColor)
            .frame(height: 16)
            
            // Volume percentage
            Text(isMuted ? "Muted" : "\(Int((isMuted ? 0 : volume) * 100))%")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.secondary)
                .frame(width: 46, alignment: .trailing)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
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
