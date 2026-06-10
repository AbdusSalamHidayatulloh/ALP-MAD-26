//
//  DropWatch.swift
//  ALP-MAD-26
//
//  Created by student on 10/06/26.
//

import SwiftUI

@main
struct DropWatch_WatchApp: App {

    /// Single WCSession owner for the entire Watch app.
    @State private var sender = WatchSessionSender()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                WatchRootView()
            }
            .environment(sender)
        }
    }
}
