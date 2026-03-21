import SwiftUI

struct StationSelector: View {
    @Binding var selectedStation: Station
    @Binding var isExpanded: Bool
    let stations: [Station]
    let onStationChange: (Station) -> Void
    
    @State private var isHovering = false
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isExpanded.toggle()
                }
            }) {
                HStack(spacing: 8) {
                    Circle()
                        .fill(selectedStation.color)
                        .frame(width: 10, height: 10)
                        .shadow(color: selectedStation.color.opacity(0.8), radius: 4)
                    
                    Text(selectedStation.shortName)
                        .font(.system(size: 16, weight: .bold))
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .bold))
                        .opacity(0.9)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(Color.black.opacity(isHovering ? 0.45 : 0.35))
                        .overlay(
                            Capsule().stroke(Color.white.opacity(0.15), lineWidth: 0.5)
                        )
                        .shadow(color: Color.black.opacity(0.2), radius: 3)
                )
            }
            .buttonStyle(PlainButtonStyle())
            .onHover { isHovering = $0 }
            
            if isExpanded {
                dropdown
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.95).combined(with: .opacity).combined(with: .offset(y: -5)),
                        removal: .scale(scale: 0.95).combined(with: .opacity)
                    ))
                    .padding(.top, 8)
            }
        }
    }
    
    private var dropdown: some View {
        VStack(spacing: 2) {
            ForEach(stations) { station in
                Button(action: {
                    if station.id != selectedStation.id {
                        onStationChange(station)
                    }
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isExpanded = false
                    }
                }) {
                    HStack(spacing: 12) {
                        Circle()
                            .fill(station.color)
                            .frame(width: 12, height: 12)
                            .shadow(color: station.color.opacity(0.6), radius: 3)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(station.name)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Text(station.description)
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.6))
                                .lineLimit(1)
                        }
                        
                        Spacer()
                        
                        if station.id == selectedStation.id {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(station.id == selectedStation.id ? Color.white.opacity(0.15) : Color.clear)
                    )
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(white: 0.1, opacity: 0.6))
#if os(macOS)
                .background(VisualEffectView(material: .popover, blendingMode: .withinWindow, state: .active).clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous)))
#else
                .background(VisualEffectView().clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous)))
#endif
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.white.opacity(0.15), lineWidth: 0.5)
                )
                .shadow(color: Color.black.opacity(0.4), radius: 15, x: 0, y: 8)
        )
        .frame(width: 280)
        .zIndex(100)
    }
}
