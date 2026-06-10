//
//  WatchRootView.swift
//  ALP-MAD-26
//
//  Created by student on 10/06/26.
//

import SwiftUI

struct WatchRootView: View {
    var viewModel: ShowerTimerViewModel
    
    var body: some View {
        NavigationStack {
            TimerView(viewModel: viewModel)
                .onAppear {
                    // Automatically kick off the countdown loop when the watch app boots
                    if !viewModel.isRunning && !viewModel.isComplete {
                        viewModel.start()
                    }
                }
                .onDisappear {
                    // Optional: Pause if the user exits the app screen abruptly
                    if viewModel.isRunning {
                        viewModel.pause()
                    }
                }
        }
    }
}
