//
//  WatchSessionSender.swift
//  ALP-MAD-26
//
//  Created by student on 10/06/26.
//

import WatchConnectivity
import Observation

@Observable
final class WatchSessionSender: NSObject {

    // MARK: - Published State

    /// True while a transferUserInfo/sendMessage call is in flight.
    var isSending: Bool = false

    // MARK: - Init

    override init() {
        super.init()
        activateSession()
    }

    // MARK: - Session Activation

    private func activateSession() {
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    // MARK: - Public API

    /// Sends completed shower data to the paired iPhone.
    /// Uses `sendMessage` for real-time delivery when the phone is reachable,
    /// otherwise falls back to guaranteed `transferUserInfo` queued delivery.
    func sendShowerSession(actualDuration: Double, baselineDuration: Double) {
        let payload: [String: Any] = [
            "type":             "showerSession",
            "actualDuration":   actualDuration,
            "baselineDuration": baselineDuration,
            "timestamp":        Date().timeIntervalSince1970
        ]

        isSending = true

        if WCSession.default.isReachable {
            WCSession.default.sendMessage(payload, replyHandler: { [weak self] _ in
                DispatchQueue.main.async { self?.isSending = false }
            }, errorHandler: { [weak self, payload] _ in
                // Phone not reachable at send time — queue it
                WCSession.default.transferUserInfo(payload)
                DispatchQueue.main.async { self?.isSending = false }
            })
        } else {
            WCSession.default.transferUserInfo(payload)
            DispatchQueue.main.async { self.isSending = false }
        }
    }
}

// MARK: - WCSessionDelegate

extension WatchSessionSender: WCSessionDelegate {

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        if let error {
            print("[WatchSessionSender] WCSession activation error: \(error.localizedDescription)")
        }
    }

    // watchOS does not call sessionDidBecomeInactive / sessionDidDeactivate,
    // but they are required by the protocol on some SDK versions.
    func sessionDidBecomeInactive(_ session: WCSession) {}

    func sessionDidDeactivate(_ session: WCSession) {
        // Re-activate to support Apple Watch device switching
        WCSession.default.activate()
    }
}
