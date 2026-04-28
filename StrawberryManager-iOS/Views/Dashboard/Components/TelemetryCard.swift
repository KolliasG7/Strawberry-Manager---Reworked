// TelemetryCard.swift
// Reusable card component for displaying telemetry data

import SwiftUI

struct TelemetryCard<Content: View>: View {
    let title: String
    let icon: String
    let accentColor: Color
    let content: Content
    
    init(
        title: String,
        icon: String,
        accentColor: Color = .blue,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.icon = icon
        self.accentColor = accentColor
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(accentColor)
                    .font(.title3)
                
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Spacer()
            }
            
            content
        }
        .padding()
        .background(Color.appSecondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// Metric row component
struct MetricRow: View {
    let label: String
    let value: String
    let color: Color?
    
    init(label: String, value: String, color: Color? = nil) {
        self.label = label
        self.value = value
        self.color = color
    }
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Text(value)
                .fontWeight(.medium)
                .foregroundStyle(color ?? .primary)
        }
        .font(.subheadline)
    }
}

// Large metric display
struct LargeMetric: View {
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            Text(value)
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundStyle(color)
            
            Text(unit)
                .font(.title2)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        TelemetryCard(title: "CPU", icon: "cpu", accentColor: .cyan) {
            LargeMetric(value: "45", unit: "%", color: .cyan)
            
            Divider()
            
            VStack(spacing: 8) {
                MetricRow(label: "Cores", value: "8")
                MetricRow(label: "Frequency", value: "2.4 GHz")
                MetricRow(label: "Load (1m)", value: "1.23")
            }
        }
        
        TelemetryCard(title: "Temperature", icon: "thermometer.medium", accentColor: .orange) {
            LargeMetric(value: "68", unit: "°C", color: .orange)
        }
    }
    .padding()
    .background(Color.appBackground)
}
