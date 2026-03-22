import SwiftUI

struct StationLogo: View {
    let station: Station
    let size: CGFloat

    var body: some View {
        if station.hasLogo {
            Image(station.logoName)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: size * 0.08, style: .continuous))
        } else {
            ZStack {
                RoundedRectangle(cornerRadius: size * 0.08, style: .continuous)
                    .fill(station.color.opacity(0.25))
                    .overlay(
                        RoundedRectangle(cornerRadius: size * 0.08, style: .continuous)
                            .stroke(station.color.opacity(0.4), lineWidth: 1)
                    )

                Text(station.shortName)
                    .font(.system(size: size * 0.22, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            .frame(width: size, height: size)
        }
    }
}
