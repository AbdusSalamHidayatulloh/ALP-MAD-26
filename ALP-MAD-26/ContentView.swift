//
//  ContentView.swift
//  ALP-MAD-26
//
//  Created by student on 28/05/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var vm = TimerViewModel(duration: 300)
    var body: some View {
        VStack(spacing: 12) {
                    ProgressView(
                        value: vm.timerModel.duration - vm.timeRemaining,
                        total: vm.timerModel.duration
                    )
                    .progressViewStyle(.circular)
                    .scaleEffect(1.3)
                    Text(formatTime(vm.timeRemaining))
                        .font(.system(size: 28, weight: .bold))
                        .monospacedDigit()
                    HStack {
                        Button {
                            vm.startTimer()
                        } label: {
                            Image(systemName: "play.fill")
                        }
                        .tint(.green)
                        Button {
                            vm.stopTimer()
                        } label: {
                            Image(systemName: "stop.fill")
                        }
                        .tint(.red)
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
            }
            private func formatTime(_ time: TimeInterval) -> String {
                let minutes = Int(time) / 60
                let seconds = Int(time) % 60
                return String(format: "%02d:%02d", minutes, seconds)
            }
    }
#Preview {
    ContentView()
}
