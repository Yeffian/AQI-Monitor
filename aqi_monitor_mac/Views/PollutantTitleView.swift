//
//  PollutantTitle.swift
//  aqi_monitor_mac
//
//  Created by Adit Chakraborty on 15/10/2026.
//

import SwiftUI

struct PollutantTileView: View {
    let name: String
    let value: Double?
 
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(name)
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack(alignment: .firstTextBaseline, spacing: 3) {
                Text(value.map { String(format: "%.1f", $0) } ?? "–")
                    .font(.title3.weight(.semibold).monospacedDigit())
                Text("µg/m³")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .background(RoundedRectangle(cornerRadius: 8).fill(.quaternary.opacity(0.5)))
    }
}
