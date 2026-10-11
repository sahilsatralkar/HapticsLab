import CoreHaptics
import XCTest
@testable import HapticsLab

@MainActor
final class HapticSwiftExportTests: XCTestCase {
    private func capabilities(envelope: Bool = true) throws -> HapticEventCapabilities {
        let range = try HapticParameterRange(minimum: 0, maximum: 1, defaultValue: 0.5)
        let parameters: [HapticParameter] = envelope ? HapticParameter.allCases : [.intensity, .sharpness]
        return HapticEventCapabilities(ranges: Dictionary(uniqueKeysWithValues: parameters.map { ($0, range) }),
                                       unavailable: [:])
    }

    func testContinuousExportMatchesPlaybackValuesAndTiming() throws {
        var draft = CustomHapticConfiguration.defaults
        draft.isContinuous = true
        draft.intensity = 0.123456789
        draft.sharpness = 0.87654321
        draft.duration = 0.456789123
        draft.gap = 0.234567891
        draft.pulseCount = 3
        draft.attack = 0.13579
        draft.release = 0.2468
        let limits = try capabilities()
        let source = try HapticSwiftExport.source(for: draft, capabilities: limits)
        let events = try HapticsController.hapticEvents(draft, capabilities: limits)
        let timing = try NSRegularExpression(pattern: #"relativeTime: ([0-9.eE+-]+), duration: ([0-9.eE+-]+)"#)
        let matches = timing.matches(in: source, range: NSRange(source.startIndex..., in: source))
        XCTAssertEqual(matches.count, events.count)
        for (match, event) in zip(matches, events) {
            let time = try XCTUnwrap(Range(match.range(at: 1), in: source))
            let duration = try XCTUnwrap(Range(match.range(at: 2), in: source))
            XCTAssertEqual(Double(source[time]), event.relativeTime)
            XCTAssertEqual(Double(source[duration]), event.duration)
        }
        for parameter in events[0].eventParameters {
            let name: String
            switch parameter.parameterID {
            case .hapticIntensity: name = "hapticIntensity"
            case .hapticSharpness: name = "hapticSharpness"
            case .attackTime: name = "attackTime"
            case .releaseTime: name = "releaseTime"
            case .sustained: name = "sustained"
            default: return XCTFail("Unexpected active parameter")
            }
            let pattern = "parameterID: \\.\(name), value: ([0-9.eE+-]+)"
            let regex = try NSRegularExpression(pattern: pattern)
            let match = try XCTUnwrap(regex.firstMatch(in: source, range: NSRange(source.startIndex..., in: source)))
            let valueRange = try XCTUnwrap(Range(match.range(at: 1), in: source))
            XCTAssertEqual(Float(source[valueRange]), parameter.value)
        }
        XCTAssertTrue(source.contains("eventType: .hapticContinuous"))
        XCTAssertFalse(source.contains("parameterID: .decayTime"))
        XCTAssertFalse(source.contains("import HapticsLab"))
    }

    func testTransientExportUsesZeroDurationAndDecayWhenNotSustained() throws {
        var draft = CustomHapticConfiguration.defaults
        draft.duration = 29
        draft.pulseCount = 2
        draft.gap = 0.125
        draft.sustained = false
        draft.decay = 0.375
        let source = try HapticSwiftExport.source(for: draft, capabilities: capabilities())
        XCTAssertTrue(source.contains("eventType: .hapticTransient"))
        XCTAssertTrue(source.contains("relativeTime: 0.125, duration: 0.0"))
        XCTAssertTrue(source.contains("parameterID: .sustained, value: 0.0"))
        XCTAssertTrue(source.contains("parameterID: .decayTime, value: 0.375"))
        XCTAssertFalse(source.contains("parameterID: .releaseTime"))
        XCTAssertFalse(source.contains("duration: 29"))
    }

    func testExportOmitsUnavailableEnvelopeAndRejectsInvalidDrafts() throws {
        let limits = try capabilities(envelope: false)
        let source = try HapticSwiftExport.source(for: .defaults, capabilities: limits)
        XCTAssertFalse(source.contains("parameterID: .attackTime"))
        XCTAssertFalse(source.contains("parameterID: .sustained"))
        XCTAssertFalse(source.contains("parameterID: .releaseTime"))
        var draft = CustomHapticConfiguration.defaults
        draft.intensity = .nan
        XCTAssertThrowsError(try HapticSwiftExport.source(for: draft, capabilities: limits))
        draft = .defaults
        draft.intensity = 1.1
        XCTAssertThrowsError(try HapticSwiftExport.source(for: draft, capabilities: limits))
        draft = .defaults
        draft.isContinuous = true
        draft.duration = 0
        XCTAssertThrowsError(try HapticSwiftExport.source(for: draft, capabilities: limits))
        XCTAssertThrowsError(try HapticSwiftExport.source(for: .defaults,
            capabilities: HapticEventCapabilities(ranges: [:], unavailable: [:])))
    }

    func testSharedFileKeepsSnapshotAfterDraftChanges() throws {
        var draft = CustomHapticConfiguration.defaults
        let limits = try capabilities()
        let original = try HapticSwiftExport.source(for: draft, capabilities: limits)
        let file = try HapticShareFile(source: original)
        defer { try? file.remove() }
        draft.intensity = 0.01
        draft.pulseCount = 8
        let saved = try String(contentsOf: file.url, encoding: .utf8)
        XCTAssertEqual(saved, original)
        XCTAssertNotEqual(saved, try HapticSwiftExport.source(for: draft, capabilities: limits))
        XCTAssertEqual(file.url.lastPathComponent, "CustomHaptic.swift")
    }

    func testShareFilesAreIndependentAndCleanUpOnlyTheirOwnDirectory() throws {
        let first = try HapticShareFile(source: "// First snapshot\nlet intensity = 0.25\n")
        defer { try? first.remove() }
        let second = try HapticShareFile(source: "// Second snapshot — SwiftUI\nlet intensity = 0.75\n")
        defer { try? second.remove() }
        XCTAssertNotEqual(first.url, second.url)
        XCTAssertEqual(try String(contentsOf: first.url, encoding: .utf8),
                       "// First snapshot\nlet intensity = 0.25\n")
        XCTAssertEqual(try String(contentsOf: second.url, encoding: .utf8),
                       "// Second snapshot — SwiftUI\nlet intensity = 0.75\n")
        try first.remove()
        try first.remove()
        XCTAssertFalse(FileManager.default.fileExists(atPath: first.url.deletingLastPathComponent().path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: second.url.path))
    }

    func testShareFileReportsPreparationFailure() throws {
        let blocker = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try Data("not a directory".utf8).write(to: blocker)
        defer { try? FileManager.default.removeItem(at: blocker) }
        XCTAssertThrowsError(try HapticShareFile(source: "import SwiftUI", temporaryDirectory: blocker))
        XCTAssertEqual(try String(contentsOf: blocker, encoding: .utf8), "not a directory")
    }
}
