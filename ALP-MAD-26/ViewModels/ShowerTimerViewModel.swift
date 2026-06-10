//
//  ShowerTimerViewModel.swift
//  ALP-MAD-26
//
//

import Foundation
import Observation
#if os(watchOS)
import WatchKit
#endif

// MARK: - Phase Model

struct ShowerPhase: Identifiable {
    let id = UUID()
    let name: String
    let durationSeconds: Double
}

// MARK: - ViewModel

@Observable
class ShowerTimerViewModel {

    // MARK: Phases (Rinse 1 min → Wash 2 min → Finish 1.5 min)
    let phases: [ShowerPhase] = [
        ShowerPhase(name: "Rinse",  durationSeconds: 60),
        ShowerPhase(name: "Wash",   durationSeconds: 120),
        ShowerPhase(name: "Finish", durationSeconds: 90)
    ]

    // MARK: State
    var currentPhaseIndex:    Int    = 0
    var timeRemainingInPhase: Double = 60   // mirrors phases[0].durationSeconds
    var totalElapsedSeconds:  Double = 0
    var isRunning:            Bool   = false
    var isComplete:           Bool   = false

    /// Called on the main thread when all phases finish. Receives actual duration in minutes.
    var onSessionComplete: ((Double) -> Void)?

    private var timer: Timer?

    // MARK: - Computed

    var currentPhase: ShowerPhase { phases[currentPhaseIndex] }

    var totalDurationSeconds: Double { phases.reduce(0) { $0 + $1.durationSeconds } }

    /// Progress within the *current* phase (0 → 1). Resets each phase for visual clarity.
    var phaseProgress: Double {
        guard currentPhase.durationSeconds > 0 else { return 0 }
        return 1.0 - (timeRemainingInPhase / currentPhase.durationSeconds)
    }

    /// Overall session progress (0 → 1). Shown as % text inside the ring.
    var overallProgress: Double {
        let completedTime  = phases[0..<currentPhaseIndex].reduce(0) { $0 + $1.durationSeconds }
        let elapsedCurrent = currentPhase.durationSeconds - timeRemainingInPhase
        return (completedTime + elapsedCurrent) / totalDurationSeconds
    }

    var timeRemainingFormatted: String {
        let total = Int(max(0, timeRemainingInPhase))
        return String(format: "%d:%02d", total / 60, total % 60)
    }

    var isResumable: Bool { totalElapsedSeconds > 0 && !isComplete }

    // MARK: - Controls

    func start() {
        guard !isRunning && !isComplete else { return }
        isRunning = true

        // Only fire start haptic + Live Activity on a completely fresh session
        if totalElapsedSeconds == 0 {
            fireHaptic(.start)
            #if os(iOS)
            let endTime = Date().addingTimeInterval(phases[currentPhaseIndex].durationSeconds)
            ActivityKitManager.shared.startLiveActivity(
                totalPhases:  phases.count,
                initialPhase: phases[currentPhaseIndex].name,
                endTime:      endTime
            )
            #endif
        }

        scheduleTimer()
    }

    func pause() {
        isRunning = false
        timer?.invalidate()
        timer = nil
        // Note: the Live Activity countdown continues ticking on the Lock Screen
        // during a pause (it's a date-based timer). This is acceptable for v1;
        // a future improvement could update phaseEndTime to reflect the pause offset.
    }

    func reset() {
        pause()
        currentPhaseIndex    = 0
        timeRemainingInPhase = phases[0].durationSeconds
        totalElapsedSeconds  = 0
        isComplete           = false

        // Safety: end any dangling Live Activity (e.g. user resets mid-session).
        #if os(iOS)
        ActivityKitManager.shared.endLiveActivity()
        #endif
    }

    // MARK: - Private Timer

    private func scheduleTimer() {
        let t = Timer(timeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }

    private func tick() {
        guard isRunning else { return }
        timeRemainingInPhase  = max(0, timeRemainingInPhase - 1.0)
        totalElapsedSeconds  += 1.0

        // Warn haptic at 10 s remaining in the final phase
        if currentPhaseIndex == phases.count - 1, Int(timeRemainingInPhase) == 10 {
            fireHaptic(.directionUp)
        }

        if timeRemainingInPhase <= 0 { advancePhase() }
    }

    private func advancePhase() {
        let next = currentPhaseIndex + 1

        if next < phases.count {
            currentPhaseIndex    = next
            timeRemainingInPhase = phases[next].durationSeconds
            fireHaptic(.start)

            // Update the Live Activity to the new phase.
            // currentPhaseIndex is 0-based internally; we pass (next + 1) to keep
            // the Live Activity's index 1-based (matching startLiveActivity's initial value of 1).
            #if os(iOS)
            let endTime = Date().addingTimeInterval(phases[next].durationSeconds)
            ActivityKitManager.shared.updateLiveActivity(
                phaseName: phases[next].name,
                index:     next + 1,
                endTime:   endTime
            )
            #endif
        } else {
            completeSession()
        }
    }

    private func completeSession() {
        timer?.invalidate()
        timer             = nil
        isRunning         = false
        isComplete        = true
        timeRemainingInPhase = 0
        fireHaptic(.success)

        #if os(iOS)
        ActivityKitManager.shared.endLiveActivity()
        #endif

        let actualMinutes = totalElapsedSeconds / 60.0
        onSessionComplete?(actualMinutes)
    }

    // MARK: - Haptics (watchOS only; iOS haptics via UIFeedbackGenerator if desired)

    private enum HapticEvent { case start, directionUp, success }

    private func fireHaptic(_ event: HapticEvent) {
        #if os(watchOS)
        switch event {
        case .start:       WKInterfaceDevice.current().play(.start)
        case .directionUp: WKInterfaceDevice.current().play(.directionUp)
        case .success:     WKInterfaceDevice.current().play(.success)
        }
        #endif
    }
}
