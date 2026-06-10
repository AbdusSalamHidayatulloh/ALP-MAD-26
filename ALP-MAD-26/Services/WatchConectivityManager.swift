//
//  WatchConnectivityManager.swift
//  ALP-MAD-26
//
//  Created by student on 10/06/26.
//
//  TARGET MEMBERSHIP: iOS ONLY (ALP-MAD-26)
//
//  Receives shower session data from the Apple Watch and surfaces it to the
//  SwiftUI layer via `pendingSession`. The App layer observes this property
//  and persists the session into SwiftData (see ALP_MAD_26App.swift).
//

import WatchConnectivity
import Observation

@Observable
final class WatchConnectivityManager: NSObject, WCSessionDelegate {

    // MARK: - Pending Session

    /// Set when a session arrives from the Watch. The App layer observes this,
    /// saves to SwiftData, then resets it to nil.
    var pendingSession: PendingShowerSession?

    struct PendingShowerSession: Equatable {
        let id              = UUID()   // Used by onChange(of:) to detect new arrivals
        let actualDuration:   Double
        let baselineDuration: Double
        let timestamp:        Date

        static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id }
    }

    // MARK: - Init

    override init() {
        super.init()
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    // MARK: - WCSessionDelegate

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        if let error {
            print("[WatchConnectivityManager] WCSession activation error: \(error.localizedDescription)")
        }
    }

    // Required on iOS (not watchOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}

    func sessionDidDeactivate(_ session: WCSession) {
        // Re-activate to support users who switch Apple Watch devices
        WCSession.default.activate()
    }

    /// Real-time delivery (phone was reachable when Watch sent)
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        handle(message)
    }

    /// Queued delivery (phone was not reachable; Watch used transferUserInfo)
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any]) {
        handle(userInfo)
    }

    // MARK: - Private

    private func handle(_ payload: [String: Any]) {
        guard
            payload["type"]             as? String   == "showerSession",
            let actual                               = payload["actualDuration"]   as? Double,
            let baseline                             = payload["baselineDuration"] as? Double,
            let ts                                   = payload["timestamp"]        as? TimeInterval
        else { return }

        DispatchQueue.main.async {
            self.pendingSession = PendingShowerSession(
                actualDuration:   actual,
                baselineDuration: baseline,
                timestamp:        Date(timeIntervalSince1970: ts)
            )
        }
    }
}
