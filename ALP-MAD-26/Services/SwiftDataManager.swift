//
//  SwiftDataManager.swift
//  ALP-MAD-26
//
//  Created by student on 10/06/26.
//

import SwiftData
import Foundation

public let sharedModelContainer: ModelContainer = {
    let schema = Schema([
        ShowerSession.self,
        HardwareProfile.self
    ])
    
    // Point SwiftData to the shared App Group directory
    let storeURL = FileManager.default
        .containerURL(forSecurityApplicationGroupIdentifier: "group.com.yourteam.DropWatch")!
        .appendingPathComponent("DropWatch.sqlite")
        
    let modelConfiguration = ModelConfiguration(url: storeURL)
    
    do {
        return try ModelContainer(for: schema, configurations: [modelConfiguration])
    } catch {
        fatalError("Could not create ModelContainer: \(error)")
    }
}()
