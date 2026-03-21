import Foundation
import Combine

struct PlaylistEntry {
    let time: String
    let title: String
    let artist: String
    let date: Date?
}

final class NowPlayingService: ObservableObject {
    @Published var currentData: NowPlayingData?
    @Published var isLoading = false
    
    private var cancellables = Set<AnyCancellable>()
    private var timer: Timer?
    private let pollInterval: TimeInterval = 30.0
    private var currentStationId: String?
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    func startMonitoring(station: Station) {
        stopMonitoring()
        currentStationId = station.id
        isLoading = true
        
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
    
    private func fetchNowPlaying(for station: Station) {
        guard currentStationId == station.id else { return }
        
        let songUrl = URL(string: "https://musikrecherche.sr.de/\(station.id)/musicresearch.php")!
        let showUrl = URL(string: "https://www.sr.de/sr/epg/nowPlaying.jsp?welle=\(station.id)")!
        
        var title = ""
        var artist = ""
        var show = ""
        var moderator = ""
        let group = DispatchGroup()
        
        print("[NowPlaying] Fetching for station: \(station.id)")
        
        // Fetch song info from music research page
        group.enter()
        URLSession.shared.dataTask(with: songUrl) { [weak self] data, response, error in
            defer { group.leave() }
            
            guard let self = self, let data = data, let html = String(data: data, encoding: .utf8) else {
                print("[NowPlaying] Failed to fetch song data")
                return
            }
            
            // Parse all entries and find closest to current time
            let entries = self.parsePlaylistEntries(from: html)
            if let current = self.findCurrentEntry(entries: entries) {
                title = current.title
                artist = current.artist
                print("[NowPlaying] Current song at \(current.time): \(artist) - \(title)")
            }
        }.resume()
        
        // Fetch show info from EPG API
        group.enter()
        URLSession.shared.dataTask(with: showUrl) { data, response, error in
            defer { group.leave() }
            
            guard let data = data else { return }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                if let nowPlaying = json?["now playing"] as? [String: [String: Any]],
                   let stationData = nowPlaying[station.id] {
                    show = stationData["titel"] as? String ?? ""
                    moderator = stationData["moderator"] as? String ?? ""
                }
            } catch {
                print("[NowPlaying] Show parse error: \(error)")
            }
        }.resume()
        
        group.notify(queue: .main) { [weak self] in
            guard let self = self, self.currentStationId == station.id else { return }
            
            self.currentData = NowPlayingData(
                title: title,
                artist: artist,
                show: show,
                moderator: moderator
            )
            self.isLoading = false
        }
    }
    
    // MARK: - HTML Parsing
    
    private func parsePlaylistEntries(from html: String) -> [PlaylistEntry] {
        var entries: [PlaylistEntry] = []
        
        // Extract all times, titles, and artists using regex
        let timePattern = "musicResearch__Item__Time[^>]*>(\\d{2}:\\d{2})</span>"
        let titlePattern = "musicResearch__Item__Content__Title[^>]*>([^<]+)</div>"
        let artistPattern = "musicResearch__Item__Content__Artist[^>]*>([^<]+)</div>"
        
        let times = extractMatches(from: html, pattern: timePattern)
        let titles = extractMatches(from: html, pattern: titlePattern)
        let artists = extractMatches(from: html, pattern: artistPattern)
        
        // Combine into entries (they should be in same order)
        let count = min(times.count, titles.count, artists.count)
        for i in 0..<count {
            let date = dateFormatter.date(from: times[i])
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
