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
        }
        .fullScreenCover(isPresented: $isExpanded) {
            StationPickerSheet(
                selectedStation: $selectedStation,
                isPresented: $isExpanded,
                stations: stations,
                onStationChange: onStationChange
            )
        }
    }
}

struct StationPickerSheet: View {
    @Binding var selectedStation: Station
    @Binding var isPresented: Bool
    let stations: [Station]
    let onStationChange: (Station) -> Void

    @State private var searchText = ""

    private var filteredStations: [Station] {
        if searchText.isEmpty { return stations }
        return stations.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.description.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        ZStack {
            Color(white: 0.08).ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Sender wählen")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)

                    Spacer()

                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(Color.white.opacity(0.5))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)

                // Search
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Color.white.opacity(0.4))
                    TextField("Sender suchen...", text: $searchText)
                        .foregroundColor(.white)
                        .autocorrectionDisabled()
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.08))
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 12)

                // Station list
                ScrollView {
                    LazyVStack(spacing: 4) {
                        ForEach(filteredStations) { station in
                            StationRow(
                                station: station,
                                isSelected: station.id == selectedStation.id
                            ) {
                                onStationChange(station)
                                isPresented = false
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                }
            }
        }
    }
}

struct StationRow: View {
    let station: Station
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 14) {
                // Color indicator
                RoundedRectangle(cornerRadius: 4)
                    .fill(station.color)
                    .frame(width: 4, height: 36)

                VStack(alignment: .leading, spacing: 2) {
                    Text(station.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)

                    Text(station.description)
                        .font(.system(size: 13))
                        .foregroundColor(Color.white.opacity(0.5))
                        .lineLimit(1)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(station.color)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isSelected ? station.color.opacity(0.15) : Color.white.opacity(0.04))
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}
