import SwiftUI

struct StationSelector: View {
    @Binding var selectedStation: Station
    @Binding var isExpanded: Bool
    let stations: [Station]
    let onStationChange: (Station) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: {
                withAnimation(.easeOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            }) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(selectedStation.color)
                        .frame(width: 8, height: 8)
                        .shadow(color: selectedStation.color.opacity(0.5), radius: 4)
                    
                    Text(selectedStation.shortName)
                        .font(.system(size: 13, weight: .semibold))
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10))
                        .opacity(0.6)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .foregroundColor(.primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpanded {
                dropdown
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .offset(y: -10)),
                        removal: .opacity
                    ))
            }
        }
    }
    
    private var dropdown: some View {
        VStack(spacing: 4) {
            ForEach(stations) { station in
                Button(action: {
                    if station.id != selectedStation.id {
                        onStationChange(station)
                    }
                    withAnimation {
                        isExpanded = false
                    }
                }) {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(station.color)
                            .frame(width: 10, height: 10)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(station.shortName)
                                .font(.system(size: 13, weight: .semibold))
                            
                            Text(station.description)
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                        
                        Spacer()
                        
                        if station.id == selectedStation.id {
                            Image(systemName: "checkmark")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                    }
                    .foregroundColor(.primary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(station.id == selectedStation.id ? 
                                  Color.white.opacity(0.1) : Color.clear)
                    )
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.4), radius: 16, x: 0, y: 8)
        )
        .frame(width: 220)
        .zIndex(100)
    }
}
