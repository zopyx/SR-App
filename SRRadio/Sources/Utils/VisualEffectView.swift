import SwiftUI
import UIKit

struct VisualEffectView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterialDark))
        return view
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}
