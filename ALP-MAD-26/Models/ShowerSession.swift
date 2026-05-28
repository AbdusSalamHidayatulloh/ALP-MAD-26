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
    
    init(baselineDuration: Double, actualDuration: Double, timestamp: Date = .now) {
        self.baselineDuration = baselineDuration
        self.actualDuration = actualDuration
        self.timestamp = timestamp
    }
}