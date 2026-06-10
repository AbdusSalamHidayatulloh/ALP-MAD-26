//
//  ShowerSession.swift
//  ALP-MAD-26
//
//  Created by student on 28/05/26.
//

import Foundation
import SwiftData

@Model
class ShowerSession {
    var baselineDuration: Double
    var actualDuration: Double
    var timestamp: Date
    var waterUsedLiters: Double
    var waterSavedLiters: Double
    var electricitySavedKWh: Double
    var lpgSavedKg: Double
    
    init(baselineDuration: Double, actualDuration: Double, timestamp: Date = .now, hardware: HardwareProfile) {
        self.timestamp = timestamp
        self.baselineDuration = baselineDuration
        self.actualDuration = actualDuration
        
        // 1. Calculate everything into local constants first
        let minutesUsed = actualDuration
        
        let computedWaterUsed = CalculationEngine.calculateWaterUsed(
            durationInMinutes: minutesUsed,
            flowRateLPM: hardware.flowRateLPM
        )
        
        let computedWaterSaved = CalculationEngine.calculateWaterSaved(
            baselineDurationMinutes: baselineDuration, // Pass the 20 minutes from the test!
            actualDurationInMinutes: minutesUsed,
            flowRateLPM: hardware.flowRateLPM
        )
        
        let computedElectricity = CalculationEngine.calculateElectricity(
            waterLiters: computedWaterSaved, // Safe: Reading local constant instead of self
            hasHeater: hardware.hasWaterHeater,
            heaterType: hardware.heaterType
        )
        
        let computedLPG = CalculationEngine.calculateLPG(
            waterLiters: computedWaterSaved, // Safe: Reading local constant instead of self
            hasHeater: hardware.hasWaterHeater,
            heaterType: hardware.heaterType
        )
        
        // 2. Initialize all stored properties with the computed values
        self.waterUsedLiters = computedWaterUsed
        self.waterSavedLiters = computedWaterSaved
        self.electricitySavedKWh = computedElectricity
        self.lpgSavedKg = computedLPG
    }
}
