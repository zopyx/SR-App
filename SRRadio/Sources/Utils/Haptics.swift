import UIKit

enum Haptics {
    static func playPause() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    static func stationChange() {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }
}
