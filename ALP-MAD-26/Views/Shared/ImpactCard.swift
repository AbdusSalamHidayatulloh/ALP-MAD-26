//
//  ImpactCard.swift
//  ALP-MAD-26
//
//  Created by student on 28/05/26.
//


import SwiftUI

struct ImpactCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.headline)
                    .foregroundColor(.blue)
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.system(.title2, design: .rounded))
                .bold()
                .contentTransition(.numericText()) // For smooth animation
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(15)
    }
}
