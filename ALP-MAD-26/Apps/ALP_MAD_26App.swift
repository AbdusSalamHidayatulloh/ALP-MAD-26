//
//  ALP_MAD_26App.swift
//  ALP-MAD-26
//
//  Created by student on 28/05/26.
//


import SwiftUI
import SwiftData

@main
struct DropWatchApp: App {
    // This looks in the device's UserDefaults.
    // It defaults to 'false' on a fresh install.
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    
    var body: some Scene {
        WindowGroup {
            // Our Routing Logic
            if hasCompletedOnboarding {
                // If they finished setup, take them to the main app
                DashboardView()
            } else {
                // If it is their first time, instantly show onboarding
                HardwareOnboardingView()
            }
        }
        // CRITICAL: This injects your local database into the entire app.
        // Without this, the app will crash when they tap "Get Started"!
        .modelContainer(for: [HardwareProfile.self, ShowerSession.self])
    }
}
