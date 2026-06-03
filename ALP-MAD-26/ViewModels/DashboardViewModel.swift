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
    var totalEnergySaved: Double = 0.0  // kWh (Electric heater)
    var totalLPGSaved: Double = 0.0     // kg  (LPG heater)
    var currentStreak: Int = 0
    var chartData: [DailyImpact] = []
    var averageShowerDuration: String = "0 min"

    // Indonesian Standard Constants (from proposal)
    private let kwhPerLiter: Double = 0.015
    private let lpgPerLiter: Double = 0.00139
    private let nationalAverageLiters: Double = 75.0 // ~20 Gallons

    func calculateImpact(sessions: [ShowerSession], profile: HardwareProfile) {
        // Reset totals before recalculating
        totalLitersSaved = 0.0
        totalEnergySaved = 0.0
        totalLPGSaved = 0.0

        for session in sessions {
            // Water Saved Formula: (Baseline - Actual) x LPM
            let litersSaved = (session.baselineDuration - session.actualDuration) * profile.flowRateLPM
            if litersSaved > 0 {
                totalLitersSaved += litersSaved
                totalEnergySaved += litersSaved * kwhPerLiter
                totalLPGSaved    += litersSaved * lpgPerLiter
            }
        }

        // Average shower duration for "None" heater type card
        if !sessions.isEmpty {
            let avgMinutes = sessions.map { $0.actualDuration }.reduce(0, +) / Double(sessions.count)
            averageShowerDuration = String(format: "%.1f min", avgMinutes)
        }

        prepareChartData(sessions: sessions, profile: profile)
    }

    private func prepareChartData(sessions: [ShowerSession], profile: HardwareProfile) {
        let grouped = Dictionary(grouping: sessions) { session in
            Calendar.current.startOfDay(for: session.timestamp)
        }

        chartData = grouped.map { date, daySessions in
            let liters = daySessions.reduce(0.0) { total, session in
                let saved = (session.baselineDuration - session.actualDuration) * profile.flowRateLPM
                return total + max(saved, 0)
            }
            return DailyImpact(date: date, litersSaved: liters)
        }
        .sorted { $0.date < $1.date }
    }
}

struct DailyImpact: Identifiable {
    let id = UUID()
    let date: Date
    let litersSaved: Double
}
