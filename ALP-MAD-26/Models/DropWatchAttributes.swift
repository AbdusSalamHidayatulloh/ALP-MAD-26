//
//  DropWatchAttributes.swift
//  ALP-MAD-26
//
//  Created by student on 10/06/26.
//

import ActivityKit
import Foundation

public struct DropWatchAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic properties that will update frequently during the shower session
        public var currentPhaseName: String     // e.g., "Soap Up"
        public var currentPhaseIndex: Int       // e.g., 2
        public var phaseEndTime: Date           // The countdown target timestamp
        
        public init(currentPhaseName: String, currentPhaseIndex: Int, phaseEndTime: Date) {
            self.currentPhaseName = currentPhaseName
            self.currentPhaseIndex = currentPhaseIndex
            self.phaseEndTime = phaseEndTime
        }
    }

    // Static baseline property that stays constant throughout the specific activity instance
    public var totalPhases: Int                 // e.g., 3
    
    public init(totalPhases: Int) {
        self.totalPhases = totalPhases
    }
}

