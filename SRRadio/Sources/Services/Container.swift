import Foundation

/// A simple dependency injection container.
///
/// Container provides a lightweight approach to managing dependencies
/// without external frameworks. It supports both singleton and transient
/// service registration.
///
/// ## Usage
///
/// ```swift
/// // Register services
/// let container = Container()
/// container.register(AudioPlayerProtocol.self) { AudioPlayer() }
/// container.register(NowPlayingServiceProtocol.self) { NowPlayingService() }
///
/// // Resolve services
/// let audioPlayer = container.resolve(AudioPlayerProtocol.self)
/// ```
///
/// ## Registration Lifetimes
///
/// - **Singleton**: Created once and reused (`.singleton`)
/// - **Transient**: Created new each time (`.transient`, default)
final class Container {
    
    /// Shared global container instance for default dependencies.
    ///
    /// Use this for simple apps that don't need multiple containers.
    /// Call `registerDefaultServices()` once at app launch.
    static let shared = Container()
    
    /// Defines the lifetime of a registered service.
    enum Lifetime {
        /// A single instance is created and reused.
        case singleton
        /// A new instance is created on each resolve.
        case transient
    }
    
    /// Internal storage for registered factories.
    private var services: [ObjectIdentifier: Any] = [:]
    
    /// Internal storage for singleton instances.
    private var singletons: [ObjectIdentifier: Any] = [:]
    
    /// Registers a service with the container.
    ///
    /// - Parameters:
    ///   - protocolType: The protocol type to register.
    ///   - lifetime: The lifetime of the service (default: `.transient`).
    ///   - factory: A closure that creates the service instance.
    func register<Service>(_ protocolType: Service.Type,
                          lifetime: Lifetime = .transient,
                          factory: @escaping () -> Service) {
        let key = ObjectIdentifier(protocolType)
        services[key] = (lifetime, factory)
    }
    
    /// Resolves a service from the container.
    ///
    /// - Parameter protocolType: The protocol type to resolve.
    /// - Returns: An instance of the service.
    /// - Precondition: The service must be registered.
    func resolve<Service>(_ protocolType: Service.Type) -> Service {
        let key = ObjectIdentifier(protocolType)
        
        guard let service = services[key] else {
            fatalError("Service \(Service.self) not registered in Container")
        }
        
        let (lifetime, factory) = service as! (Lifetime, () -> Service)
        
        switch lifetime {
        case .singleton:
            if let instance = singletons[key] as? Service {
                return instance
            }
            let instance = factory()
            singletons[key] = instance
            return instance
            
        case .transient:
            return factory()
        }
    }
    
    /// Convenience method to register a singleton.
    func registerSingleton<Service>(_ protocolType: Service.Type,
                                   factory: @escaping () -> Service) {
        register(protocolType, lifetime: .singleton, factory: factory)
    }
    
    // MARK: - Type-Erased Resolve (for 'any' protocols)
    
    /// Resolves a service using ObjectIdentifier for type-erased protocols.
    func resolveAudioPlayer() -> any AudioPlayerProtocol {
        let key = ObjectIdentifier(AudioPlayerProtocol.self)
        guard let service = services[key] else {
            fatalError("AudioPlayerProtocol not registered in Container")
        }
        let (lifetime, factory) = service as! (Lifetime, () -> any AudioPlayerProtocol)
        
        switch lifetime {
        case .singleton:
            if let instance = singletons[key] as? (any AudioPlayerProtocol) {
                return instance
            }
            let instance = factory()
            singletons[key] = instance
            return instance
        case .transient:
            return factory()
        }
    }
    
    /// Resolves a service using ObjectIdentifier for type-erased protocols.
    func resolveNowPlayingService() -> any NowPlayingServiceProtocol {
        let key = ObjectIdentifier(NowPlayingServiceProtocol.self)
        guard let service = services[key] else {
            fatalError("NowPlayingServiceProtocol not registered in Container")
        }
        let (lifetime, factory) = service as! (Lifetime, () -> any NowPlayingServiceProtocol)
        
        switch lifetime {
        case .singleton:
            if let instance = singletons[key] as? (any NowPlayingServiceProtocol) {
                return instance
            }
            let instance = factory()
            singletons[key] = instance
            return instance
        case .transient:
            return factory()
        }
    }
    
    /// Resolves a service using ObjectIdentifier for type-erased protocols.
    @available(iOS 16.2, *)
    func resolveLiveActivityManager() -> (any LiveActivityManagerProtocol)? {
        let key = ObjectIdentifier(LiveActivityManagerProtocol.self)
        guard let service = services[key] else {
            fatalError("LiveActivityManagerProtocol not registered in Container")
        }
        let (lifetime, factory) = service as! (Lifetime, () -> (any LiveActivityManagerProtocol)?)

        switch lifetime {
        case .singleton:
            if let instance = singletons[key] {
                return instance as? (any LiveActivityManagerProtocol)
            }
            let instance = factory()
            singletons[key] = instance as Any
            return instance
        case .transient:
            return factory()
        }
    }
}

// MARK: - Default Registration

extension Container {
    
    /// Registers all default services for the app.
    ///
    /// Call this method to set up the standard production dependencies.
    func registerDefaultServices() {
        // Register AudioPlayer as singleton (manages audio session)
        registerSingleton(AudioPlayerProtocol.self) {
            AudioPlayer()
        }
        
        // Register NowPlayingService as singleton (manages polling)
        registerSingleton(NowPlayingServiceProtocol.self) {
            NowPlayingService()
        }
        
        // Register LiveActivityManager as singleton (iOS 16.2+)
        if #available(iOS 16.2, *) {
            registerSingleton(LiveActivityManagerProtocol.self) {
                LiveActivityManager.shared
            }
        }
    }
}
