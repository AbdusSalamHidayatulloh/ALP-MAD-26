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

    func testWaterSavedVariableIntegrity() {
        // Given: A session of 5 mins (Baseline 10) and Standard Flow (9 LPM) [1]
        let session = ShowerSession(baselineDuration: 10, actualDuration: 5)
        let profile = HardwareProfile(flowRateLPM: 9.0)
        
        // When
        viewModel.calculateImpact(sessions: [session], profile: profile)
        
        // Then: (10 - 5) * 9 = 45 Liters
        XCTAssertEqual(viewModel.totalLitersSaved, 45.0, "The totalLitersSaved variable failed integrity check.")
    }

    func testEnergyVariableIntegrity() {
        // Given: 100 Liters saved
        let session = ShowerSession(baselineDuration: 20, actualDuration: 10)
        let profile = HardwareProfile(flowRateLPM: 10.0)
        
        // When
        viewModel.calculateImpact(sessions: [session], profile: profile)
        
        // Then: 100 * 0.015 = 1.5 kWh [1]
        XCTAssertEqual(viewModel.totalEnergySaved, 1.5, "The energy calculation variable is inaccurate.")
    }
}
