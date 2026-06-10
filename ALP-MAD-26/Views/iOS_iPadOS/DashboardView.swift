//
//  DashboardView.swift
//  ALP-MAD-26
//
//  Created by student on 28/05/26.


import SwiftUI
import SwiftData

struct DashboardView: View {
    @State private var viewModel = DashboardViewModel()
    @State private var showingTimer = false
    @State private var timerViewModel = ShowerTimerViewModel()
    @Query private var sessions: [ShowerSession]
    @Query private var profiles: [HardwareProfile]

    // ← FIX 1: We need modelContext to insert the completed ShowerSession.
    @Environment(\.modelContext) private var modelContext

    // Derive heater type from the saved profile
    private var heaterType: String {
        profiles.first?.heaterType ?? "None"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // Impact Summary Cards
                    HStack {
                        ImpactCard(
                            title: "Liters Saved",
                            value: "\(Int(viewModel.totalLitersSaved))L",
                            icon: "drop.fill"
                        )

                        // Switch card based on heater type
                        if heaterType == "LPG" {
                            ImpactCard(
                                title: "LPG Saved",
                                value: String(format: "%.4f kg", viewModel.totalLPGSaved),
                                icon: "flame.fill"
                            )
                        } else if heaterType == "Electric" {
                            ImpactCard(
                                title: "kWh Saved",
                                value: String(format: "%.2f", viewModel.totalEnergySaved),
                                icon: "bolt.fill"
                            )
                        } else {
                            // heaterType == "None" — no energy card needed
                            ImpactCard(
                                title: "Avg. Duration",
                                value: viewModel.averageShowerDuration,
                                icon: "clock.fill"
                            )
                        }
                    }

                    Text("Daily Progress").font(.headline)
                    ImpactChart(data: viewModel.chartData)

                    // Milestone Counter
                    VStack(alignment: .leading) {
                        Text("Environmental Milestone")
                            .font(.subheadline).bold()
                        Text("You've saved enough water to provide drinking water for one person for \(Int(viewModel.totalLitersSaved / 2.0)) days!")
                            .font(.callout).foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)

                    // ← FIX 2: Wire up onSessionComplete BEFORE showing the sheet,
                    //   so the finished shower is saved and the sheet auto-dismisses.
                    Button(action: {
                        timerViewModel.reset()
                        timerViewModel.onSessionComplete = { actualMinutes in
                            saveSession(actualMinutes: actualMinutes)
                            showingTimer = false
                        }
                        showingTimer = true
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "drop.circle.fill")
                                .font(.title2)
                            Text("Start New Shower")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .foregroundStyle(.white)
                        .background(Color.blue.gradient)
                        .cornerRadius(12)
                        .shadow(color: Color.blue.opacity(0.25), radius: 6, x: 0, y: 3)
                    }
                    .padding(.top, 8)
                }
                .padding()
            }
            .navigationTitle("Your Impact")
            .onAppear { recalculate() }
            // ← FIX 3: iOS 17+ two-argument onChange (suppresses deprecation warning).
            .onChange(of: profiles) { _, _ in recalculate() }
            .onChange(of: sessions) { _, _ in recalculate() }
            .sheet(isPresented: $showingTimer) {
                NavigationStack {
                    TimerView(viewModel: timerViewModel)
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                Button("Dismiss") {
                                    showingTimer = false
                                }
                            }
                        }
                }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
        }
    }

    // MARK: - Private Helpers

    /// Persists a completed shower session to SwiftData using the active hardware profile.
    private func saveSession(actualMinutes: Double) {
        guard let profile = profiles.first else { return }

        let session = ShowerSession(
            baselineDuration: Constants.baselineShowerDurationMinutes,
            actualDuration:   actualMinutes,
            hardware:         profile
        )
        modelContext.insert(session)
        try? modelContext.save()
    }

    private func recalculate() {
        if let profile = profiles.first {
            viewModel.calculateImpact(sessions: sessions, profile: profile)
        }
    }
}
