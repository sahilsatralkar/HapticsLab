import CoreHaptics
import XCTest
@testable import HapticsLab

@MainActor
final class HapticCurveTests: XCTestCase {
    private func limits(dynamic: Bool = true) throws -> HapticEventCapabilities {
        let range = try HapticParameterRange(minimum: 0, maximum: 1, defaultValue: 0.5)
        return HapticEventCapabilities(
            ranges: Dictionary(uniqueKeysWithValues: HapticParameter.allCases.map { ($0, range) }),
            unavailable: [:],
            dynamicRanges: dynamic ? [
                .intensity: try HapticParameterRange(minimum: 0, maximum: 1, defaultValue: 1),
                .sharpness: try HapticParameterRange(minimum: -1, maximum: 1, defaultValue: 0)
            ] : [:])
    }

    private func draft() -> CustomHapticConfiguration {
        var value = CustomHapticConfiguration.defaults
        value.isContinuous = true
        value.duration = 1.2
        value.setVariation(true)
        value.curvePoints[0].intensity = 0.15
        value.curvePoints[0].sharpness = 0.15
        value.curvePoints[1].position = 1.0 / 3.0
        value.curvePoints[1].intensity = 0.95
        value.curvePoints[1].sharpness = 0.65
        value.curvePoints[2].intensity = 0
        value.curvePoints[2].sharpness = 0.2
        return value
    }

    func testInsertionPreservesShapeIdentityAndEnforcesPointLimit() throws {
        var value = draft()
        let before = value.curvePoints
        value.addCurvePoint()
        XCTAssertEqual(value.curvePoints.count, 4)
        for point in before { XCTAssertTrue(value.curvePoints.contains(point)) }
        let added = try XCTUnwrap(value.curvePoints.first { point in !before.contains(where: { $0.id == point.id }) })
        let a = before[1], b = before[2]
        XCTAssertEqual(added.position, (a.position + b.position) / 2)
        XCTAssertEqual(added.intensity, (a.intensity + b.intensity) / 2)
        XCTAssertEqual(added.sharpness, (a.sharpness + b.sharpness) / 2)
        while value.canAddCurvePoint { value.addCurvePoint() }
        XCTAssertEqual(value.curvePoints.count, 16)
        let full = value
        value.addCurvePoint()
        XCTAssertEqual(value, full)
        XCTAssertNoThrow(try limits().validate(value))
    }

    func testDeletionKeepsEndpointsAndAllowsTwoPointCurve() throws {
        var value = draft()
        let start = value.curvePoints[0], end = value.curvePoints[2]
        value.removeCurvePoint(id: start.id)
        value.removeCurvePoint(id: end.id)
        XCTAssertEqual(value.curvePoints.count, 3)
        value.removeCurvePoint(id: value.curvePoints[1].id)
        XCTAssertEqual(value.curvePoints, [start, end])
        XCTAssertNoThrow(try HapticsController.pattern(value, capabilities: limits()))
    }

    func testPointTimesRejectInvalidEditsAndScaleWithDuration() throws {
        var value = draft()
        let id = value.curvePoints[1].id
        for invalid in [0, 1.2, -1, 1.3, .nan, .infinity] {
            let before = value
            XCTAssertNotNil(value.pointTimeError(invalid, id: id))
            value.setPointTime(invalid, id: id)
            XCTAssertEqual(value, before)
        }
        let parsed = try HapticNumberInput.parse("0.3", range: 0...value.duration,
                                                locale: Locale(identifier: "en_US"))
        XCTAssertNil(value.pointTimeError(parsed, id: id))
        value.setPointTime(parsed, id: id)
        XCTAssertEqual(value.curvePoints[1].position * value.duration, 0.3, accuracy: 1e-12)
        value.duration = 2.4
        XCTAssertEqual(value.curvePoints[1].position * value.duration, 0.6, accuracy: 1e-12)
        XCTAssertEqual(value.curvePoints.last?.position, 1)
        XCTAssertNoThrow(try value.events())
    }

