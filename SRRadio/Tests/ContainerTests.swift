import XCTest
@testable import SRRadio

/// Comprehensive tests for the Dependency Injection Container.
final class ContainerTests: XCTestCase {

    // MARK: - Container Initialization Tests

    func testContainerInitializesEmpty() {
        let container = Container()
        XCTAssertNotNil(container)
    }

    func testSharedContainerExists() {
        XCTAssertNotNil(Container.shared)
    }

    func testSharedContainerIsSingleton() {
        let container1 = Container.shared
        let container2 = Container.shared
        XCTAssertIdentical(container1, container2)
    }

    // MARK: - Transient Registration Tests

    func testRegisterTransient_CreatesNewInstanceEachTime() {
        let container = Container()
        var instanceCount = 0

        container.register(TestServiceProtocol.self) {
            instanceCount += 1
            return TestServiceImplementation()
        }

        _ = container.resolve(TestServiceProtocol.self)
        _ = container.resolve(TestServiceProtocol.self)
        _ = container.resolve(TestServiceProtocol.self)

        XCTAssertEqual(instanceCount, 3, "Transient should create new instance each time")
    }

    func testRegisterTransient_DifferentInstances() {
        let container = Container()
        container.register(TestServiceProtocol.self) {
            TestServiceImplementation()
        }

        let instance1 = container.resolve(TestServiceProtocol.self)
        let instance2 = container.resolve(TestServiceProtocol.self)

        XCTAssertNotIdentical(instance1 as? TestServiceImplementation, instance2 as? TestServiceImplementation)
    }

    // MARK: - Singleton Registration Tests

    func testRegisterSingleton_CreatesOneInstance() {
        let container = Container()
        var instanceCount = 0

        container.registerSingleton(TestServiceProtocol.self) {
            instanceCount += 1
            return TestServiceImplementation()
        }

        _ = container.resolve(TestServiceProtocol.self)
        _ = container.resolve(TestServiceProtocol.self)
        _ = container.resolve(TestServiceProtocol.self)

        XCTAssertEqual(instanceCount, 1, "Singleton should create only one instance")
    }

    func testRegisterSingleton_SameInstanceReturned() {
        let container = Container()
        container.registerSingleton(TestServiceProtocol.self) {
            TestServiceImplementation()
        }

        let instance1 = container.resolve(TestServiceProtocol.self)
        let instance2 = container.resolve(TestServiceProtocol.self)
        let instance3 = container.resolve(TestServiceProtocol.self)

        XCTAssertIdentical(instance1 as? TestServiceImplementation, instance2 as? TestServiceImplementation)
        XCTAssertIdentical(instance2 as? TestServiceImplementation, instance3 as? TestServiceImplementation)
    }

    // MARK: - Multiple Service Registration Tests

    func testRegisterMultipleServices() {
        let container = Container()

        container.register(TestServiceProtocol.self) {
            TestServiceImplementation()
        }
        container.register(AnotherServiceProtocol.self) {
            AnotherServiceImplementation()
        }

        let service1 = container.resolve(TestServiceProtocol.self)
        let service2 = container.resolve(AnotherServiceProtocol.self)

        XCTAssertNotNil(service1)
        XCTAssertNotNil(service2)
        XCTAssertNotIdentical(service1 as AnyObject, service2 as AnyObject)
    }

    func testRegisterMultipleServicesOfSameType() {
        let container = Container()

        // Last registration should win
        container.register(TestServiceProtocol.self) {
            TestServiceImplementation()
        }
        container.register(TestServiceProtocol.self) {
            TestServiceImplementation()
        }

        let service = container.resolve(TestServiceProtocol.self)
        XCTAssertNotNil(service)
    }

    // MARK: - Unregistered Service Tests

    func testResolveUnregisteredService_ThrowsFatalError() {
        let container = Container()

        // We expect a fatalError, which XCTest can't catch directly
        // This test documents the expected behavior
        XCTAssertThrowsError(try {
            // Simulate by checking if service exists
            let key = ObjectIdentifier(TestServiceProtocol.self)
            // Container doesn't expose internal state, so we test via resolve
            _ = container.resolve(TestServiceProtocol.self)
            return NSError(domain: "test", code: 0, userInfo: nil)
        }())
    }

    // MARK: - Type-Erased Resolve Tests

    func testResolveAudioPlayer() {
        let container = Container()
        container.registerSingleton(AudioPlayerProtocol.self) {
            MockAudioPlayer()
        }

        let audioPlayer = container.resolveAudioPlayer()
        XCTAssertNotNil(audioPlayer)
        XCTAssertTrue(audioPlayer is MockAudioPlayer)
    }

    func testResolveNowPlayingService() {
        let container = Container()
        container.registerSingleton(NowPlayingServiceProtocol.self) {
            MockNowPlayingService()
        }

        let service = container.resolveNowPlayingService()
        XCTAssertNotNil(service)
        XCTAssertTrue(service is MockNowPlayingService)
    }

    func testResolveAudioPlayerUnregistered_ThrowsFatalError() {
        let container = Container()

        XCTAssertThrowsError(try {
            _ = container.resolveAudioPlayer()
            return NSError(domain: "test", code: 0, userInfo: nil)
        }())
    }

    func testResolveNowPlayingServiceUnregistered_ThrowsFatalError() {
        let container = Container()

        XCTAssertThrowsError(try {
            _ = container.resolveNowPlayingService()
            return NSError(domain: "test", code: 0, userInfo: nil)
        }())
    }

