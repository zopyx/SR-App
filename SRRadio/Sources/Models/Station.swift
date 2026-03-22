import Foundation
import SwiftUI

/// Represents a radio station with its metadata and stream configuration.
///
/// `Station` is the core model for representing radio stations in the app.
/// It includes all necessary information for streaming, display, and persistence.
struct Station: Identifiable, Equatable, Hashable {
    /// Unique identifier for the station (e.g., `"sr1"`, `"radio_salue"`)
    let id: String

    /// Full display name of the station (e.g., `"SR 1"`, `"Radio Salü"`)
    let name: String

    /// Short name used in compact UI elements (e.g., `"SR1"`, `"Salü"`)
    let shortName: String

    /// Human-readable description of the station's format/content
    let description: String

    /// URL of the audio stream for playback
    let streamUrl: URL

    /// Asset name for the station logo image (empty string if using colored initials)
    let logoName: String

    /// Hex color string for branding (single source of truth).
    ///
    /// This is the primary color storage for the station. All color representations
    /// are derived from this value.
    let colorHex: String

    /// Brand color associated with the station, derived from `colorHex`.
    ///
    /// This computed property converts the stored hex string to a SwiftUI Color.
    var color: Color {
        Color(hex: colorHex)
    }

    /// Official website URL for the station
    let website: URL

    // MARK: - Saarländischer Rundfunk

    static let sr1 = srStation(
        id: "sr1",
        name: "SR 1",
        shortName: "SR1",
        description: "Saarlands beste Musik und Nachrichten",
        streamPath: "1009/mp3/128/sr1",
        logoName: "sr1_logo",
        colorHex: "#2ab3a6"
    )

    static let srKultur = srStation(
        id: "sr_kultur",
        name: "SR kultur",
        shortName: "SR kultur",
        description: "Kultur, Wort und klassische Musik",
        streamPath: "1010/mp3/128/sr2",
        logoName: "sr2_logo",
        colorHex: "#8b7cff"
    )

    static let sr3 = srStation(
        id: "sr3",
        name: "SR 3 Saarlandwelle",
        shortName: "SR3",
        description: "Die beste Musik für das Saarland",
        streamPath: "1011/mp3/128/sr3",
        logoName: "sr3_logo",
        colorHex: "#44a1ff"
    )

    static let unserding = srStation(
        id: "unserding",
        name: "SR UnserDing",
        shortName: "UnserDing",
        description: "Das junge Radio im Saarland",
        streamPath: "1012/mp3/128/ud",
        logoName: "",
        colorHex: "#ff6b35"
    )

    static let antenneSaar = srStation(
        id: "antenne_saar",
        name: "Antenne Saar",
        shortName: "Antenne",
        description: "Hits und gute Laune",
        streamPath: "1013/mp3/128/as",
        logoName: "",
        colorHex: "#e4002b"
    )

    // MARK: - Privatsender

    static let radioSalue = privateStation(
        id: "radio_salue",
        name: "Radio Salü",
        shortName: "Salü",
        description: "Das Hitradio aus dem Saarland",
        streamUrlString: "https://internetradio.salue.de:8443/salue5",
        websiteString: "https://www.salue.de",
        colorHex: "#ff9900"
    )

    static let bigfm = privateStation(
        id: "bigfm",
        name: "bigFM Saarland",
        shortName: "bigFM",
        description: "Deutschlands biggste Beats",
        streamUrlString: "https://stream.bigfm.de/saarland/mp3-128/private",
        websiteString: "https://www.bigfm.de",
        colorHex: "#00c853"
    )

    static let cityradioSB = privateStation(
        id: "cityradio_sb",
        name: "CityRadio Saarbrücken",
        shortName: "CR SB",
        description: "Dein Stadtradio für Saarbrücken",
        streamUrlString: "https://radiogroup-stream32.radiohost.de/cityradio-saarbruecken_mp3-192",
        websiteString: "https://www.cityradio-saarbruecken.de",
        colorHex: "#1976d2"
    )

    static let cityradioNK = privateStation(
        id: "cityradio_nk",
        name: "CityRadio Neunkirchen",
        shortName: "CR NK",
        description: "Dein Stadtradio für Neunkirchen",
        streamUrlString: "https://radiogroup-stream31.radiohost.de/cityradio-neunkirchen_mp3-192",
        websiteString: "https://www.cityradio-neunkirchen.de",
        colorHex: "#7b1fa2"
    )

