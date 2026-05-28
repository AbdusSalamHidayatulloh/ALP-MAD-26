//
//  showertimerview.swift
//  ALP-MAD-26
//
//  Created by Nathania Michelle on 28/05/26.
//

import SwiftUI
struct TimerView: View {
    @StateObject var viewModel = TimerViewModel(duration: 300) // 5 minutes
    var body: some View {
        VStack {
            Text("Time Remaining: \(Int(viewModel.timeRemaining)) seconds")
            HStack {
                Button("Start") {
                    viewModel.startTimer()
                }
                Button("Stop") {
                    viewModel.stopTimer()
                }
            }
        }
    }
}