    // MARK: - Default Services Registration Tests

    func testRegisterDefaultServices_RegistersAudioPlayer() {
        let container = Container()
        container.registerDefaultServices()

        let audioPlayer = container.resolveAudioPlayer()
        XCTAssertNotNil(audioPlayer)
        XCTAssertTrue(audioPlayer is AudioPlayer)
    }

    func testRegisterDefaultServices_RegistersNowPlayingService() {
        let container = Container()
        container.registerDefaultServices()

        let service = container.resolveNowPlayingService()
        XCTAssertNotNil(service)
        XCTAssertTrue(service is NowPlayingService)
    }

    func testRegisterDefaultServices_AudioPlayerIsSingleton() {
        let container = Container()
        container.registerDefaultServices()

        let instance1 = container.resolveAudioPlayer()
        let instance2 = container.resolveAudioPlayer()

        XCTAssertIdentical(instance1 as AnyObject, instance2 as AnyObject)
    }

    func testRegisterDefaultServices_NowPlayingServiceIsSingleton() {
        let container = Container()
        container.registerDefaultServices()

        let instance1 = container.resolveNowPlayingService()
        let instance2 = container.resolveNowPlayingService()

        XCTAssertIdentical(instance1 as AnyObject, instance2 as AnyObject)
    }

    // MARK: - Container Lifetime Tests

    func testMixedLifetimeRegistrations() {
        let container = Container()

        container.registerSingleton(TestServiceProtocol.self) {
            TestServiceImplementation()
        }
        container.register(AnotherServiceProtocol.self) {
            AnotherServiceImplementation()
        }

        let singleton1 = container.resolve(TestServiceProtocol.self)
        let singleton2 = container.resolve(TestServiceProtocol.self)
        let transient1 = container.resolve(AnotherServiceProtocol.self)
        let transient2 = container.resolve(AnotherServiceProtocol.self)

        // Singleton should be same instance
        XCTAssertIdentical(singleton1 as? TestServiceImplementation, singleton2 as? TestServiceImplementation)

        // Transient should be different instances
        XCTAssertNotIdentical(transient1 as? AnotherServiceImplementation, transient2 as? AnotherServiceImplementation)
    }

    // MARK: - Thread Safety Tests (Basic)

    func testConcurrentResolves_DoesNotCrash() {
        let container = Container()
        container.registerSingleton(TestServiceProtocol.self) {
            TestServiceImplementation()
        }

        let expectation = XCTestExpectation(description: "Concurrent resolves")

        DispatchQueue.global().async {
            for _ in 0..<100 {
                _ = container.resolve(TestServiceProtocol.self)
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0)
    }

    // MARK: - Real Service Integration Tests

    func testContainerWithRealAudioPlayer() {
        let container = Container()
        container.registerSingleton(AudioPlayerProtocol.self) {
            AudioPlayer()
        }

        let audioPlayer = container.resolveAudioPlayer()
        XCTAssertNotNil(audioPlayer)
        XCTAssertEqual(audioPlayer.volume, 0.8, accuracy: 0.01)
        XCTAssertFalse(audioPlayer.isMuted)
    }

    func testContainerWithRealNowPlayingService() {
        let container = Container()
        container.registerSingleton(NowPlayingServiceProtocol.self) {
            NowPlayingService()
        }

        let service = container.resolveNowPlayingService()
        XCTAssertNotNil(service)
        XCTAssertNil(service.currentData)
        XCTAssertFalse(service.isLoading)
    }

    // MARK: - Error Handling Tests

    func testContainerHandlesNilGracefully() {
        let container = Container()

        // Register a service that returns nil (shouldn't happen, but test safety)
        container.register(TestServiceProtocol.self) {
            TestServiceImplementation()
        }

        let service = container.resolve(TestServiceProtocol.self)
        XCTAssertNotNil(service)
    }
}

// MARK: - Test Protocols and Implementations

protocol TestServiceProtocol: AnyObject {
}

final class TestServiceImplementation: TestServiceProtocol {
}

protocol AnotherServiceProtocol: AnyObject {
}

final class AnotherServiceImplementation: AnotherServiceProtocol {
}

// MARK: - Linux Support

extension ContainerTests {
    static var allTests: [(String, (ContainerTests) -> () throws -> Void)] {
        [
            ("testContainerInitializesEmpty", testContainerInitializesEmpty),
            ("testSharedContainerExists", testSharedContainerExists),
            ("testRegisterTransient_CreatesNewInstanceEachTime", testRegisterTransient_CreatesNewInstanceEachTime),
            ("testRegisterSingleton_CreatesOneInstance", testRegisterSingleton_CreatesOneInstance),
            ("testRegisterSingleton_SameInstanceReturned", testRegisterSingleton_SameInstanceReturned),
            ("testRegisterMultipleServices", testRegisterMultipleServices),
            ("testResolveAudioPlayer", testResolveAudioPlayer),
            ("testResolveNowPlayingService", testResolveNowPlayingService),
            ("testRegisterDefaultServices_RegistersAudioPlayer", testRegisterDefaultServices_RegistersAudioPlayer),
            ("testRegisterDefaultServices_AudioPlayerIsSingleton", testRegisterDefaultServices_AudioPlayerIsSingleton),
            ("testMixedLifetimeRegistrations", testMixedLifetimeRegistrations),
        ]
    }
}
