//
//  DashboardTests.swift
//  ALP-MAD-26
//
//  Created by student on 28/05/26.
//

import XCTest
@testable import ALP_MAD_26

final class DashboardTests: XCTestCase {
    var viewModel: DashboardViewModel!

    override func setUp() {
        super.setUp()
        viewModel = DashboardViewModel()
    }

    // MARK: - Water Saved

    func testWaterSavedVariableIntegrity() {
        let session = ShowerSession(baselineDuration: 10, actualDuration: 5)
        let profile = HardwareProfile(userName: "Test", flowRateLPM: 9.0)

        viewModel.calculateImpact(sessions: [session], profile: profile)

        XCTAssertEqual(viewModel.totalLitersSaved, 45.0, "totalLitersSaved failed integrity check.")
    }

    func testNoWaterSavedWhenActualExceedsBaseline() {
        let session = ShowerSession(baselineDuration: 5, actualDuration: 10)
        let profile = HardwareProfile(userName: "Test", flowRateLPM: 9.0)

        viewModel.calculateImpact(sessions: [session], profile: profile)

        XCTAssertEqual(viewModel.totalLitersSaved, 0.0, "Negative savings should not be counted.")
    }

    func testWaterSavedWithMultipleSessions() {
        let sessions = [
            ShowerSession(baselineDuration: 10, actualDuration: 5),  // 45L
            ShowerSession(baselineDuration: 10, actualDuration: 8)   // 18L
        ]
        let profile = HardwareProfile(userName: "Test", flowRateLPM: 9.0)

        viewModel.calculateImpact(sessions: sessions, profile: profile)

        XCTAssertEqual(viewModel.totalLitersSaved, 63.0, "Multi-session water total is incorrect.")
    }

    func testEmptySessionsProducesZeroValues() {
        let profile = HardwareProfile(userName: "Test", flowRateLPM: 9.0)

        viewModel.calculateImpact(sessions: [], profile: profile)

        XCTAssertEqual(viewModel.totalLitersSaved, 0.0, "Empty sessions should yield 0 liters.")
        XCTAssertEqual(viewModel.totalEnergySaved, 0.0, "Empty sessions should yield 0 kWh.")
        XCTAssertEqual(viewModel.totalLPGSaved,    0.0, "Empty sessions should yield 0 LPG.")
    }

    // MARK: - Energy (Electric)

    func testEnergyVariableIntegrity() {
        let session = ShowerSession(baselineDuration: 20, actualDuration: 10)
        let profile = HardwareProfile(userName: "Test", flowRateLPM: 10.0)

        viewModel.calculateImpact(sessions: [session], profile: profile)

        XCTAssertEqual(viewModel.totalEnergySaved, 1.5, accuracy: 0.0001, "Energy calculation is inaccurate.")
    }

    // MARK: - LPG

    func testLPGVariableIntegrity() {
        let session = ShowerSession(baselineDuration: 20, actualDuration: 10)
        let profile = HardwareProfile(userName: "Test", flowRateLPM: 10.0)

        viewModel.calculateImpact(sessions: [session], profile: profile)

        XCTAssertEqual(viewModel.totalLPGSaved, 0.139, accuracy: 0.0001, "LPG calculation is inaccurate.")
    }

    // MARK: - Reset Integrity

    func testRecalculationResetsOldValues() {
        let profile = HardwareProfile(userName: "Test", flowRateLPM: 9.0)
        viewModel.calculateImpact(
            sessions: [ShowerSession(baselineDuration: 10, actualDuration: 5)],
            profile: profile
        )

        viewModel.calculateImpact(sessions: [], profile: profile)

        XCTAssertEqual(viewModel.totalLitersSaved, 0.0, "Recalculation did not reset totalLitersSaved.")
        XCTAssertEqual(viewModel.totalEnergySaved, 0.0, "Recalculation did not reset totalEnergySaved.")
        XCTAssertEqual(viewModel.totalLPGSaved,    0.0, "Recalculation did not reset totalLPGSaved.")
    }
}
