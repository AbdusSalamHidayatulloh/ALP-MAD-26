//
//  CircularProgressRing.swift
//  ALP-MAD-26
//
//  Created by student on 10/06/26.
//
//  TARGET MEMBERSHIP: iOS (ALP-MAD-26) + watchOS (ALP-MAD-26 WatchKit Extension)
//

import SwiftUI

struct CircularProgressRing: View {
    /// Progress from 0.0 to 1.0
    var progress:  Double
    var ringColor: Color
    var lineWidth: CGFloat = 14

    var body: some View {
        ZStack {
            // Track
            Circle()
                .stroke(ringColor.opacity(0.2), lineWidth: lineWidth)

            // Fill
            Circle()
                .trim(from: 0, to: max(0, min(1, progress)))
                .stroke(
                    ringColor,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1.0), value: progress)
        }
    }
}
