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

struct AppBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(.sRGB, red: 0.06, green: 0.07, blue: 0.10, opacity: 1),
                    Color(.sRGB, red: 0.04, green: 0.05, blue: 0.08, opacity: 1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            RadialGradient(
                colors: [
                    Color.white.opacity(0.08),
                    Color.clear
                ],
                center: .topLeading,
                startRadius: 20,
                endRadius: 220
            )
            RadialGradient(
                colors: [
                    Color.white.opacity(0.05),
                    Color.clear
                ],
                center: .bottomTrailing,
                startRadius: 20,
                endRadius: 260
            )
        }
    }
}

struct GlassCard: ViewModifier {
    let cornerRadius: CGFloat
    let padding: EdgeInsets
    let strong: Bool
    
    init(cornerRadius: CGFloat = 16, padding: EdgeInsets = EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12), strong: Bool = false) {
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.strong = strong
    }
    
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(strong ? Theme.panelStrong : Theme.panel)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(strong ? Theme.borderStrong : Theme.border, lineWidth: 1)
                    )
                    .shadow(color: Theme.shadow, radius: 10, x: 0, y: 6)
            )
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat = 16, padding: EdgeInsets = EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12), strong: Bool = false) -> some View {
        modifier(GlassCard(cornerRadius: cornerRadius, padding: padding, strong: strong))
    }
}
