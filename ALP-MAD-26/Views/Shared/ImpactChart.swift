//
//  ImpactChart.swift
//  ALP-MAD-26
//
//  Created by student on 28/05/26.
//

import SwiftUI
import Charts

struct ImpactChart: View {
    var data: [DailyImpact]

    var body: some View {
        Chart(data) { point in
            // Using BarMark as requested for historical savings [5]
            BarMark(
                x: .value("Date", point.date, unit: .day),
                y: .value("Liters Saved", point.litersSaved)
            )
            .foregroundStyle(Color.blue.gradient)
            
            // Baseline Rule Mark to show target (National Average) [2]
            RuleMark(y: .value("Average", 75.0))
                .lineStyle(StrokeStyle(dash: [6]))
                .annotation(position: .top, alignment: .leading) {
                    Text("National Avg").font(.caption).foregroundColor(.secondary)
                }
        }
        .frame(height: 250)
    }
}
