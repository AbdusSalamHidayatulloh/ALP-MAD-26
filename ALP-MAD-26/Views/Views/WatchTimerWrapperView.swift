//
//  WatchTimerWrapperView.swift
//  ALP-MAD-26
//
//  Created by student on 10/06/26.
//
//  TARGET MEMBERSHIP: watchOS ONLY (ALP-MAD-26 WatchKit Extension)
//
//  Root view on Apple Watch. Owns the ShowerTimerViewModel, attaches the
//  session-complete callback that sends data to the iPhone, and wraps
//  the shared TimerView with Watch-appropriate chrome.
//

import SwiftUI

struct WatchTimerWrapperView: View {

    @State private var viewModel = ShowerTimerViewModel()

    var body: some View {
        NavigationStack {
            TimerView(viewModel: viewModel)
                .navigationTitle("DropWatch")
                .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            // Attach the completion callback once when the view is mounted.
            // WatchSessionDelegate sends the finished session to the iPhone.
            viewModel.onSessionComplete = { actualMinutes in
                WatchSessionDelegate.shared.sendSession(
                    actualDuration:   actualMinutes,
                    baselineDuration: Constants.baselineShowerDurationMinutes
                )
            }
        }
    }
}
