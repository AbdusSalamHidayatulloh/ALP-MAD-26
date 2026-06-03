//
//  CalculationEngine.swift
//  ALP-MAD-26
//
//  Created by student on 03/06/26.
//

import Foundation

public struct CalculationEngine {
    
    // MARK: - Constants From Proposal
    private static let lpgEnergyPerKg: Double = 46000.0 // 46,000 kJ per kg of LPG
    private static let lpgHeaterEfficiency: Double = 0.85 // 85% efficiency rate
    private static let electricKWhPerLiter: Double = 0.015 // 0.015 kWh per Liter
    
    // MARK: - Water Calculations
    
    /// Calculates the total amount of water consumed during a shower session.
    public static func calculateWaterUsed(durationInMinutes: Double, flowRateLPM: Double) -> Double {
        let validDuration = max(0, durationInMinutes)
        return validDuration * flowRateLPM
    }
    
    /// Calculates the amount of water saved compared to a baseline shower.
    public static func calculateWaterSaved(actualDurationInMinutes: Double, flowRateLPM: Double) -> Double {
        // Constants.baselineShowerDurationMinutes is assumed to be defined in your Constants.swift
        guard actualDurationInMinutes < Constants.baselineShowerDurationMinutes else {
            return 0.0
        }
        let minutesSaved = Constants.baselineShowerDurationMinutes - actualDurationInMinutes
        return minutesSaved * flowRateLPM
    }
    
    // MARK: - Precise Thermodynamic Base Function
    
    /// Calculates the raw thermal energy required to heat a specific volume of water from Indonesian groundwater (27°C) to standard warm (40°C)[cite: 41, 42].
    /// - Returns: Thermal energy in kilojoules (kJ).
    public static func calculateThermalEnergyRequired(waterLiters: Double) -> Double {
        let deltaT = Constants.targetShowerTemperature - Constants.groundwaterTemperature // 13°C delta [cite: 41, 42]
        let validDeltaT = max(0, deltaT)
        let massInKg = max(0, waterLiters) // 1 Liter of water ≈ 1 kg
        
        // Q = m * c * ΔT [cite: 41, 42]
        return massInKg * Constants.waterHeatCapacity * validDeltaT
    }
    
    // MARK: - Energy & Gas Routing Matrix
    
    /// Calculates how much electrical energy was processed (either saved or consumed) in kWh.
    /// Returns 0.0 if the user does not use an electric heater.
    public static func calculateElectricity(waterLiters: Double, hasHeater: Bool, heaterType: String) -> Double {
        guard hasHeater && heaterType == "Electric" else { return 0.0 }
        return max(0, waterLiters) * electricKWhPerLiter // Liters x 0.015 kWh
    }
    
    /// Calculates how much LPG mass was processed (either saved or consumed) in kilograms (kg).
    /// Returns 0.0 if the user does not use an LPG heater.
    public static func calculateLPG(waterLiters: Double, hasHeater: Bool, heaterType: String) -> Double {
        guard hasHeater && heaterType == "LPG" else { return 0.0 }
        
        // Extract raw thermal requirements in kJ [cite: 42]
        let requiredThermalKJ = calculateThermalEnergyRequired(waterLiters: waterLiters)
        
        // Mass (kg) = Thermal Energy / (Energy Density * Efficiency)
        let lpgConsumedKg = requiredThermalKJ / (lpgEnergyPerKg * lpgHeaterEfficiency)
        return max(0, lpgConsumedKg) // This equates to roughly 0.00139 kg per Liter
    }
}
