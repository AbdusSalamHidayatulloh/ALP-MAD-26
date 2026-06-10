//
//  ActivityKitManager.swift
//  ALP-MAD-26
//
//  Created by student on 10/06/26.
//

import ActivityKit
import Foundation

class ActivityKitManager {
    static let shared = ActivityKitManager()
    private var activeActivity: Activity<DropWatchAttributes>? = nil
    
    func startLiveActivity(totalPhases: Int, initialPhase: String, endTime: Date) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        
        let attributes = DropWatchAttributes(totalPhases: totalPhases)
        let initialContentState = DropWatchAttributes.ContentState(
            currentPhaseName: initialPhase,
            currentPhaseIndex: 1,
            phaseEndTime: endTime
        )
        
        do {
            activeActivity = try Activity.request(
                attributes: attributes,
                content: .init(state: initialContentState, staleDate: nil)
            )
        } catch {
            print("Error starting Live Activity: \(error.localizedDescription)")
        }
    }
    
    func updateLiveActivity(phaseName: String, index: Int, endTime: Date) {
        let updatedState = DropWatchAttributes.ContentState(
            currentPhaseName: phaseName,
            currentPhaseIndex: index,
            phaseEndTime: endTime
        )
        
        Task {
            await activeActivity?.update(.init(state: updatedState, staleDate: nil))
        }
    }
    
    func endLiveActivity() {
        Task {
            await activeActivity?.end(dismissalPolicy: .immediate)
        }
    }
}
