import Foundation
import Combine
import ActivityKit

// MARK: - Audio Player Protocol

/// Protocol defining the interface for audio playback functionality.
///
/// This protocol abstracts the audio player implementation, allowing for
/// dependency injection and easier testing.
protocol AudioPlayerProtocol: ObservableObject {
    /// The current playback state.
    var state: PlaybackState { get }
    
    /// The current volume level (0.0 to 1.0).
    var volume: Double { get set }
    
    /// Whether audio is currently muted.
    var isMuted: Bool { get set }
    
    /// The current error state, if any.
    var currentError: RadioError? { get }
    
    /// Publisher for currentError changes.
    var currentErrorPublisher: Published<RadioError?>.Publisher { get }
    
    /// The currently playing station, if any.
    var currentStation: Station? { get }
    
    /// Loads a radio station and optionally starts playback.
    /// - Parameters:
    ///   - station: The station to load
    ///   - autoPlay: Whether to automatically start playback after loading
    func loadStation(_ station: Station, autoPlay: Bool)
    
    /// Starts or resumes audio playback.
    func play()
    
    /// Pauses the current playback.
    func pause()
    
    /// Toggles between play and pause states.
    func togglePlayPause()
    
    /// Toggles the mute state.
    func toggleMute()
    
    /// Clears the current error state and attempts to reload the station.
    func retryAfterError()
}

// MARK: - Now Playing Service Protocol

/// Protocol defining the interface for fetching now-playing information.
///
/// This protocol abstracts the now-playing service implementation, allowing for
/// dependency injection and easier testing.
protocol NowPlayingServiceProtocol: ObservableObject {
    /// The current now-playing data.
    var currentData: NowPlayingData? { get }
    
    /// Whether the service is currently loading data.
    var isLoading: Bool { get }
    
    /// The last error that occurred, if any.
    var lastError: RadioError? { get }
    
    /// Starts monitoring now-playing information for a station.
    /// - Parameter station: The station to monitor.
    func startMonitoring(station: Station)
    
    /// Stops monitoring now-playing information.
    func stopMonitoring()
}

// MARK: - Live Activity Manager Protocol

/// Protocol defining the interface for managing Live Activities.
///
/// This protocol abstracts the Live Activity manager implementation, allowing for
/// dependency injection and easier testing.
@available(iOS 16.2, *)
protocol LiveActivityManagerProtocol {
    /// The current active Live Activity, if any.
    var currentActivity: Activity<SRRadioAttributes>? { get }
    
    /// The current error state, if any.
    var currentError: RadioError? { get }
    
    /// Starts a new Live Activity for the given station.
    /// - Parameters:
    ///   - station: The station to display in the activity.
    ///   - state: The initial content state.
    func startActivity(station: Station, state: SRRadioAttributes.ContentState)
    
    /// Updates the current Live Activity with new state.
    /// - Parameter state: The new content state.
    func updateActivity(state: SRRadioAttributes.ContentState)
    
    /// Ends the current Live Activity.
    func endActivity()
}

// MARK: - Default Implementations

// AudioPlayer already conforms to AudioPlayerProtocol via extension below
extension AudioPlayer: AudioPlayerProtocol {}

// NowPlayingService already conforms to NowPlayingServiceProtocol
extension NowPlayingService: NowPlayingServiceProtocol {}

// LiveActivityManager already conforms to LiveActivityManagerProtocol
@available(iOS 16.2, *)
extension LiveActivityManager: LiveActivityManagerProtocol {}
