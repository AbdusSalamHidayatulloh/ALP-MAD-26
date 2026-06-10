//
//  WatchConnectivityManager.swift
//  ALP-MAD-26
//
//  Created by student on 10/06/26.
//

import WatchConnectivity
import Observation

@Observable
final class WatchConnectivityManager: NSObject, WCSessionDelegate {

    // MARK: - Pending Session

    var pendingSession: PendingShowerSession?

    struct PendingShowerSession: Equatable {
        let id              = UUID()
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

    // MARK: - WCSessionDelegate Shared

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        if let error {
            print("[WatchConnectivityManager] WCSession activation error: \(error.localizedDescription)")
        }
    }

    // MARK: - iOS Specific Delegate Methods
    // Fixed: Wrapped in an OS directive so the watchOS compiler completely skips them
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}

    func sessionDidDeactivate(_ session: WCSession) {
        // Re-activate to support users who switch Apple Watch devices
        WCSession.default.activate()
    }
    #endif

    /// Real-time delivery (device was reachable when data was dispatched)
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        handle(message)
    }

    /// Queued delivery (device was out of range; background synchronization cached it)
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any]) {
        handle(userInfo)
    }

    // MARK: - Private Handler

    private func handle(_ payload: [String: Any]) {
        guard
            payload["type"]             as? String   == "showerSession",
            let actual                               = payload["actualDuration"]   as? Double,
            let baseline                             = payload["baselineDuration"] as? Double,
            let ts                                   = payload["timestamp"]        as? TimeInterval
        else { return }

        // Ensure state writes execute directly onto the main thread loop
        DispatchQueue.main.async {
            self.pendingSession = PendingShowerSession(
                actualDuration:   actual,
                baselineDuration: baseline,
                timestamp:        Date(timeIntervalSince1970: ts)
            )
        }
    }
}