    static let cityradioHOM = privateStation(
        id: "cityradio_hom",
        name: "CityRadio Homburg",
        shortName: "CR HOM",
        description: "Dein Stadtradio für Homburg",
        streamUrlString: "https://stream.radiogroup.de/cityradio-homburg/mp3-192",
        websiteString: "https://www.cityradio-homburg.de",
        colorHex: "#00838f"
    )

    static let cityradioSLS = privateStation(
        id: "cityradio_sls",
        name: "CityRadio Saarlouis",
        shortName: "CR SLS",
        description: "Dein Stadtradio für Saarlouis",
        streamUrlString: "https://stream.radiogroup.de/cityradio-saarlouis_mp3-192",
        websiteString: "https://www.cityradio-saarlouis.de",
        colorHex: "#c62828"
    )

    static let cityradioWND = privateStation(
        id: "cityradio_wnd",
        name: "CityRadio St. Wendel",
        shortName: "CR WND",
        description: "Dein Stadtradio für St. Wendel",
        streamUrlString: "https://radiogroup-stream32.radiohost.de/cityradio-stwendel_mp3-192",
        websiteString: "https://www.cityradio-stwendel.de",
        colorHex: "#558b2f"
    )

    static let radioRSL = privateStation(
        id: "radio_rsl",
        name: "Radio Saarschleifenland",
        shortName: "RSL",
        description: "Radio aus dem Saarschleifenland",
        streamUrlString: "http://stream.radiorsl.de:8000/radiorsl",
        websiteString: "https://www.radiorsl.de",
        colorHex: "#4e342e"
    )

    static let classicRock = privateStation(
        id: "classic_rock",
        name: "Classic Rock Radio",
        shortName: "CRR",
        description: "Die besten Classic Rock Hits",
        streamUrlString: "https://internetradio.salue.de:8443/classicrock.mp3",
        websiteString: "https://www.classicrockradio.de",
        colorHex: "#b71c1c"
    )

    static let schlagerparadies = privateStation(
        id: "schlagerparadies",
        name: "Radio Schlagerparadies",
        shortName: "Schlager",
        description: "Die schönsten Schlager",
        streamUrlString: "https://stream.schlagerparadies.de/schlagerparadies",
        websiteString: "https://www.schlagerparadies.de",
        colorHex: "#e91e63"
    )

    var hasLogo: Bool { !logoName.isEmpty }

    // MARK: - URL Validation

    /// Validates that the station's stream URL is valid.
    /// - Returns: true if the stream URL is a valid http/https URL
    var isValidStreamURL: Bool {
        guard streamUrl.scheme == "http" || streamUrl.scheme == "https" else {
            return false
        }
        return !(streamUrl.host?.isEmpty ?? true)
    }

    /// Validates that the station's website URL is valid.
    /// - Returns: true if the website URL is a valid http/https URL
    var isValidWebsiteURL: Bool {
        guard website.scheme == "http" || website.scheme == "https" else {
            return false
        }
        return !(website.host?.isEmpty ?? true)
    }

    // MARK: - Factory Methods

    /// Creates a Saarländischer Rundfunk (SR) station with standardized configuration.
    ///
    /// - Parameters:
    ///   - id: Station identifier (e.g., `"sr1"`, `"sr_kultur"`)
    ///   - name: Full display name
    ///   - shortName: Abbreviated name for compact UI
    ///   - description: Station description/tagline
    ///   - streamPath: Stream path segment for SR CDN URL
    ///   - logoName: Asset name for station logo
    ///   - colorHex: Hex color code for branding
    /// - Returns: A configured `Station` instance for SR stations
    /// - Note: This method uses safe URL creation and will use fallback URLs if parsing fails
    private static func srStation(
        id: String,
        name: String,
        shortName: String,
        description: String,
        streamPath: String,
        logoName: String,
        colorHex: String
    ) -> Station {
        let streamUrlString = "https://sr.audiostream.io/sr/\(streamPath)"
        let websiteString = "https://www.sr.de/\(id)"
        
        let streamUrl = URL(string: streamUrlString) ?? URL(fileURLWithPath: "/dev/null")
        let website = URL(string: websiteString) ?? URL(fileURLWithPath: "/dev/null")
        
        return Station(
            id: id,
            name: name,
            shortName: shortName,
            description: description,
            streamUrl: streamUrl,
            logoName: logoName,
            colorHex: colorHex,
            website: website
        )
    }

