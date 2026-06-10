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
    var userName: String
    var flowRateLPM: Double
    var hasWaterHeater: Bool
    var heaterType: String
    var isActive : Bool
    
    init(userName: String, flowRateLPM: Double, hasWaterHeater: Bool = true, heaterType: String = "Electric", isActive: Bool = true) {
        self.userName = userName
        self.flowRateLPM = flowRateLPM
        self.hasWaterHeater = hasWaterHeater
        self.heaterType = heaterType
        self.isActive = isActive
    }
}
