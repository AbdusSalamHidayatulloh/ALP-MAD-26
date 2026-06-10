//
//  WatchRootView.swift
//  ALP-MAD-26
//
//  Created by student on 10/06/26.
//

import SwiftUI

// MARK: - Home Screen

struct WatchRootView: View {

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {

                Image(systemName: "drop.circle.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.blue)
                    .padding(.top, 10)

                Text("DropWatch")
                    .font(.headline)

                Text("Goal: \(Int(Constants.baselineShowerDurationMinutes)) min")
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                NavigationLink {
                    WatchTimerView()
                } label: {
                    Label("Start Shower", systemImage: "play.fill")
                        .font(.callout.bold())
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                .padding(.top, 4)
            }
            .padding(.bottom, 10)
        }
        .navigationTitle("DropWatch")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Timer Screen

/// Pushed by WatchRootView. Hosts the shared TimerView, hooks completion
/// to WatchSessionSender, and shows a syncing badge after the session ends.
struct WatchTimerView: View {

    @Environment(WatchSessionSender.self) private var sender
    @Environment(\.dismiss) private var dismiss

    /// Fresh ViewModel per push — each navigation creates an independent session.
    @State private var timerViewModel = ShowerTimerViewModel()

    var body: some View {
        VStack(spacing: 6) {

            TimerView(viewModel: timerViewModel)

            // ── Post-session controls ──────────────────────────────────────
            if timerViewModel.isComplete {
                syncBadge
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: timerViewModel.isComplete)
        .navigationBarBackButtonHidden(timerViewModel.isRunning) // hide back while running
        .onAppear(perform: wireCallbacks)
    }

    // MARK: - Sync Badge

    private var syncBadge: some View {
        HStack(spacing: 6) {
            if sender.isSending {
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(0.7)
                Text("Syncing…")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            } else {
                Image(systemName: "checkmark.icloud.fill")
                    .foregroundStyle(.green)
                Text("Sent to iPhone")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(.ultraThinMaterial, in: Capsule())
    }

    // MARK: - Wiring

    private func wireCallbacks() {
        timerViewModel.onSessionComplete = { actualMinutes in
            sender.sendShowerSession(
                actualDuration:   actualMinutes,
                baselineDuration: Constants.baselineShowerDurationMinutes
            )
        }
    }
}
