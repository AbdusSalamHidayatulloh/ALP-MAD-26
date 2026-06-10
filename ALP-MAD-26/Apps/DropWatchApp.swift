//
//  ALP_MAD_26App.swift
//  ALP-MAD-26
//
//  Created by student on 28/05/26.
//  Updated by student on 10/06/26.
//   → Added WatchConnectivityManager wiring.
//   → DashboardView is unchanged.
//

import SwiftUI
import SwiftData

@main
struct DropWatchApp: App {

    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false

    /// Owns the WCSession lifetime for the entire app.
    @State private var watchManager = WatchConnectivityManager()

    var body: some Scene {
        WindowGroup {
            // ContentRoot bridges the modelContext (from .modelContainer below)
            // with the watchManager so it can save incoming Watch sessions.
            ContentRoot(hasCompletedOnboarding: $hasCompletedOnboarding)
                .environment(watchManager)
        }
        .modelContainer(for: [HardwareProfile.self, ShowerSession.self])
    }
}

private struct ContentRoot: View {

    @Binding var hasCompletedOnboarding: Bool

    @Environment(WatchConnectivityManager.self) private var watchManager
    @Environment(\.modelContext)               private var modelContext
    
    // Fetch stored hardware profiles from SwiftData
    @Query private var hardwareProfiles: [HardwareProfile]

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                DashboardView()
            } else {
                HardwareOnboardingView()
            }
        }
        // Fixed: Change the closure signature to expect exactly 1 argument (the new pending value)
        .onChange(of: watchManager.pendingSession) { pending in
            guard let pending else { return }
            
            // Safe fallback: Find the active profile or use standard as a temporary backup
            let activeHardware = hardwareProfiles.first(where: { $0.isActive })
                ?? hardwareProfiles.first
                ?? HardwareProfile(userName: "User", flowRateLPM: Constants.FlowRate.standard)
            
            let session = ShowerSession(
                baselineDuration: pending.baselineDuration,
                actualDuration:   pending.actualDuration,
                timestamp:        pending.timestamp,
                hardware:         activeHardware
            )
            
            modelContext.insert(session)
            try? modelContext.save()
            
            // Clear so a subsequent session with the same duration still triggers onChange
            watchManager.pendingSession = nil
        }
    }
}
