//
//  timer.swift
//  ALP-MAD-26
//
//  Created by Nathania Michelle on 28/05/26.
//

import Foundation
class TimerModel {
    var timer: Timer?
    var duration: TimeInterval
    var isRunning: Bool {
        return timer != nil
    }
    var timeRemaining: TimeInterval {
        return duration - elapsedTime
    }
    private var elapsedTime: TimeInterval = 0
    init(duration: TimeInterval) {
        self.duration = duration
    }
    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.elapsedTime += 1
            if self?.elapsedTime ?? <#default value#> >= self?.duration ?? 0 {
                self?.stop()
            }
        }
    }
    func stop() {
        timer?.invalidate()
        timer = nil
        elapsedTime = 0
    }
}
