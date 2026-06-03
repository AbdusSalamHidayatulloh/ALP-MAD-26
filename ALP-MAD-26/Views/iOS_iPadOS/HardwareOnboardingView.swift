//
//  HardwareOnboardingView.swift
//  ALP-MAD-26
//
//  Created by student on 03/06/26.
//

import SwiftUI
import SwiftData

struct HardwareOnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = OnboardingViewModel()
    
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 35) {
                    
                    // MARK: - Header
                    VStack(spacing: 8) {
                        Text("Welcome to DropWatch")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text("Let's calibrate your tracking.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 40)
                    
                    // MARK: - Name Input
                    VStack(alignment: .leading) {
                        Text("What should we call you?")
                            .font(.headline)
                        TextField("Enter your name", text: $viewModel.userName)
                            .textFieldStyle(.roundedBorder)
                            .autocorrectionDisabled()
                    }
                    .padding(.horizontal)
                    
                    // MARK: - Showerhead Selection
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Select your shower hardware")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        HStack(spacing: 12) {
                            ForEach(OnboardingViewModel.ShowerheadType.allCases, id: \.self) { type in
                                ShowerheadCard(
                                    type: type,
                                    isSelected: viewModel.selectedShowerhead == type
                                ) {
                                    viewModel.selectedShowerhead = type
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // MARK: - Water Heater Configuration
                    VStack(alignment: .leading, spacing: 15) {
                        Toggle("I use a Water Heater", isOn: $viewModel.hasWaterHeater)
                            .font(.headline)
                            .padding(.horizontal)
                            .tint(.blue)
                        
                        // Only show the heater type picker if they actually have a heater
                        if viewModel.hasWaterHeater {
                            Picker("Heater Type", selection: $viewModel.heaterType) {
                                ForEach(OnboardingViewModel.HeaterType.allCases, id: \.self) { type in
                                    Text(type.rawValue).tag(type)
                                }
                            }
                            .pickerStyle(.segmented)
                            .padding(.horizontal)
                        }
                    }
                    
                    Spacer(minLength: 40)
                    
                    // MARK: - Complete Button
                    Button(action: completeOnboarding) {
                        Text("Get Started")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(viewModel.isFormValid ? Color.blue : Color.gray)
                            .cornerRadius(12)
                    }
                    .disabled(!viewModel.isFormValid)
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
        }
    }
    
    // MARK: - Save Logic
    private func completeOnboarding() {
        guard let selected = viewModel.selectedShowerhead else { return }
        
        // Save using the new HardwareProfile format
        let newProfile = HardwareProfile(
            userName: viewModel.userName,
            flowRateLPM: selected.flowRateLPM,          // Translated visual selection to Double!
            hasWaterHeater: viewModel.hasWaterHeater,
            heaterType: viewModel.heaterType.rawValue
        )
        
        modelContext.insert(newProfile)
        hasCompletedOnboarding = true
    }
}

// MARK: - Custom Reusable Card Subview
struct ShowerheadCard: View {
    let type: OnboardingViewModel.ShowerheadType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                // Relies on your local Image assets: "eco", "standard", "rainfall"
                Image(type.rawValue)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 70)
                    .padding(10)
                
                Text(type.displayName)
                    .font(.caption)
                    .fontWeight(isSelected ? .bold : .regular)
                    .multilineTextAlignment(.center)
                    .foregroundColor(isSelected ? .blue : .primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.secondary.opacity(0.05))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 3)
            )
        }
        .buttonStyle(.plain)
    }
}
