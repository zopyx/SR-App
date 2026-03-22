import ActivityKit
import Foundation

struct SRRadioAttributes: ActivityAttributes {
    let stationName: String
    let stationShortName: String
    let stationLogoName: String
    let stationColorHex: String

    struct ContentState: Codable, Hashable {
        let isPlaying: Bool
        let title: String
        let artist: String
        let show: String
    }
}
