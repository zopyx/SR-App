import Foundation
import Combine

// MARK: - Error Type Alias

/// NowPlayingError is now an alias for RadioError for backward compatibility
typealias NowPlayingError = RadioError

// MARK: - Regex Pattern Configuration

/// Centralized configuration for HTML regex patterns
/// This makes patterns easier to maintain and update
struct NowPlayingPatterns {
    // MARK: - Musikrecherche HTML Patterns

    /// Pattern for extracting time entries from musikrecherche HTML
    /// Matches: <span class="musicResearch__Item__Time">HH:MM</span>
    static let timePattern = #"musicResearch__Item__Time[^>]*>(\d{2}:\d{2})</span>"#

    /// Pattern for extracting song titles from musikrecherche HTML
    /// Matches: <div class="musicResearch__Item__Content__Title">Title</div>
    static let titlePattern = #"musicResearch__Item__Content__Title[^>]*>([^<]+)</div>"#

    /// Pattern for extracting artist names from musikrecherche HTML
    /// Matches: <div class="musicResearch__Item__Content__Artist">Artist</div>
    static let artistPattern = #"musicResearch__Item__Content__Artist[^>]*>([^<]+)</div>"#

    // MARK: - Fallback Patterns (in order of preference)

    static let timeFallbackPatterns = [
        timePattern,
        #"class="time"[^>]*>(\d{2}:\d{2})<"#,
        #">(\d{2}:\d{2})<"#
    ]

    static let titleFallbackPatterns = [
        titlePattern,
        #"class="title"[^>]*>([^<]+)<"#,
        #""title"[^>]*>([^<]+)<"#
    ]

    static let artistFallbackPatterns = [
        artistPattern,
        #"class="artist"[^>]*>([^<]+)<"#,
        #""artist"[^>]*>([^<]+)<"#
    ]
}

// MARK: - Cached Response

/// Stores a cached API response with timestamp
struct CachedResponse<T> {
    let data: T
    let timestamp: Date
    let stationId: String

    /// Returns true if the cache is still valid (not older than maxAge)
    func isValid(maxAge: TimeInterval) -> Bool {
        return Date().timeIntervalSince(timestamp) < maxAge
    }
}

// MARK: - Playlist Entry

/// Represents a playlist entry from the SR music research page.
struct PlaylistEntry: Equatable {
    let time: String
    let title: String
    let artist: String
    let date: Date?
}

// MARK: - Now Playing Service

/// Service for fetching now-playing information from SR stations.
///
/// NowPlayingService polls SR's EPG API and music research page to get
/// current track and show information. Only works for SR stations.
final class NowPlayingService: ObservableObject {
    @Published var currentData: NowPlayingData?
    @Published var isLoading = false
    @Published var lastError: NowPlayingError?

    private var cancellables = Set<AnyCancellable>()
    private var timer: Timer?
    private let pollInterval: TimeInterval = 30.0
    private var currentStationId: String?

    // MARK: - Cache Configuration

    /// Maximum age of cached playlist data (5 minutes)
    private let playlistCacheMaxAge: TimeInterval = 300.0

    /// Maximum age of cached show data (2 minutes)
    private let showCacheMaxAge: TimeInterval = 120.0

    /// Cache for playlist entries to reduce HTML scraping
    private var playlistCache: CachedResponse<[PlaylistEntry]>?

    /// Cache for show data to reduce JSON requests
    private var showCache: CachedResponse<NowPlayingShowData>?

