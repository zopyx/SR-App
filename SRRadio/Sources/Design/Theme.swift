import SwiftUI

enum Theme {
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.78)
    static let textTertiary = Color.white.opacity(0.58)

    static let panel = Color(.sRGB, red: 0.10, green: 0.11, blue: 0.14, opacity: 0.85)
    static let panelStrong = Color(.sRGB, red: 0.13, green: 0.14, blue: 0.18, opacity: 0.92)
    static let border = Color.white.opacity(0.12)
    static let borderStrong = Color.white.opacity(0.2)
    static let shadow = Color.black.opacity(0.35)
}
