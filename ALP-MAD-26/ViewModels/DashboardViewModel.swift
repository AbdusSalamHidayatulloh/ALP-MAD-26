//
//  DashboardViewModel.swift
//  ALP-MAD-26
//
//  Created by student on 28/05/26.

import Foundation
import SwiftData
import Observation

@Observable
class DashboardViewModel {
    var totalLitersSaved: Double = 0.0
    var totalEnergySaved: Double = 0.0  // kWh (Electric heater)
    var totalLPGSaved:    Double = 0.0  // kg  (LPG heater)
    var currentStreak:    Int    = 0
    var chartData: [DailyImpact] = []
    var averageShowerDuration: String = "0 min"

    // ← FIX: Use the values already computed and stored in ShowerSession.
    //   The old implementation recalculated using a flat kWh-per-liter constant
    //   without checking heaterType, so Electric/LPG savings were always wrong.
    func calculateImpact(sessions: [ShowerSession], profile: HardwareProfile) {
        // Sum the pre-calculated fields written by ShowerSession.init / CalculationEngine
        totalLitersSaved = sessions.reduce(0.0) { $0 + $1.waterSavedLiters }
        totalEnergySaved = sessions.reduce(0.0) { $0 + $1.electricitySavedKWh }
        totalLPGSaved    = sessions.reduce(0.0) { $0 + $1.lpgSavedKg }

        // Average shower duration for the "None" heater type card
        if sessions.isEmpty {
            averageShowerDuration = "0 min"
        } else {
            let avgMinutes = sessions.map { $0.actualDuration }.reduce(0, +) / Double(sessions.count)
            averageShowerDuration = String(format: "%.1f min", avgMinutes)
        }

        prepareChartData(sessions: sessions)
    }

    private func prepareChartData(sessions: [ShowerSession]) {
        let grouped = Dictionary(grouping: sessions) { session in
            Calendar.current.startOfDay(for: session.timestamp)
        }

        chartData = grouped.map { date, daySessions in
            // Use the stored waterSavedLiters — already correct for this session's hardware.
            let liters = daySessions.reduce(0.0) { $0 + $1.waterSavedLiters }
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
