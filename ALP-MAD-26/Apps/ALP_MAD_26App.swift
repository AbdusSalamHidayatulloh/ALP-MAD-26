//
//  ALP_MAD_26App.swift
//  ALP-MAD-26
//
//  Created by student on 28/05/26.
//


import SwiftUI
import SwiftData

@main
struct ALP_MAD_26App: App {
    var body: some Scene {
        WindowGroup {
            DashboardView()
        }
        .modelContainer(for: [ShowerSession.self, HardwareProfile.self]) 
    }
}
