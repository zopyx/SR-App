import Foundation

/// Represents the current state of the radio player.
///
/// The player cycles through these states:
/// - Started: Initial state, player is ready but not actively streaming
/// - Buffering: Connecting to stream and loading audio data
/// - Playing: Audio is actively playing
/// - Paused: Playback was stopped/paused by user
/// - Muted: Audio playback is muted (visual overlay on Playing or Paused)
/// - Error: An error occurred during playback
enum PlayerState: Equatable {
    case started
    case buffering
    case playing
    case paused
    case muted(underlying: MutedUnderlyingState)
    case error(String)
    
    /// The underlying state when muted (either playing or paused)
    enum MutedUnderlyingState: Equatable {
        case playing
        case paused
    }
    
    /// Returns true if audio is currently playing (not muted, not buffering, not error)
    var isPlaying: Bool {
        switch self {
        case .playing:
            return true
        case .muted(let underlying):
            return underlying == .playing
        default:
            return false
        }
    }
    
    /// Returns true if the player is in buffering state
    var isBuffering: Bool {
        if case .buffering = self { return true }
        return false
    }
    
    /// Returns true if the player is paused
    var isPaused: Bool {
        if case .paused = self { return true }
        return false
    }
    
    /// Returns true if the player is muted
    var isMuted: Bool {
        if case .muted = self { return true }
        return false
    }
    
    /// Returns true if the player has encountered an error
    var isError: Bool {
        if case .error = self { return true }
        return false
    }
    
    /// Returns the user-facing status text for this state
    var statusText: String {
        switch self {
        case .started:
            return "BEREIT"
        case .buffering:
            return "PUFFERN"
        case .playing:
            return "AUF SENDUNG"
        case .paused:
            return "PAUSIERT"
        case .muted(let underlying):
            switch underlying {
            case .playing:
                return "STUMM"
            case .paused:
                return "PAUSIERT"  // Muted while paused still shows as paused
            }
        case .error:
            return "FEHLER"
        }
    }
    
    /// Returns the SF Symbol name for this state's indicator
    var indicatorIcon: String {
        switch self {
        case .started:
            return "circle.fill"
        case .buffering:
            return "arrow.clockwise.circle.fill"
        case .playing:
            return "waveform"
        case .paused:
            return "stop.fill"
        case .muted:
            return "speaker.slash.fill"
        case .error:
            return "exclamationmark.triangle.fill"
        }
    }
}
