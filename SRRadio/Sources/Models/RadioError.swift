import Foundation

/// Comprehensive error types for the Saar Streams radio application.
///
/// `RadioError` provides a unified error handling approach across all services,
/// enabling consistent error reporting and user-friendly error messages.
///
/// ## Usage
/// ```swift
/// do {
///     try station.url()
/// } catch RadioError.invalidURL(let urlString) {
///     print("Invalid URL: \(urlString)")
/// } catch {
///     print("Error: \(error.localizedDescription)")
/// }
/// ```
enum RadioError: LocalizedError, Equatable {
    // MARK: - URL Errors

    /// The URL string provided was invalid or malformed.
    /// - Parameter urlString: The invalid URL string
    case invalidURL(String)

    // MARK: - Network Errors

    /// A network error occurred during a request.
    /// - Parameter underlyingError: The underlying NSError from URLSession
    case networkError(Error)

    /// No data was received from the network request.
    case noData

    // MARK: - Stream Errors

    /// Failed to load the radio stream.
    /// - Parameter stationId: The ID of the station that failed to load
    case streamLoadFailed(String)

    /// The stream ended unexpectedly.
    case streamEndedUnexpectedly

    // MARK: - Parsing Errors

    /// Failed to parse data (JSON, HTML, etc.).
    /// - Parameter reason: A description of what went wrong
    case parseError(String)

    /// Data conversion failed (e.g., Data to String conversion).
    case dataConversionFailed

    // MARK: - Audio Session Errors

    /// Failed to configure the audio session.
    /// - Parameter underlyingError: The underlying AVAudioSession error
    case audioSessionFailed(Error)

    // MARK: - Activity/Extension Errors

    /// Failed to start or update a Live Activity.
    /// - Parameter reason: A description of what went wrong
    case liveActivityFailed(String)

    /// Live Activities are not authorized or enabled.
    case liveActivityNotAuthorized

    // MARK: - Station Errors

    /// The station is not supported for a specific feature.
    /// - Parameter stationId: The ID of the unsupported station
    /// - Parameter feature: The feature that is not supported
    case stationNotSupported(stationId: String, feature: String)

    /// The playlist or content is empty.
    case contentEmpty

    // MARK: - LocalizedError Conformance

    /// A human-readable description of the error in German.
    var errorDescription: String? {
        switch self {
        case .invalidURL(let urlString):
            return "Ungültige URL: \(urlString)"

        case .networkError(let error):
            return "Netzwerkfehler: \(error.localizedDescription)"

        case .noData:
            return "Keine Daten erhalten"

        case .streamLoadFailed(let stationId):
            return "Stream für \(stationId) konnte nicht geladen werden"

        case .streamEndedUnexpectedly:
            return "Stream unerwartet beendet"

        case .parseError(let reason):
            return "Parsing fehlgeschlagen: \(reason)"

        case .dataConversionFailed:
            return "Datenkonvertierung fehlgeschlagen"

        case .audioSessionFailed(let error):
            return "Audio-Session fehlgeschlagen: \(error.localizedDescription)"

        case .liveActivityFailed(let reason):
            return "Live Activity fehlgeschlagen: \(reason)"

        case .liveActivityNotAuthorized:
            return "Live Activities sind nicht autorisiert"

        case .stationNotSupported(let stationId, let feature):
            return "Station \(stationId) unterstützt \(feature) nicht"

        case .contentEmpty:
            return "Keine Inhalte verfügbar"
        }
    }

    // MARK: - User-Friendly Messages

    /// A user-friendly error message suitable for display in the UI.
    /// All messages are in German for consistency with the app's UI.
    var userMessage: String {
        switch self {
        case .invalidURL:
            return "Verbindungsfehler"

        case .networkError:
            return "Keine Internetverbindung"

        case .noData, .contentEmpty:
            return "Keine Informationen verfügbar"

        case .streamLoadFailed, .streamEndedUnexpectedly:
            return "Stream nicht verfügbar"

        case .parseError, .dataConversionFailed:
            return "Datenfehler"

        case .audioSessionFailed:
            return "Audio-Fehler"

        case .liveActivityFailed, .liveActivityNotAuthorized:
            return "Live Activity nicht verfügbar"

        case .stationNotSupported:
            return "Nicht unterstützt"
        }
    }

    /// A detailed error message for debugging/development.
    var debugDescription: String {
        switch self {
        case .invalidURL(let urlString):
            return "[RadioError] Invalid URL: \(urlString)"

        case .networkError(let error):
            return "[RadioError] Network error: \(error.localizedDescription)"

        case .noData:
            return "[RadioError] No data received"

        case .streamLoadFailed(let stationId):
            return "[RadioError] Stream load failed for station: \(stationId)"

        case .streamEndedUnexpectedly:
            return "[RadioError] Stream ended unexpectedly"

        case .parseError(let reason):
            return "[RadioError] Parse error: \(reason)"

        case .dataConversionFailed:
            return "[RadioError] Data conversion failed"

        case .audioSessionFailed(let error):
            return "[RadioError] Audio session error: \(error.localizedDescription)"

        case .liveActivityFailed(let reason):
            return "[RadioError] Live activity error: \(reason)"

        case .liveActivityNotAuthorized:
            return "[RadioError] Live activities not authorized"

        case .stationNotSupported(let stationId, let feature):
            return "[RadioError] Station \(stationId) does not support: \(feature)"

        case .contentEmpty:
            return "[RadioError] Content is empty"
        }
    }

    // MARK: - Equatable Conformance

    static func == (lhs: RadioError, rhs: RadioError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL(let l), .invalidURL(let r)):
            return l == r
        case (.networkError, .networkError):
            return true // Error comparison not reliable
        case (.noData, .noData):
            return true
        case (.streamLoadFailed(let l), .streamLoadFailed(let r)):
            return l == r
        case (.streamEndedUnexpectedly, .streamEndedUnexpectedly):
            return true
        case (.parseError(let l), .parseError(let r)):
            return l == r
        case (.dataConversionFailed, .dataConversionFailed):
            return true
        case (.audioSessionFailed, .audioSessionFailed):
            return true
        case (.liveActivityFailed(let l), .liveActivityFailed(let r)):
            return l == r
        case (.liveActivityNotAuthorized, .liveActivityNotAuthorized):
            return true
        case (.stationNotSupported(let lStation, let lFeature), .stationNotSupported(let rStation, let rFeature)):
            return lStation == rStation && lFeature == rFeature
        case (.contentEmpty, .contentEmpty):
            return true
        default:
            return false
        }
    }
}

// MARK: - Error Conversion Extensions

extension RadioError {
    /// Creates a RadioError from a generic Error.
    /// - Parameter error: The error to convert
    /// - Returns: A RadioError instance
    static func from(_ error: Error) -> RadioError {
        if let radioError = error as? RadioError {
            return radioError
        }
        return .networkError(error)
    }
}
