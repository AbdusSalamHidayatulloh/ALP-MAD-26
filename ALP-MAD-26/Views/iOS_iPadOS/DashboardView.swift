//
//  DashboardView.swift
//  ALP-MAD-26
//
//  Created by student on 28/05/26.
//

import SwiftUI
import SwiftData

struct DashboardView: View {
    @State private var viewModel = DashboardViewModel()
    @Query private var sessions: [ShowerSession]
    @Query private var profiles: [HardwareProfile]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Impact Summary Cards
                    HStack {
                        ImpactCard(title: "Liters Saved", value: "\(Int(viewModel.totalLitersSaved))L", icon: "drop.fill")
                        ImpactCard(title: "kWh Saved", value: String(format: "%.2f", viewModel.totalEnergySaved), icon: "bolt.fill")
                    }
                    
                    Text("Daily Progress").font(.headline)
                    ImpactChart(data: viewModel.chartData)
                    
                    // Milestone Counter [2]
                    VStack(alignment: .leading) {
                        Text("Environmental Milestone")
                            .font(.subheadline).bold()
                        Text("You've saved enough water to provide drinking water for one person for \(Int(viewModel.totalLitersSaved / 2.0)) days!")
                            .font(.callout).foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("Your Impact")
            .onAppear {
                if let profile = profiles.first {
                    viewModel.calculateImpact(sessions: sessions, profile: profile)
                }
            }
        }
    }
}
