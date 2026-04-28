// DashboardView.swift
// Main dashboard with tab navigation

import SwiftUI

struct DashboardView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            MonitorTabPlaceholder()
                .tabItem {
                    Label("Monitor", systemImage: "chart.xyaxis.line")
                }
                .tag(0)
            
            ControlTabPlaceholder()
                .tabItem {
                    Label("Control", systemImage: "slider.horizontal.3")
                }
                .tag(1)
            
            TerminalPlaceholder()
                .tabItem {
                    Label("Terminal", systemImage: "terminal")
                }
                .tag(2)
            
            FilesPlaceholder()
                .tabItem {
                    Label("Files", systemImage: "folder")
                }
                .tag(3)
        }
    }
}

// Placeholder views - to be implemented in later phases
struct MonitorTabPlaceholder: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Monitor Tab")
                Text("Phase 2: Telemetry visualization")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("Monitor")
        }
    }
}

struct ControlTabPlaceholder: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Control Tab")
                Text("Phase 3: Fan/LED controls")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("Control")
        }
    }
}

struct TerminalPlaceholder: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Terminal")
                Text("Phase 4: Interactive terminal")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("Terminal")
        }
    }
}

struct FilesPlaceholder: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Files")
                Text("Phase 5: File manager")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("Files")
        }
    }
}

#Preview {
    DashboardView()
}
