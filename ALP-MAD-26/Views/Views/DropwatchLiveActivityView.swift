//
//  DropwatchLiveActivityView.swift
//  ALP-MAD-26
//
//  Created by student on 10/06/26.
//


#if os(iOS)
import ActivityKit
import WidgetKit
import SwiftUI

// MARK: - Lock Screen / Notification Banner

struct DropWatchLockScreenView: View {

    let context: ActivityViewContext<DropWatchAttributes>

    private var isLastPhase: Bool {
        context.state.currentPhaseIndex >= context.attributes.totalPhases
    }

    var body: some View {
        HStack(alignment: .center, spacing: 16) {

            // Left: phase info + dot progress
            VStack(alignment: .leading, spacing: 6) {

                HStack(spacing: 6) {
                    Image(systemName: "drop.fill")
                        .foregroundStyle(.cyan)
                        .font(.caption.bold())
                    Text("DropWatch")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.7))
                }

                Text(context.state.currentPhaseName)
                    .font(.title3.bold())
                    .foregroundStyle(.white)

                // Phase dot indicator
                HStack(spacing: 5) {
                    ForEach(1...context.attributes.totalPhases, id: \.self) { i in
                        Capsule()
                            .fill(
                                i == context.state.currentPhaseIndex
                                    ? Color.cyan
                                : i < context.state.currentPhaseIndex
                                    ? Color.cyan.opacity(0.45)
                                    : Color.white.opacity(0.2)
                            )
                            .frame(
                                width: i == context.state.currentPhaseIndex ? 18 : 8,
                                height: 6
                            )
                            .animation(.easeInOut, value: context.state.currentPhaseIndex)
                    }
                }
            }

            Spacer()

            // Right: live countdown
            VStack(alignment: .trailing, spacing: 2) {
                Text(
                    timerInterval: Date.now...context.state.phaseEndTime,
                    countsDown: true
                )
                .font(.system(.title2, design: .monospaced, weight: .bold))
                .foregroundStyle(.cyan)
                .monospacedDigit()
                .frame(width: 72, alignment: .trailing)

                Text("phase left")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(
            LinearGradient(
                colors: [Color(red: 0.05, green: 0.18, blue: 0.45),
                         Color(red: 0.03, green: 0.30, blue: 0.55)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

// MARK: - Widget Configuration

struct DropWatchLiveActivityWidget: Widget {

    var body: some WidgetConfiguration {
        ActivityConfiguration(for: DropWatchAttributes.self) { context in

            // ── Lock Screen / Banner ───────────────────────────────────────
            DropWatchLockScreenView(context: context)

        } dynamicIsland: { context in

            DynamicIsland {

                // ── Expanded ───────────────────────────────────────────────
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 6) {
                        Image(systemName: "drop.fill")
                            .foregroundStyle(.cyan)
                            .font(.callout.bold())
                        Text(context.state.currentPhaseName)
                            .font(.callout.bold())
                            .foregroundStyle(.white)
                    }
                }

                DynamicIslandExpandedRegion(.trailing) {
                    Text(
                        timerInterval: Date.now...context.state.phaseEndTime,
                        countsDown: true
                    )
                    .font(.callout.bold().monospacedDigit())
                    .foregroundStyle(.cyan)
                    .frame(maxWidth: 70, alignment: .trailing)
                }

                DynamicIslandExpandedRegion(.bottom) {
                    // Phase progress bar
                    HStack(spacing: 6) {
                        Text("Phase \(context.state.currentPhaseIndex) of \(context.attributes.totalPhases)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)

                        Spacer()

                        HStack(spacing: 4) {
                            ForEach(1...context.attributes.totalPhases, id: \.self) { i in
                                Capsule()
                                    .fill(
                                        i == context.state.currentPhaseIndex
                                            ? Color.cyan
                                        : i < context.state.currentPhaseIndex
                                            ? Color.cyan.opacity(0.4)
                                            : Color.white.opacity(0.15)
                                    )
                                    .frame(
                                        width: i == context.state.currentPhaseIndex ? 20 : 10,
                                        height: 6
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                }

            } compactLeading: {
                // ── Compact leading ────────────────────────────────────────
                Image(systemName: "drop.fill")
                    .foregroundStyle(.cyan)
                    .font(.caption.bold())

            } compactTrailing: {
                // ── Compact trailing ───────────────────────────────────────
                Text(
                    timerInterval: Date.now...context.state.phaseEndTime,
                    countsDown: true
                )
                .font(.caption2.bold().monospacedDigit())
                .foregroundStyle(.cyan)
                .frame(maxWidth: 46)

            } minimal: {
                // ── Minimal (two activities running) ──────────────────────
                Image(systemName: "drop.fill")
                    .foregroundStyle(.cyan)
            }
            .keylineTint(.cyan)          // Dynamic Island accent colour
        }
    }
}
#endif
