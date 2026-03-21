import Foundation
import SwiftUI

struct Station: Identifiable, Equatable, Hashable {
    let id: String
    let name: String
    let shortName: String
    let description: String
    let streamUrl: URL
    let logoName: String
    let color: Color
    let website: URL
    
    static let sr1 = Station(
        id: "sr1",
        name: "SR 1 Europawelle",
        shortName: "SR1",
        description: "Saarlands beste Musik und Nachrichten",
        streamUrl: URL(string: "https://liveradio.sr.de/sr/sr1/mp3/256/stream.mp3?aggregator=custom1")!,
        logoName: "sr1_logo",
        color: Color(hex: "#e60005"),
        website: URL(string: "https://www.sr.de/sr1")!
    )
    
    static let sr2 = Station(
        id: "sr2",
        name: "SR 2 KulturRadio",
        shortName: "SR2",
        description: "Kultur, Wort und klassische Musik",
        streamUrl: URL(string: "https://liveradio.sr.de/sr/sr2/mp3/256/stream.mp3?aggregator=custom1")!,
        logoName: "sr2_logo",
        color: Color(hex: "#ffb700"),
        website: URL(string: "https://www.sr.de/sr2")!
    )
    
    static let sr3 = Station(
        id: "sr3",
        name: "SR 3 Saarlandwelle",
        shortName: "SR3",
        description: "Die beste Musik für das Saarland",
        streamUrl: URL(string: "https://liveradio.sr.de/sr/sr3/mp3/256/stream.mp3?aggregator=custom1")!,
        logoName: "sr3_logo",
        color: Color(hex: "#0082c9"),
        website: URL(string: "https://www.sr.de/sr3")!
    )
    
    static let all: [Station] = [.sr1, .sr2, .sr3]
    static let `default` = sr2
}

struct NowPlayingData: Codable, Equatable {
    let title: String
    let artist: String
    let show: String
    let moderator: String
    
    var displayText: String? {
        if !artist.isEmpty && !title.isEmpty {
            return "\(artist) — \(title)"
        }
        if !title.isEmpty {
            return title
        }
        if !show.isEmpty {
            return show
        }
        return nil
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
