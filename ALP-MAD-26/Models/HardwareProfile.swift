//
//  HardwareProfile.swift
//  ALP-MAD-26
//
//  Created by student on 28/05/26.
//


import Foundation
import SwiftData

@Model
class HardwareProfile {
    var flowRateLPM: Double
    var hasWaterHeater: Bool
    var heaterType: String // e.g., "Electric" or "LPG"
    
    init(flowRateLPM: Double, hasWaterHeater: Bool = true, heaterType: String = "Electric") {
        self.flowRateLPM = flowRateLPM
        self.hasWaterHeater = hasWaterHeater
        self.heaterType = heaterType
    }
}