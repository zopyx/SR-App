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

    var colorHex: String {
        switch id {
        case "sr1": return "#2ab3a6"
        case "sr_kultur": return "#8b7cff"
        case "sr3": return "#44a1ff"
        case "unserding": return "#ff6b35"
        case "antenne_saar": return "#e4002b"
        case "radio_salue": return "#ff9900"
        case "bigfm": return "#00c853"
        case "cityradio_sb": return "#1976d2"
        case "cityradio_nk": return "#7b1fa2"
        case "cityradio_hom": return "#00838f"
        case "cityradio_sls": return "#c62828"
        case "cityradio_wnd": return "#558b2f"
        case "radio_rsl": return "#4e342e"
        case "classic_rock": return "#b71c1c"
        case "schlagerparadies": return "#e91e63"
        default: return "#FFFFFF"
        }
    }

    // MARK: - Saarländischer Rundfunk

    static let sr1 = Station(
        id: "sr1",
        name: "SR 1",
        shortName: "SR1",
        description: "Saarlands beste Musik und Nachrichten",
        streamUrl: URL(string: "https://liveradio.sr.de/sr/sr1/mp3/128/stream.mp3")!,
        logoName: "sr1_logo",
        color: Color(hex: "#2ab3a6"),
        website: URL(string: "https://www.sr.de/sr1")!
    )

    static let srKultur = Station(
        id: "sr_kultur",
        name: "SR kultur",
        shortName: "SR kultur",
        description: "Kultur, Wort und klassische Musik",
        streamUrl: URL(string: "https://sr.audiostream.io/sr/1010/mp3/128/sr2")!,
        logoName: "sr2_logo",
        color: Color(hex: "#8b7cff"),
        website: URL(string: "https://www.sr.de/sr2")!
    )

    static let sr3 = Station(
        id: "sr3",
        name: "SR 3 Saarlandwelle",
        shortName: "SR3",
        description: "Die beste Musik für das Saarland",
        streamUrl: URL(string: "https://sr.audiostream.io/sr/1011/mp3/128/sr3")!,
        logoName: "sr3_logo",
        color: Color(hex: "#44a1ff"),
        website: URL(string: "https://www.sr.de/sr3")!
    )

    static let unserding = Station(
        id: "unserding",
        name: "SR UnserDing",
        shortName: "UnserDing",
        description: "Das junge Radio im Saarland",
        streamUrl: URL(string: "https://sr.audiostream.io/sr/1012/mp3/128/ud")!,
        logoName: "",
        color: Color(hex: "#ff6b35"),
        website: URL(string: "https://www.sr.de/unserding")!
    )

    static let antenneSaar = Station(
        id: "antenne_saar",
        name: "Antenne Saar",
        shortName: "Antenne",
        description: "Hits und gute Laune",
        streamUrl: URL(string: "https://sr.audiostream.io/sr/1013/mp3/128/as")!,
        logoName: "",
        color: Color(hex: "#e4002b"),
        website: URL(string: "https://www.antenne-saar.de")!
    )

    // MARK: - Privatsender

    static let radioSalue = Station(
        id: "radio_salue",
        name: "Radio Salü",
        shortName: "Salü",
        description: "Das Hitradio aus dem Saarland",
        streamUrl: URL(string: "https://internetradio.salue.de:8443/salue5")!,
        logoName: "",
        color: Color(hex: "#ff9900"),
        website: URL(string: "https://www.salue.de")!
    )

    static let bigfm = Station(
        id: "bigfm",
        name: "bigFM Saarland",
        shortName: "bigFM",
        description: "Deutschlands biggste Beats",
        streamUrl: URL(string: "https://stream.bigfm.de/saarland/mp3-128/private")!,
        logoName: "",
        color: Color(hex: "#00c853"),
        website: URL(string: "https://www.bigfm.de")!
    )

    static let cityradioSB = Station(
        id: "cityradio_sb",
        name: "CityRadio Saarbrücken",
        shortName: "CR SB",
        description: "Dein Stadtradio für Saarbrücken",
        streamUrl: URL(string: "https://radiogroup-stream32.radiohost.de/cityradio-saarbruecken_mp3-192")!,
        logoName: "",
        color: Color(hex: "#1976d2"),
        website: URL(string: "https://www.cityradio-saarbruecken.de")!
    )

    static let cityradioNK = Station(
        id: "cityradio_nk",
        name: "CityRadio Neunkirchen",
        shortName: "CR NK",
        description: "Dein Stadtradio für Neunkirchen",
        streamUrl: URL(string: "https://radiogroup-stream31.radiohost.de/cityradio-neunkirchen_mp3-192")!,
        logoName: "",
        color: Color(hex: "#7b1fa2"),
        website: URL(string: "https://www.cityradio-neunkirchen.de")!
    )

    static let cityradioHOM = Station(
        id: "cityradio_hom",
        name: "CityRadio Homburg",
        shortName: "CR HOM",
        description: "Dein Stadtradio für Homburg",
        streamUrl: URL(string: "https://stream.radiogroup.de/cityradio-homburg/mp3-192")!,
        logoName: "",
        color: Color(hex: "#00838f"),
        website: URL(string: "https://www.cityradio-homburg.de")!
    )

    static let cityradioSLS = Station(
        id: "cityradio_sls",
        name: "CityRadio Saarlouis",
        shortName: "CR SLS",
        description: "Dein Stadtradio für Saarlouis",
        streamUrl: URL(string: "https://stream.radiogroup.de/cityradio-saarlouis_mp3-192")!,
        logoName: "",
        color: Color(hex: "#c62828"),
        website: URL(string: "https://www.cityradio-saarlouis.de")!
    )

    static let cityradioWND = Station(
        id: "cityradio_wnd",
        name: "CityRadio St. Wendel",
        shortName: "CR WND",
        description: "Dein Stadtradio für St. Wendel",
        streamUrl: URL(string: "https://radiogroup-stream32.radiohost.de/cityradio-stwendel_mp3-192")!,
        logoName: "",
        color: Color(hex: "#558b2f"),
        website: URL(string: "https://www.cityradio-stwendel.de")!
    )

    static let radioRSL = Station(
        id: "radio_rsl",
        name: "Radio Saarschleifenland",
        shortName: "RSL",
        description: "Radio aus dem Saarschleifenland",
        streamUrl: URL(string: "http://stream.radiorsl.de:8000/radiorsl")!,
        logoName: "",
        color: Color(hex: "#4e342e"),
        website: URL(string: "https://www.radiorsl.de")!
    )

    static let classicRock = Station(
        id: "classic_rock",
        name: "Classic Rock Radio",
        shortName: "CRR",
        description: "Die besten Classic Rock Hits",
        streamUrl: URL(string: "https://internetradio.salue.de:8443/classicrock.mp3")!,
        logoName: "",
        color: Color(hex: "#b71c1c"),
        website: URL(string: "https://www.classicrockradio.de")!
    )

    static let schlagerparadies = Station(
        id: "schlagerparadies",
        name: "Radio Schlagerparadies",
        shortName: "Schlager",
        description: "Die schönsten Schlager",
        streamUrl: URL(string: "https://stream.schlagerparadies.de/schlagerparadies")!,
        logoName: "",
        color: Color(hex: "#e91e63"),
        website: URL(string: "https://www.schlagerparadies.de")!
    )

    var hasLogo: Bool { !logoName.isEmpty }

    static let all: [Station] = [
        .sr1, .srKultur, .sr3, .unserding, .antenneSaar,
        .radioSalue, .bigfm,
        .cityradioSB, .cityradioNK, .cityradioHOM, .cityradioSLS, .cityradioWND,
        .radioRSL, .classicRock, .schlagerparadies
    ]
    static let `default` = sr1
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
