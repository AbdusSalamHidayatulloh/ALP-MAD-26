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
        let profile = HardwareProfile(userName: "Test", flowRateLPM: 9.0)
        let session = ShowerSession(baselineDuration: 10, actualDuration: 5, hardware: profile)

        viewModel.calculateImpact(sessions: [session], profile: profile)

        XCTAssertEqual(viewModel.totalLitersSaved, 45.0, "totalLitersSaved failed integrity check.")
    }

    func testNoWaterSavedWhenActualExceedsBaseline() {
        let profile = HardwareProfile(userName: "Test", flowRateLPM: 9.0)
        let session = ShowerSession(baselineDuration: 5, actualDuration: 10, hardware: profile)

        viewModel.calculateImpact(sessions: [session], profile: profile)

        XCTAssertEqual(viewModel.totalLitersSaved, 0.0, "Negative savings should not be counted.")
    }

    func testWaterSavedWithMultipleSessions() {
        let profile = HardwareProfile(userName: "Test", flowRateLPM: 9.0)
        let sessions = [
            ShowerSession(baselineDuration: 10, actualDuration: 5, hardware: profile),  // 45L
            ShowerSession(baselineDuration: 10, actualDuration: 8, hardware: profile)   // 18L
        ]

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
        let profile = HardwareProfile(
            userName: "Test",
            flowRateLPM: 10.0,
            hasWaterHeater: true,
            heaterType: "Electric"
        )
        
        let session = ShowerSession(baselineDuration: 20, actualDuration: 10, hardware: profile)

        viewModel.calculateImpact(sessions: [session], profile: profile)

        XCTAssertEqual(viewModel.totalEnergySaved, 1.5, accuracy: 0.0001, "Energy calculation is inaccurate.")
    }

    // MARK: - LPG

    func testLPGVariableIntegrity() {
        let profile = HardwareProfile(
            userName: "Test",
            flowRateLPM: 10.0,
            hasWaterHeater: true,
            heaterType: "LPG"
        )
        
        let session = ShowerSession(baselineDuration: 20, actualDuration: 10, hardware: profile)

        viewModel.calculateImpact(sessions: [session], profile: profile)

        XCTAssertEqual(viewModel.totalLPGSaved, 0.139, accuracy: 0.001, "LPG calculation is inaccurate.")
    }

    // MARK: - Reset Integrity

    func testRecalculationResetsOldValues() {
        let profile = HardwareProfile(userName: "Test", flowRateLPM: 9.0)
        let initialSession = ShowerSession(baselineDuration: 10, actualDuration: 5, hardware: profile)
        
        viewModel.calculateImpact(
            sessions: [initialSession],
            profile: profile
        )

        viewModel.calculateImpact(sessions: [], profile: profile)

        XCTAssertEqual(viewModel.totalLitersSaved, 0.0, "Recalculation did not reset totalLitersSaved.")
        XCTAssertEqual(viewModel.totalEnergySaved, 0.0, "Recalculation did not reset totalEnergySaved.")
        XCTAssertEqual(viewModel.totalLPGSaved,    0.0, "Recalculation did not reset totalLPGSaved.")
    }
}
