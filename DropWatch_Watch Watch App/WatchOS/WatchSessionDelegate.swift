//
//  WatchSessionDelegate.swift
//  ALP-MAD-26
//
//  Created by student on 10/06/26.
//
//  TARGET MEMBERSHIP: watchOS ONLY (ALP-MAD-26 WatchKit Extension)
//
//  Handles WCSession activation on the Watch and sends completed shower
//  session data to the paired iPhone for SwiftData persistence.
//

import WatchConnectivity

final class WatchSessionDelegate: NSObject, WCSessionDelegate {
    func sessionDidBecomeInactive(_ session: WCSession) {
        WCSession.default.delegate?.sessionDidBecomeInactive(WCSession.default, )
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
    

    static let shared = WatchSessionDelegate()

    private override init() {
        super.init()
        activate()
    }

    // MARK: - Activation

    private func activate() {
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    // MARK: - Sending Data

    /// Sends a completed shower session to the iPhone.
    /// Uses `sendMessage` for real-time delivery; falls back to `transferUserInfo`
    /// (guaranteed, queued delivery) if the phone is not immediately reachable.
    func sendSession(actualDuration: Double, baselineDuration: Double) {
        let payload: [String: Any] = [
            "type":             "showerSession",
            "actualDuration":   actualDuration,
            "baselineDuration": baselineDuration,
            "timestamp":        Date().timeIntervalSince1970
        ]

        if WCSession.default.isReachable {
            WCSession.default.sendMessage(payload, replyHandler: nil) { [payload] _ in
                // Phone was not actually reachable at send time — queue it instead
                WCSession.default.transferUserInfo(payload)
            }
        } else {
            // Queue for delivery when the phone becomes available
            WCSession.default.transferUserInfo(payload)
        }
    }

    // MARK: - WCSessionDelegate (watchOS only requires activation callback)

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        if let error {
            print("[WatchSessionDelegate] WCSession activation error: \(error.localizedDescription)")
        }
    }
}
