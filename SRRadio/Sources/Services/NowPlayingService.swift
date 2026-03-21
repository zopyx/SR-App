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
        
        let showUrl = URL(string: "https://www.sr.de/sr/epg/nowPlaying.jsp?welle=\(station.id)")!
        
        print("[NowPlaying] Fetching for station: \(station.id)")
        
        URLSession.shared.dataTask(with: showUrl) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("[NowPlaying] Error: \(error)")
            }
            
            guard let data = data else {
                print("[NowPlaying] No data received")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                print("[NowPlaying] JSON: \(json ?? [:])")
                
                if let nowPlaying = json?["now playing"] as? [String: [String: Any]],
                   let stationData = nowPlaying[station.id] {
                    
                    let show = stationData["titel"] as? String ?? ""
                    let moderator = stationData["moderator"] as? String ?? ""
                    
                    print("[NowPlaying] Show: \(show), Moderator: \(moderator)")
                    
                    DispatchQueue.main.async {
                        guard self.currentStationId == station.id else { return }
                        self.currentData = NowPlayingData(
                            title: "",
                            artist: "",
                            show: show,
                            moderator: moderator
                        )
                        self.isLoading = false
                    }
                } else {
                    DispatchQueue.main.async {
                        self.isLoading = false
                    }
                }
            } catch {
                print("[NowPlaying] Parse error: \(error)")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }.resume()
    }
}
