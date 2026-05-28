//
//  timerviewmodel.swift
//  ALP-MAD-26
//
//  Created by Nathania Michelle on 28/05/26.
//

import Foundation
internal import Combine
class TimerViewModel: ObservableObject {
    @Published var timerModel: TimerModel
    @Published var timeRemaining: TimeInterval
    init(duration: TimeInterval) {
        self.timerModel = TimerModel(duration: duration)
        self.timeRemaining = duration
    }
    func startTimer() {
        timerModel.start()
        updateTimeRemaining()
    }
    func stopTimer() {
        timerModel.stop()
        timeRemaining = timerModel.duration
    }
    private func updateTimeRemaining() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            if self.timerModel.isRunning {
                self.timeRemaining = self.timerModel.timeRemaining
            } else {
                timer.invalidate()
            }
        }
    }
}
