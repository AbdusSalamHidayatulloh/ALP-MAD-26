//
//  TimerView.swift
//  ALP-MAD-26
//
//  Created by student on 10/06/26.
//
//  TARGET MEMBERSHIP: iOS (ALP-MAD-26) + watchOS (ALP-MAD-26 WatchKit Extension)
//
//  TimerView is the single source of truth for timer UI across iPhone, iPad, and Apple Watch.
//  Platform-specific sizing and button styles are handled via conditional compilation.
//

import SwiftUI

struct TimerView: View {

    // Owned externally so the parent (e.g. WatchTimerWrapperView) can attach callbacks.
    var viewModel: ShowerTimerViewModel

    // MARK: - Phase Color

    private var phaseColor: Color {
        switch viewModel.currentPhaseIndex {
        case 0:  return .cyan
        case 1:  return .blue
        case 2:  return .teal
        default: return .blue
        }
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: verticalSpacing) {
            phaseHeader
            ringWithTimer
            controls
        }
        .padding(outerPadding)
    }

    // MARK: - Subviews

    private var phaseHeader: some View {
        VStack(spacing: 2) {
            Text(viewModel.isComplete ? "Session Complete!" : viewModel.currentPhase.name)
                .font(.headline)
                .foregroundStyle(viewModel.isComplete ? .green : phaseColor)
                .animation(.easeInOut, value: viewModel.currentPhaseIndex)

            if !viewModel.isComplete {
                Text("Phase \(viewModel.currentPhaseIndex + 1) of \(viewModel.phases.count)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var ringWithTimer: some View {
        ZStack {
            CircularProgressRing(
                progress:  viewModel.phaseProgress,
                ringColor: phaseColor,
                lineWidth: ringLineWidth
            )
            .frame(width: ringSize, height: ringSize)

            timerCenter
        }
    }

    @ViewBuilder
    private var timerCenter: some View {
        if viewModel.isComplete {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: completionIconSize))
                .foregroundStyle(.green)
        } else {
            VStack(spacing: 2) {
                Text(viewModel.timeRemainingFormatted)
                    .font(.system(size: timerFontSize, weight: .bold, design: .monospaced))
                    .foregroundStyle(.primary)
                    .contentTransition(.numericText(countsDown: true))
                    .animation(.linear(duration: 0.5), value: viewModel.timeRemainingFormatted)

                Text(String(format: "%.0f%%", viewModel.overallProgress * 100))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }

    @ViewBuilder
    private var controls: some View {
        #if os(watchOS)
        watchControls
        #else
        iOSControls
        #endif
    }

    // MARK: - iOS Controls (labeled buttons)

    #if !os(watchOS)
    private var iOSControls: some View {
        HStack(spacing: 20) {
            if !viewModel.isComplete {
                Button {
                    viewModel.isRunning ? viewModel.pause() : viewModel.start()
                } label: {
                    Label(
                        viewModel.isRunning ? "Pause" : (viewModel.isResumable ? "Resume" : "Start"),
                        systemImage: viewModel.isRunning ? "pause.fill" : "play.fill"
                    )
                }
                .buttonStyle(.borderedProminent)
                .tint(phaseColor)

                Button {
                    viewModel.reset()
                } label: {
                    Label("Reset", systemImage: "arrow.counterclockwise")
                }
                .buttonStyle(.bordered)
            } else {
                Button {
                    viewModel.reset()
                } label: {
                    Label("New Session", systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            }
        }
    }
    #endif

    // MARK: - watchOS Controls (icon-only, tap-target sized)

    #if os(watchOS)
    private var watchControls: some View {
        HStack(spacing: 12) {
            if !viewModel.isComplete {
                Button {
                    viewModel.isRunning ? viewModel.pause() : viewModel.start()
                } label: {
                    Image(systemName: viewModel.isRunning ? "pause.fill" : "play.fill")
                        .font(.title3)
                }
                .buttonStyle(.borderedProminent)
                .tint(phaseColor)

                Button {
                    viewModel.reset()
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.title3)
                }
                .buttonStyle(.bordered)
            } else {
                Button {
                    viewModel.reset()
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.title3)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            }
        }
    }
    #endif

    // MARK: - Platform-Adaptive Constants

    private var ringSize: CGFloat {
        #if os(watchOS)
        return 120
        #else
        return 220
        #endif
    }

    private var ringLineWidth: CGFloat {
        #if os(watchOS)
        return 10
        #else
        return 18
        #endif
    }

    private var timerFontSize: CGFloat {
        #if os(watchOS)
        return 30
        #else
        return 46
        #endif
    }

    private var completionIconSize: CGFloat {
        #if os(watchOS)
        return 36
        #else
        return 52
        #endif
    }

    private var verticalSpacing: CGFloat {
        #if os(watchOS)
        return 8
        #else
        return 24
        #endif
    }

    private var outerPadding: CGFloat {
        #if os(watchOS)
        return 4
        #else
        return 20
        #endif
    }
}
