import Foundation
import Combine

final class NowPlayingService: ObservableObject {
    @Published var currentData: NowPlayingData?
    @Published var isLoading = false
    
    private var cancellables = Set<AnyCancellable>()
    private var timer: Timer?
    private let pollInterval: TimeInterval = 30.0
    private var currentStationId: String?
    
    func startMonitoring(station: Station) {
        stopMonitoring()
        currentStationId = station.id
        isLoading = true
        
        // Fetch immediately
        fetchNowPlaying(for: station)
        
        // Set up timer on main run loop
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
        
        // Use the music research page for song info
        let songUrl = URL(string: "https://musikrecherche.sr.de/\(station.id)/musicresearch.php")!
        // Use the EPG API for show info
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
            
            if let error = error {
                print("[NowPlaying] Song fetch error: \(error)")
                return
            }
            
            guard let data = data, let html = String(data: data, encoding: .utf8) else {
                print("[NowPlaying] No song data received")
                return
            }
            
            // Parse HTML to extract first song (current)
            if let parsedTitle = self?.extractFirstTitle(from: html),
               let parsedArtist = self?.extractFirstArtist(from: html) {
                title = parsedTitle
                artist = parsedArtist
                print("[NowPlaying] Parsed song: \(artist) - \(title)")
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
            
            print("[NowPlaying] Updated: \(artist) - \(title) | Show: \(show)")
        }
    }
    
    // MARK: - HTML Parsing
    
    private func extractFirstTitle(from html: String) -> String? {
        // Find the first occurrence of musicResearch__Item__Content__Title
        let pattern = "musicResearch__Item__Content__Title[^>]*>([^<]+)</div>"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
              let match = regex.firstMatch(in: html, options: [], range: NSRange(location: 0, length: html.utf16.count)) else {
            return nil
        }
        
        if let range = Range(match.range(at: 1), in: html) {
            let title = String(html[range]).trimmingCharacters(in: .whitespacesAndNewlines)
            // Clean up HTML entities
            return title.replacingOccurrences(of: "&amp;", with: "&")
                       .replacingOccurrences(of: "&#039;", with: "'")
                       .replacingOccurrences(of: "&quot;", with: "\"")
        }
        return nil
    }
    
    private func extractFirstArtist(from html: String) -> String? {
        // Find the first occurrence of musicResearch__Item__Content__Artist
        let pattern = "musicResearch__Item__Content__Artist[^>]*>([^<]+)</div>"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
              let match = regex.firstMatch(in: html, options: [], range: NSRange(location: 0, length: html.utf16.count)) else {
            return nil
        }
        
        if let range = Range(match.range(at: 1), in: html) {
            let artist = String(html[range]).trimmingCharacters(in: .whitespacesAndNewlines)
            // Clean up HTML entities
            return artist.replacingOccurrences(of: "&amp;", with: "&")
                         .replacingOccurrences(of: "&#039;", with: "'")
                         .replacingOccurrences(of: "&quot;", with: "\"")
        }
        return nil
    }
}
