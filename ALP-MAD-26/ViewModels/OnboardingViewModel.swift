//
//  OnboardingViewModel.swift
//  ALP-MAD-26
//
//  Created by student on 03/06/26.
//

import Foundation
import SwiftUI

@Observable
class OnboardingViewModel {
    var userName: String = ""
    var selectedShowerhead: ShowerheadType? = nil
    
    // Default the choice to electric initially
    var heaterType: HeaterType = .electric
    
    // Dynamic computed property to seamlessly bind to your SwiftUI Toggle.
    // This keeps the toggle and the picker perfectly synchronized!
    var hasWaterHeater: Bool {
        get {
            heaterType != .none
        }
        set {
            // If they flip the toggle to true, default to Electric.
            // If they flip it to false, automatically set type to .none.
            heaterType = newValue ? .electric : .none
        }
    }
    
    // Enum mapping visual cards to your actual math baselines
    enum ShowerheadType: String, CaseIterable {
        case eco = "eco"
        case standard = "standard"
        case rainfall = "rainfall"
        
        var displayName: String {
            switch self {
            case .eco: return "Eco Showerhead"
            case .standard: return "Standard Showerhead"
            case .rainfall: return "Rainfall / High-Flow"
            }
        }
        
        // This transfers the visual selection into the mathematical flow rate
        var flowRateLPM: Double {
            switch self {
            case .eco: return 5.5
            case .standard: return 9.0
            case .rainfall: return 12.0
            }
        }
    }
    
    // Enum for the heater types, now safely featuring 'none'
    enum HeaterType: String, CaseIterable {
        case none = "None"
        case electric = "Electric"
        case lpg = "LPG"
    }
    
    // Validates that they entered a name and picked a showerhead
    var isFormValid: Bool {
        !userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && selectedShowerhead != nil
    }
}
