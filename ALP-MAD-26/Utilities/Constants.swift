//
//  Constants.swift
//  ALP-MAD-26
//
//  Created by student on 03/06/26.
//

import Foundation

public enum Constants {
    
    // MARK: - Environmental & Thermal Baselines
    /// Average Indonesian groundwater temperature in Celsius
    public static let groundwaterTemperature: Double = 27.0 //
    
    /// Target comfortable warm shower temperature in Celsius
    public static let targetShowerTemperature: Double = 40.0 //
    
    /// Specific heat capacity of water (kJ/kg°C)
    public static let waterHeatCapacity: Double = 4.184 //
    
    // MARK: - Simplified Energy Conversions (Electricity)
    /// The predefined constant for energy saved per liter of heated water saved (in kWh)
    public static let energyPerLiterSaved: Double = 0.015 //
    
    // MARK: - Gas (LPG) Baselines
    /// Energy content of Liquefied Petroleum Gas (kJ per kg)
    public static let lpgEnergyPerKg: Double = 46000.0 //
    
    /// Average efficiency rating of standard domestic LPG water heaters (85%)
    public static let lpgHeaterEfficiency: Double = 0.85 //
    
    // MARK: - Behavioral Baselines
    /// The average baseline shower duration in minutes (used to calculate savings)
    /// Your proposal points to an 80L shower benchmark (~8.8 to 10 mins).
    public static let baselineShowerDurationMinutes: Double = 10.0
    
    // MARK: - Hardware Flow Rates (Liters Per Minute - LPM)
    /// Flow rates categorized based on Green Building Council Indonesia (GBCI) standards
    public enum FlowRate {
        /// Eco/Low-flow showerhead (~5-6 LPM)
        public static let eco: Double = 5.5 //
        /// Standard showerhead (~9 LPM)
        public static let standard: Double = 9.0 //
        /// High-flow / Rainfall showerhead (~12+ LPM)
        public static let highFlow: Double = 12.0 //
    }
}
