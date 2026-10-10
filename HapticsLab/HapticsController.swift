import CoreHaptics
import Observation
import UIKit

/// Native framework objects and observable UI state belong to MainActor.
/// Async engine startup suspends without blocking it; no detached task or
/// unchecked Sendable wrapper is needed for Core Haptics objects.
@MainActor
@Observable
final class HapticsController {
    private(set) var isPlaying = false
    private(set) var status = "Ready"
    private(set) var errorMessage: String?
    let supportsCustomHaptics = CHHapticEngine.capabilitiesForHardware().supportsHaptics

    @ObservationIgnored private var engine: CHHapticEngine?
    @ObservationIgnored private var engineIdentity: UUID?
    @ObservationIgnored private var player: (any CHHapticAdvancedPatternPlayer)?
    @ObservationIgnored private var startupTask: Task<Void, Never>?
    @ObservationIgnored private var generation: UInt64 = 0

    func recordNativeRequest(_ title: String) {
        status = "Requested: " + title
    }

    func playCustom(_ configuration: CustomHapticConfiguration) {
        guard !isPlaying else { return }
        errorMessage = nil
        guard supportsCustomHaptics else {
            status = "Custom haptics require supported physical hardware."
            return
        }
        generation &+= 1
        let token = generation
        isPlaying = true
        status = "Starting custom haptic"
        startupTask = Task { [weak self] in
            guard let self else { return }
            do {
                let events = try configuration.events()
                let engine = try makeEngine()
                try await engine.start()
                guard token == generation, !Task.isCancelled else {
                    try? await engine.stop()
                    return
                }
                let pattern = try Self.pattern(configuration, events: events)
                let player = try engine.makeAdvancedPlayer(with: pattern)
                player.completionHandler = { [weak self] error in
                    let message = error?.localizedDescription
                    Task { @MainActor [weak self] in
                        self?.finish(token: token, error: message)
                    }
                }
                self.player = player
                try player.start(atTime: CHHapticTimeImmediate)
                status = "Playing custom haptic"
                startupTask = nil
            } catch {
                guard token == generation else { return }
                finish(token: token, error: error is CancellationError ? nil : error.localizedDescription)
            }
        }
    }

    func stop() {
        generation &+= 1
        startupTask?.cancel()
        startupTask = nil
        try? player?.stop(atTime: CHHapticTimeImmediate)
        player = nil
        let oldEngine = engine
        engine = nil
        engineIdentity = nil
        oldEngine?.stop(completionHandler: nil)
        isPlaying = false
        status = "Stopped"
    }

    func clearError() { errorMessage = nil }

    private func makeEngine() throws -> CHHapticEngine {
        if let engine { return engine }
        let newEngine = try CHHapticEngine()
        newEngine.playsHapticsOnly = true
        newEngine.isAutoShutdownEnabled = true
        let identity = UUID()
        engineIdentity = identity
        newEngine.stoppedHandler = { [weak self] _ in
            Task { @MainActor [weak self] in self?.handleInterruption(identity: identity) }
        }
        newEngine.resetHandler = { [weak self] in
            Task { @MainActor [weak self] in self?.handleInterruption(identity: identity) }
        }
        engine = newEngine
        return newEngine
    }

    private func handleInterruption(identity: UUID) {
        guard identity == engineIdentity else { return }
        let wasPlaying = isPlaying
        let previousStatus = status
        stop()
        // Normal idle shutdown after completion is not interrupted playback.
        status = wasPlaying ? "Playback interrupted. Tap Play to try again." : previousStatus
    }

    private func finish(token: UInt64, error: String?) {
        guard token == generation else { return }
        isPlaying = false
        player = nil
        startupTask = nil
        errorMessage = error
        status = error == nil ? "Custom haptic finished" : "Playback failed"
    }

    static func pattern(_ configuration: CustomHapticConfiguration,
                        events: [CustomHapticConfiguration.Event]) throws -> CHHapticPattern {
        try CHHapticPattern(events: events.map {
            CHHapticEvent(
                eventType: configuration.kind == .transient ? .hapticTransient : .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(configuration.intensity)),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: Float(configuration.sharpness))
                ],
                relativeTime: $0.time,
                duration: $0.duration
            )
        }, parameters: [])
    }
}
