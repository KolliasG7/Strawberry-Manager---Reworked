// TelemetryGraph.swift
// Real-time telemetry graph using Swift Charts

import SwiftUI
import Charts

struct TelemetryGraph: View {
    let data: [Double]
    let color: Color
    let yAxisMax: Double
    let unit: String
    
    init(data: [Double], color: Color, yAxisMax: Double = 100, unit: String = "%") {
        self.data = data
        self.color = color
        self.yAxisMax = yAxisMax
        self.unit = unit
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let latest = data.last {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(String(format: "%.0f", latest))
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(color)
                    
                    Text(unit)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    // Min/Max indicators
                    if !data.isEmpty {
                        VStack(alignment: .trailing, spacing: 2) {
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.up")
                                    .font(.caption2)
                                Text(String(format: "%.0f", data.max() ?? 0))
                                    .font(.caption)
                            }
                            .foregroundStyle(.secondary)
                            
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.down")
                                    .font(.caption2)
                                Text(String(format: "%.0f", data.min() ?? 0))
                                    .font(.caption)
                            }
                            .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            
            if data.isEmpty {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.appSecondaryBackground)
                        .frame(height: 100)
                    
                    Text("Waiting for data...")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }
            } else {
                Chart {
                    ForEach(Array(data.enumerated()), id: \.offset) { index, value in
                        LineMark(
                            x: .value("Time", index),
                            y: .value("Value", value)
                        )
                        .foregroundStyle(color.gradient)
                        .interpolationMethod(.catmullRom)
                        
                        AreaMark(
                            x: .value("Time", index),
                            y: .value("Value", value)
                        )
                        .foregroundStyle(color.opacity(0.2).gradient)
                        .interpolationMethod(.catmullRom)
                    }
                }
                .chartYScale(domain: 0...yAxisMax)
                .chartXAxis(.hidden)
                .chartYAxis {
                    AxisMarks(position: .leading, values: [0, yAxisMax / 2, yAxisMax])
                }
                .frame(height: 100)
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        TelemetryGraph(
            data: [20, 25, 30, 35, 40, 45, 50, 55, 48, 42],
            color: .cyan,
            yAxisMax: 100,
            unit: "%"
        )
        .padding()
        .background(Color.appSecondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        
        TelemetryGraph(
            data: [55, 58, 62, 65, 68, 70, 72, 69, 65, 60],
            color: .orange,
            yAxisMax: 100,
            unit: "°C"
        )
        .padding()
        .background(Color.appSecondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    .padding()
}
