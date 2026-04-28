// Color+Theme.swift
// App color palette and theme extensions

import SwiftUI

extension Color {
    // Brand colors
    static let appPrimary = Color.blue
    static let appBackground = Color(uiColor: .systemBackground)
    static let appSecondaryBackground = Color(uiColor: .secondarySystemBackground)
    
    // Status colors
    static let statusGreen = Color.green
    static let statusYellow = Color.yellow
    static let statusOrange = Color.orange
    static let statusRed = Color.red
    
    // Telemetry colors
    static let cpuColor = Color.cyan
    static let ramColor = Color.purple
    static let tempColorCool = Color.cyan
    static let tempColorWarm = Color.orange
    static let tempColorHot = Color.red
    
    // Temperature gradient
    static func temperatureColor(for celsius: Double) -> Color {
        if celsius < 55 {
            return .cyan
        } else if celsius < 70 {
            return .orange
        } else {
            return .red
        }
    }
    
    // Fan threshold gradient
    static func fanThresholdColor(for celsius: Int) -> Color {
        if celsius >= 70 {
            return .red
        } else if celsius >= 55 {
            return .orange
        } else {
            return .cyan
        }
    }
}