    /// Creates a private/commercial radio station.
    ///
    /// - Parameters:
    ///   - id: Station identifier
    ///   - name: Full display name
    ///   - shortName: Abbreviated name for compact UI
    ///   - description: Station description/tagline
    ///   - streamUrlString: Full stream URL
    ///   - websiteString: Full website URL
    ///   - colorHex: Hex color code for branding
    /// - Returns: A configured `Station` instance for private stations
    /// - Note: This method uses safe URL creation and will use fallback URLs if parsing fails
    private static func privateStation(
        id: String,
        name: String,
        shortName: String,
        description: String,
        streamUrlString: String,
        websiteString: String,
        colorHex: String
    ) -> Station {
        let streamUrl = URL(string: streamUrlString) ?? URL(fileURLWithPath: "/dev/null")
        let website = URL(string: websiteString) ?? URL(fileURLWithPath: "/dev/null")
        
        return Station(
            id: id,
            name: name,
            shortName: shortName,
            description: description,
            streamUrl: streamUrl,
            logoName: "",
            colorHex: colorHex,
            website: website
        )
    }

    /// Safely creates a URL from a string.
    ///
    /// This helper provides safe URL creation without fatal errors.
    /// For internal use during station initialization.
    ///
    /// - Parameter string: The URL string
    /// - Returns: A valid `URL` instance, or nil if the URL string is malformed
    private static func url(_ string: String) -> URL? {
        return URL(string: string)
    }

    // MARK: - Station Instances

    static let all: [Station] = [
        .sr1, .srKultur, .sr3, .unserding, .antenneSaar,
        .radioSalue, .bigfm,
        .cityradioSB, .cityradioNK, .cityradioHOM, .cityradioSLS, .cityradioWND,
        .radioRSL, .classicRock, .schlagerparadies
    ]
    static let `default` = sr1

    // MARK: - Default Station Persistence

    private static let defaultStationKey = "defaultStationId"

    /// The currently configured default station ID.
    ///
    /// - Returns: The stored station ID from `UserDefaults`, or the fallback default station ID.
    static var defaultStationId: String {
        get {
            UserDefaults.standard.string(forKey: defaultStationKey) ?? Station.default.id
        }
        set {
            UserDefaults.standard.set(newValue, forKey: defaultStationKey)
        }
    }

    /// The default station to use when the app launches.
    ///
    /// - Returns: The station matching `defaultStationId`, or the built-in default if not found.
    static var defaultStation: Station {
        all.first(where: { $0.id == defaultStationId }) ?? .default
    }

    /// Persists the given station ID as the default station.
    /// - Parameter id: The station ID to save as default.
    static func saveDefaultStation(id: String) {
        UserDefaults.standard.set(id, forKey: defaultStationKey)
    }

    // MARK: - Last Played Persistence

    private static let lastPlayedKey = "lastPlayedStationId"

    /// The last played station.
    ///
    /// - Returns: The most recently played station from `UserDefaults`, or the default station if none was played.
    static var lastPlayed: Station {
        guard let id = UserDefaults.standard.string(forKey: lastPlayedKey),
              let station = all.first(where: { $0.id == id }) else {
            return defaultStation
        }
        return station
    }

    /// Persists the given station as the last played station.
    /// - Parameter station: The station to save as last played.
    static func saveLastPlayed(_ station: Station) {
        UserDefaults.standard.set(station.id, forKey: lastPlayedKey)
    }
}

/// Represents now-playing metadata for a radio station.
///
/// `NowPlayingData` contains information about the currently playing track or show,
/// including title, artist, show name, and moderator.
struct NowPlayingData: Codable, Equatable {
    /// The title of the currently playing track.
    let title: String
    
    /// The artist of the currently playing track.
    let artist: String
    
    /// The name of the current show or program.
    let show: String
    
    /// The name of the current show moderator/host.
    let moderator: String

    /// Formatted display text for the now-playing information.
    ///
    /// Returns a human-readable string combining artist and title, or fallback to title/show.
    /// - Returns: `"Artist — Title"` if both available, otherwise `title` or `show`.
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
