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
    public static let groundwaterTemperature: Double = 27.0
    
    /// Target comfortable warm shower temperature in Celsius
    public static let targetShowerTemperature: Double = 40.0
    
    /// Specific heat capacity of water (kJ/kg°C)
    public static let waterHeatCapacity: Double = 4.184
    
    // MARK: - Simplified Energy Conversions
    /// The predefined constant for energy saved per liter of heated water saved (in kWh)
    public static let energyPerLiterSaved: Double = 0.015
    
    // MARK: - Behavioral Baselines
    /// The average baseline shower duration in minutes (used to calculate savings)
    /// Adjust this based on your specific target demographic research.
    public static let baselineShowerDurationMinutes: Double = 10.0
    
    // MARK: - Hardware Flow Rates (Liters Per Minute - LPM)
    /// Flow rates categorized based on standard plumbing profiles
    public enum FlowRate {
        /// Eco/Low-flow showerhead
        public static let eco: Double = 5.5
        /// Standard showerhead
        public static let standard: Double = 9.0
        /// High-flow / Rainfall showerhead
        public static let highFlow: Double = 12.0
    }
}
