//
//  DashboardViewModel.swift
//  ALP-MAD-26
//
//  Created by student on 28/05/26.
//


import Foundation
import SwiftData
import Observation

@Observable
class DashboardViewModel {
    var totalLitersSaved: Double = 0.0
    var totalEnergySaved: Double = 0.0 // in kWh
    var totalLPGSaved: Double = 0.0 // in kg
    var currentStreak: Int = 0
    var chartData: [DailyImpact] = []
    
    // Indonesian Standard Constants [1]
    private let kwhPerLiter: Double = 0.015
    private let lpgPerLiter: Double = 0.00139
    private let nationalAverageLiters: Double = 75.0 // ~20 Gallons [2]

    func calculateImpact(sessions: [ShowerSession], profile: HardwareProfile) {
        // Variable integrity: Resetting totals before recalculating [3]
        self.totalLitersSaved = 0.0
        self.totalEnergySaved = 0.0
        self.totalLPGSaved = 0.0

        for session in sessions {
            // Water Saved Formula: (Baseline - Actual) x LPM [1]
            let litersSaved = (session.baselineDuration - session.actualDuration) * profile.flowRateLPM
            if litersSaved > 0 {
                self.totalLitersSaved += litersSaved
                self.totalEnergySaved += litersSaved * kwhPerLiter
                self.totalLPGSaved += litersSaved * lpgPerLiter
            }
        }
        prepareChartData(sessions: sessions, profile: profile)
    }

    private func prepareChartData(sessions: [ShowerSession], profile: HardwareProfile) {
        // Groups sessions and maps them to DailyImpact for Swift Charts [4]
    }
}

struct DailyImpact: Identifiable {
    let id = UUID()
    let date: Date
    let litersSaved: Double
}