    // MARK: - Date Formatters

    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "de_DE")
        return formatter
    }()

    // MARK: - Station Support

    private static let srStationIds: Set<String> = ["sr1", "sr_kultur", "sr3", "unserding", "antenne_saar"]

    /// Timeout for network requests (seconds)
    private let networkTimeout: TimeInterval = 10.0

    // MARK: - Public Methods

    func startMonitoring(station: Station) {
        stopMonitoring()
        currentStationId = station.id
        isLoading = true
        lastError = nil

        guard Self.srStationIds.contains(station.id) else {
            isLoading = false
            lastError = .stationNotSupported(stationId: station.id, feature: "Now Playing")
            return
        }

        // Clear cache when switching stations
        clearCache()

        fetchNowPlaying(for: station)

        timer = Timer(timeInterval: pollInterval, repeats: true) { [weak self] _ in
            self?.fetchNowPlaying(for: station)
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
        currentStationId = nil
        currentData = nil
    }

    // MARK: - Cache Management

    private func clearCache() {
        playlistCache = nil
        showCache = nil
    }

    private func invalidatePlaylistCache() {
        playlistCache = nil
    }

    private func invalidateShowCache() {
        showCache = nil
    }

    // MARK: - Data Fetching

    private func fetchNowPlaying(for station: Station) {
        guard currentStationId == station.id else { return }

        let apiId = station.id == "sr_kultur" ? "sr2" : station.id

        // Safely create URLs
        guard let songURL = URL(string: "https://musikrecherche.sr.de/\(apiId)/musicresearch.php"),
              let showURL = URL(string: "https://www.sr.de/sr/epg/nowPlaying.jsp?welle=\(apiId)") else {
            print("[NowPlaying] Failed to create URLs for station: \(station.id)")
            isLoading = false
            lastError = .invalidURL("musikrecherche or EPG URL")
            return
        }

        var title = ""
        var artist = ""
        var show = ""
        var moderator = ""
        let group = DispatchGroup()

        print("[NowPlaying] Fetching for station: \(station.id)")

        // Fetch song info from music research page
        group.enter()
        fetchPlaylistEntries(url: songURL, stationId: station.id) { [weak self] result in
            defer { group.leave() }

            switch result {
            case .success(let entries):
                if let current = self?.findCurrentEntry(entries: entries) {
                    title = current.title
                    artist = current.artist
                    print("[NowPlaying] Current song at \(current.time): \(artist) - \(title)")
                } else {
                    print("[NowPlaying] No current song entry found")
                }
            case .failure(let error):
                print("[NowPlaying] Song fetch error: \(error.errorDescription ?? "Unknown")")
            }
        }

        // Fetch show info from EPG API
        group.enter()
        fetchShowData(url: showURL, stationId: station.id) { result in
            switch result {
            case .success(let data):
                show = data.title
                moderator = data.moderator
                print("[NowPlaying] Current show: \(show) with \(moderator)")
            case .failure(let error):
                print("[NowPlaying] Show fetch error: \(error.errorDescription ?? "Unknown")")
            }
            group.leave()
        }

        group.notify(queue: .main) { [weak self] in
            guard let self = self, self.currentStationId == station.id else { return }

            self.currentData = NowPlayingData(
                title: title,
                artist: artist,
                show: show,
                moderator: moderator
            )
            self.isLoading = false
            self.lastError = nil
        }
    }

    // MARK: - Playlist Fetching with Cache

    private func fetchPlaylistEntries(url: URL, stationId: String, completion: @escaping (Result<[PlaylistEntry], RadioError>) -> Void) {
        // Check cache first
        if let cached = playlistCache,
           cached.isValid(maxAge: playlistCacheMaxAge),
           cached.stationId == stationId {
            print("[NowPlaying] Using cached playlist data")
            completion(.success(cached.data))
            return
        }

        let task = URLSession.shared.dataTask(with: songRequest(for: url)) { [weak self] data, response, error in
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }

            guard let data = data else {
                completion(.failure(.noData))
                return
            }

            guard let html = String(data: data, encoding: .utf8) else {
                completion(.failure(.dataConversionFailed))
                return
            }

            let entries = self?.parsePlaylistEntries(from: html) ?? []

            if entries.isEmpty {
                completion(.failure(.contentEmpty))
                return
            }

            // Cache the result
            self?.playlistCache = CachedResponse(
                data: entries,
                timestamp: Date(),
                stationId: stationId
            )

            completion(.success(entries))
        }
        task.resume()
    }

    // MARK: - Show Data Fetching with Cache

    private struct NowPlayingShowData {
        let title: String
        let moderator: String
    }

    private func fetchShowData(url: URL, stationId: String, completion: @escaping (Result<NowPlayingShowData, RadioError>) -> Void) {
        // Check cache first
        if let cached = showCache,
           cached.isValid(maxAge: showCacheMaxAge),
           cached.stationId == stationId {
            print("[NowPlaying] Using cached show data")
            completion(.success(cached.data))
            return
        }

        let task = URLSession.shared.dataTask(with: showRequest(for: url)) { [weak self] data, response, error in
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }

            guard let data = data else {
                completion(.failure(.noData))
                return
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

                guard let nowPlaying = json?["now playing"] as? [String: [String: Any]],
                      let stationData = nowPlaying[stationId] else {
                    completion(.failure(.parseError("Keine Show-Daten gefunden")))
                    return
                }

                let title = stationData["titel"] as? String ?? ""
                let moderator = stationData["moderator"] as? String ?? ""

                let showData = NowPlayingShowData(title: title, moderator: moderator)

                // Cache the result
                self?.showCache = CachedResponse(
                    data: showData,
                    timestamp: Date(),
                    stationId: stationId
                )

                completion(.success(showData))
            } catch {
                completion(.failure(.parseError("JSON Parsing fehlgeschlagen: \(error.localizedDescription)")))
            }
        }
        task.resume()
    }

    // MARK: - URL Request Configuration

    private func songRequest(for url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("text/html,application/xhtml+xml", forHTTPHeaderField: "Accept")
        request.setValue("de-DE,de;q=0.9", forHTTPHeaderField: "Accept-Language")
        request.timeoutInterval = networkTimeout
        return request
    }

    private func showRequest(for url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = networkTimeout
        return request
    }

    // MARK: - HTML Parsing

    private func parsePlaylistEntries(from html: String) -> [PlaylistEntry] {
        // Extract all times, titles, and artists using regex with fallback patterns
        let times = extractMatches(from: html, patterns: NowPlayingPatterns.timeFallbackPatterns)
        let titles = extractMatches(from: html, patterns: NowPlayingPatterns.titleFallbackPatterns)
        let artists = extractMatches(from: html, patterns: NowPlayingPatterns.artistFallbackPatterns)

        // Combine into entries (they should be in same order)
        let count = min(times.count, titles.count, artists.count)

        if count == 0 {
            print("[NowPlaying] Warning: No entries parsed - pattern mismatch possible")
        }

        var entries: [PlaylistEntry] = []
        for i in 0..<count {
            let date = timeFormatter.date(from: times[i])
            entries.append(PlaylistEntry(
                time: times[i],
                title: cleanHTML(titles[i]),
                artist: cleanHTML(artists[i]),
                date: date
            ))
        }

        print("[NowPlaying] Parsed \(entries.count) entries")
        return entries
    }

    /// Extract matches using multiple patterns (fallback chain)
    private func extractMatches(from html: String, patterns: [String]) -> [String] {
        for pattern in patterns {
            let matches = extractMatches(from: html, pattern: pattern)
            if !matches.isEmpty {
                print("[NowPlaying] Pattern matched: \(String(pattern.prefix(40)))...")
                return matches
            }
        }
        print("[NowPlaying] No patterns matched")
        return []
    }

    private func findCurrentEntry(entries: [PlaylistEntry]) -> PlaylistEntry? {
        guard !entries.isEmpty else { return nil }

        let now = Date()
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: now)
        let currentMinute = calendar.component(.minute, from: now)

        // Find entry with time closest to now (but not in the future)
        var bestEntry: PlaylistEntry?
        var smallestDiff: Int = Int.max

        for entry in entries {
            guard let entryDate = entry.date else { continue }
            let entryHour = calendar.component(.hour, from: entryDate)
            let entryMinute = calendar.component(.minute, from: entryDate)

            // Calculate difference in minutes from now
            var diff = (currentHour - entryHour) * 60 + (currentMinute - entryMinute)

            // Handle day wrap (if entry is late night and now is early morning)
            if diff < -720 { // More than 12 hours in future
                diff += 1440 // Add 24 hours
            }

            // We want the most recent entry (smallest positive diff or closest to 0)
            if diff >= 0 && diff < smallestDiff {
                smallestDiff = diff
                bestEntry = entry
            }
        }

        // If no entry found (all in future), take the last one
        return bestEntry ?? entries.last
    }

    private func extractMatches(from html: String, pattern: String) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
            print("[NowPlaying] Invalid regex pattern: \(pattern)")
            return []
        }

        let matches = regex.matches(in: html, options: [], range: NSRange(location: 0, length: html.utf16.count))
        return matches.compactMap { match in
            if let range = Range(match.range(at: 1), in: html) {
                return String(html[range])
            }
            return nil
        }
    }

    private func cleanHTML(_ string: String) -> String {
        return string.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&#039;", with: "'")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
    }
}

// MARK: - Test Extension

extension NowPlayingService {
    /// Expose cleanHTML for testing
    func cleanHTMLForTest(_ string: String) -> String {
        return cleanHTML(string)
    }

    /// Expose parsePlaylistEntries for testing
    func parsePlaylistEntriesForTest(html: String) -> [PlaylistEntry] {
        return parsePlaylistEntries(from: html)
    }
}