    func testValidationRejectsMalformedCurvesBeforePlaybackOrExport() throws {
        let mutations: [(inout CustomHapticConfiguration) -> Void] = [
            { $0.curvePoints = [] },
            { $0.curvePoints = Array($0.curvePoints.prefix(1)) },
            { $0.curvePoints[0].position = 0.1 },
            { $0.curvePoints[2].position = 0.9 },
            { $0.curvePoints[1].position = 0 },
            { $0.curvePoints[1].position = 1.1 },
            { $0.curvePoints[1].position = .nan },
            { $0.curvePoints[1].intensity = .infinity },
            { $0.curvePoints[1].intensity = -0.01 },
            { $0.curvePoints[1].sharpness = 1.01 },
            { $0.curvePoints[1].sharpness = .nan },
            { $0.curvePoints[1] = $0.curvePoints[0] }
        ]
        for mutate in mutations {
            var value = draft()
            mutate(&value)
            XCTAssertThrowsError(try HapticsController.pattern(value, capabilities: limits()))
            XCTAssertThrowsError(try HapticSwiftExport.source(for: value, capabilities: limits()))
        }
        var tooMany = draft()
        tooMany.curvePoints = (0...16).map { HapticCurvePoint(position: Double($0) / 16, intensity: 0.5, sharpness: 0.5) }
        XCTAssertThrowsError(try limits().validate(tooMany))
    }

    func testDynamicCapabilitiesAreRequiredAndNeverInvented() throws {
        let value = draft()
        XCTAssertThrowsError(try HapticsController.pattern(value, capabilities: limits(dynamic: false)))
        var partial = try limits()
        partial.dynamicRanges.removeValue(forKey: .sharpness)
        XCTAssertThrowsError(try HapticSwiftExport.source(for: value, capabilities: partial))
        var restricted = try limits()
        restricted.dynamicRanges[.sharpness] = try HapticParameterRange(minimum: 0, maximum: 0.1, defaultValue: 0)
        XCTAssertThrowsError(try restricted.validate(value))
        let original = try limits()
        var ranges = original.ranges
        ranges[.intensity] = try HapticParameterRange(minimum: 0.2, maximum: 1, defaultValue: 0.5)
        let narrowerEvent = HapticEventCapabilities(ranges: ranges, unavailable: [:],
                                                   dynamicRanges: original.dynamicRanges)
        XCTAssertThrowsError(try narrowerEvent.validate(value))
    }

    func testCurvesMapEffectiveValuesToAppleMultiplierAndOffset() throws {
        let value = draft()
        let events = try HapticsController.hapticEvents(value, capabilities: limits())
        let curves = try HapticsController.parameterCurves(value, capabilities: limits())
        XCTAssertEqual(curves.count, 2)
        let intensity = try XCTUnwrap(events.first?.eventParameters.first { $0.parameterID == .hapticIntensity })
        let sharpness = try XCTUnwrap(events.first?.eventParameters.first { $0.parameterID == .hapticSharpness })
        for (index, point) in value.curvePoints.enumerated() {
            XCTAssertEqual(curves[0].controlPoints[index].relativeTime, point.position * value.duration)
            XCTAssertEqual(Double(intensity.value * curves[0].controlPoints[index].value), point.intensity, accuracy: 1e-7)
            XCTAssertEqual(Double(sharpness.value + curves[1].controlPoints[index].value), point.sharpness, accuracy: 1e-7)
        }
        XCTAssertEqual(curves[0].parameterID, .hapticIntensityControl)
        XCTAssertEqual(curves[1].parameterID, .hapticSharpnessControl)
    }

    func testRepetitionsRestartCurvesWithZeroGapAndFullDuration() throws {
        var value = draft()
        value.duration = 30
        value.pulseCount = 8
        while value.canAddCurvePoint { value.addCurvePoint() }
        for gap in [0.0, 2.0] {
            value.gap = gap
            let curves = try HapticsController.parameterCurves(value, capabilities: limits())
            XCTAssertEqual(curves.count, 16)
            for index in 0..<value.pulseCount {
                for curve in curves[(index * 2)..<(index * 2 + 2)] {
                    XCTAssertEqual(curve.relativeTime, Double(index) * (30 + gap))
                    XCTAssertEqual(curve.controlPoints.count, 16)
                    XCTAssertEqual(curve.controlPoints.last?.relativeTime, 30)
                }
            }
            XCTAssertNoThrow(try HapticsController.pattern(value, capabilities: limits()))
        }
    }

