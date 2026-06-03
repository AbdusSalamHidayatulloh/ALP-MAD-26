//
//  CalculationEngine.swift
//  ALP-MAD-26
//
//  Created by student on 03/06/26.
//

import Foundation

public struct CalculationEngine {
    
    // MARK: - Water Calculations
    
    /// Calculates the total amount of water consumed during a shower session.
    /// - Parameters:
    ///   - durationInMinutes: The actual time spent in the shower.
    ///   - flowRateLPM: The hardware flow rate (Liters Per Minute) from the user's Onboarding Profile.
    /// - Returns: Total water used in Liters.
    public static func calculateWaterUsed(durationInMinutes: Double, flowRateLPM: Double) -> Double {
        // Ensure we don't calculate negative time in edge cases
        let validDuration = max(0, durationInMinutes)
        return validDuration * flowRateLPM
    }
    
    /// Calculates the amount of water saved compared to a baseline shower.
    /// - Parameters:
    ///   - actualDurationInMinutes: The time spent in the shower.
    ///   - flowRateLPM: The hardware flow rate (LPM).
    /// - Returns: Water saved in Liters. Returns 0 if the user took longer than the baseline.
    public static func calculateWaterSaved(actualDurationInMinutes: Double, flowRateLPM: Double) -> Double {
        guard actualDurationInMinutes < Constants.baselineShowerDurationMinutes else {
            return 0.0 // No savings if they exceeded the baseline time
        }
        
        let minutesSaved = Constants.baselineShowerDurationMinutes - actualDurationInMinutes
        return minutesSaved * flowRateLPM
    }
    
    // MARK: - Energy Calculations
    
    /// Calculates the electrical/gas energy saved (in kWh) based on water volume saved.
    /// Uses the simplified project proposal conversion metric.
    /// - Parameter litersSaved: The volume of heated water prevented from being used.
    /// - Returns: Estimated energy saved in kWh.
    public static func calculateEnergySaved(litersSaved: Double) -> Double {
        let validLiters = max(0, litersSaved)
        return validLiters * Constants.energyPerLiterSaved
    }
    
    /// Calculates the precise thermodynamic energy required to heat the used water.
    /// - Parameter waterUsedLiters: Total water consumed in Liters (1 Liter of water ≈ 1 kg).
    /// - Returns: Total thermal energy expended in kilojoules (kJ).
    public static func calculateThermalEnergyExpended(waterUsedLiters: Double) -> Double {
        // Formula: Q = m * c * ΔT
        // Mass (m) = waterUsedLiters (assuming density of water is ~1 kg/L)
        // Delta T (ΔT) = Target Temp - Groundwater Temp
        
        let deltaT = Constants.targetShowerTemperature - Constants.groundwaterTemperature
        let validDeltaT = max(0, deltaT) // Prevent negative energy if groundwater is exceptionally hot
        
        let massInKg = waterUsedLiters
        
        let thermalEnergyKJ = massInKg * Constants.waterHeatCapacity * validDeltaT
        return thermalEnergyKJ
    }
}
