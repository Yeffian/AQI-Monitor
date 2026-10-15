//
//  AQIScaleBarView.swift
//  aqi_monitor_mac
//
//  Created by Adit Chakraborty on 15/10/2026.
//

import SwiftUI

struct AQIScaleBarView: View {
    let aqi: Int?
 
    private let maxValue = 300.0
 
    private var gradient: Gradient {
        Gradient(stops: [
            .init(color: Color(red: 0.00, green: 0.89, blue: 0.00), location: 0.00), // Good
            .init(color: Color(red: 0.00, green: 0.89, blue: 0.00), location: 25 / maxValue),
            .init(color: Color(red: 1.00, green: 1.00, blue: 0.00), location: 75 / maxValue), // Moderate
            .init(color: Color(red: 1.00, green: 0.49, blue: 0.00), location: 125 / maxValue), // USG
            .init(color: Color(red: 1.00, green: 0.00, blue: 0.00), location: 175 / maxValue), // Unhealthy
            .init(color: Color(red: 0.56, green: 0.25, blue: 0.59), location: 250 / maxValue), // Very unhealthy
            .init(color: Color(red: 0.56, green: 0.25, blue: 0.59), location: 1.00)
        ])
    }
 
    var body: some View {
        VStack(spacing: 4) {
            GeometryReader { geo in
                let width = geo.size.width
                let fraction = min(Double(aqi ?? 0), maxValue) / maxValue
                let x = width * fraction
 
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(LinearGradient(gradient: gradient,
                                             startPoint: .leading,
                                             endPoint: .trailing))
                        .frame(height: 8)
                        .frame(maxHeight: .infinity)
 
                    if aqi != nil {
                        Circle()
                            .strokeBorder(.white, lineWidth: 3)
                            .background(Circle().fill(.black.opacity(0.35)))
                            .frame(width: 16, height: 16)
                            .shadow(color: .black.opacity(0.4), radius: 2, y: 1)
                            .offset(x: min(max(x - 8, 0), width - 16))
                            .animation(.easeInOut(duration: 0.4), value: aqi)
                    }
                }
            }
            .frame(height: 18)
 
            GeometryReader { geo in
                ForEach([0, 50, 100, 150, 200, 300], id: \.self) { tick in
                    Text(tick == 300 ? "300+" : "\(tick)")
                        .font(.system(size: 9).monospacedDigit())
                        .foregroundStyle(.secondary)
                        .fixedSize()
                        .position(x: labelX(for: tick, width: geo.size.width),
                                  y: geo.size.height / 2)
                }
            }
            .frame(height: 12)
        }
    }
 
    private func labelX(for tick: Int, width: CGFloat) -> CGFloat {
        let x = width * Double(tick) / maxValue
        return min(max(x, 8), width - 12) 
    }
}