    func testAllZeroIntensityProducesFiniteSilentPattern() throws {
        var value = draft()
        for index in value.curvePoints.indices { value.curvePoints[index].intensity = 0 }
        let events = try HapticsController.hapticEvents(value, capabilities: limits())
        XCTAssertEqual(events[0].eventParameters.first { $0.parameterID == .hapticIntensity }?.value, 0)
        let curves = try HapticsController.parameterCurves(value, capabilities: limits())
        XCTAssertTrue(curves[0].controlPoints.allSatisfy { $0.value.isFinite && $0.value == 1 })
        XCTAssertNoThrow(try HapticsController.pattern(value, capabilities: limits()))
    }

    func testConstantAndTransientModesRetainCurvesButDoNotApplyThem() throws {
        var value = draft()
        let points = value.curvePoints
        value.setVariation(false)
        XCTAssertEqual(value.curvePoints, points)
        XCTAssertTrue(try HapticsController.parameterCurves(value, capabilities: limits(dynamic: false)).isEmpty)
        XCTAssertEqual(value.value(for: .intensity), value.intensity)
        value.setVariation(true)
        value.isContinuous = false
        XCTAssertTrue(try HapticsController.parameterCurves(value, capabilities: limits(dynamic: false)).isEmpty)
        XCTAssertEqual(value.curvePoints, points)
        value.isContinuous = true
        XCTAssertEqual(try HapticsController.parameterCurves(value, capabilities: limits()).count, 2)
    }

    func testCurveDraftSnapshotSurvivesNavigationAndResetClearsIt() {
        let controller = HapticsController()
        controller.customConfiguration = draft()
        let snapshot = controller.customConfiguration
        controller.stop()
        _ = CustomHapticsView(controller: controller)
        XCTAssertEqual(controller.customConfiguration, snapshot)
        controller.customConfiguration.addCurvePoint()
        XCTAssertNotEqual(controller.customConfiguration, snapshot)
        XCTAssertEqual(snapshot.curvePoints.count, 3)
        controller.resetCustomConfiguration()
        XCTAssertFalse(controller.customConfiguration.variesOverTime)
        XCTAssertTrue(controller.customConfiguration.curvePoints.isEmpty)
        XCTAssertFalse(controller.customConfiguration.isContinuous)
    }

    func testExportContainsExactPlaybackCurvesAndDestinationValidation() throws {
        var value = draft()
        value.pulseCount = 3
        value.gap = 0.2
        let curves = try HapticsController.parameterCurves(value, capabilities: limits())
        let source = try HapticSwiftExport.source(for: value, capabilities: limits())
        for curve in curves {
            XCTAssertTrue(source.contains("], relativeTime: \(curve.relativeTime))"))
            for point in curve.controlPoints {
                XCTAssertTrue(source.contains("CHHapticParameterCurve.ControlPoint(relativeTime: \(point.relativeTime), value: \(point.value))"))
            }
        }
        XCTAssertEqual(source.components(separatedBy: "CHHapticParameterCurve(parameterID:").count - 1, 6)
        XCTAssertTrue(source.contains("attributes(forDynamicParameter: curve.parameterID)"))
        XCTAssertTrue(source.contains("base.value * point.value"))
        XCTAssertTrue(source.contains("base.value + point.value"))
        XCTAssertTrue(source.contains("parameterCurves: curves"))
        XCTAssertTrue(source.contains("token == generation"))
        XCTAssertTrue(source.contains("if phase != .active { player.stop() }"))
        let file = try HapticShareFile(source: source)
        defer { try? file.remove() }
        value.curvePoints[1].intensity = 0.1
        XCTAssertEqual(try String(contentsOf: file.url, encoding: .utf8), source)
    }
}
