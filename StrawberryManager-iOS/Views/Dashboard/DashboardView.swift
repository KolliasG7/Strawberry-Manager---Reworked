// DashboardView.swift
// Main dashboard with tab navigation - Updated with real monitoring

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var connectionViewModel: ConnectionViewModel
    @StateObject private var dashboardViewModel: DashboardViewModel
    @State private var selectedTab = 0
    
    init() {
        // Initialize with connection details from environment
        // Note: In real usage, this will be properly injected
        let mockAPI = APIService(baseURL: URL(string: "http://localhost")!, token: "")
        let mockURL = URL(string: "http://localhost")!
        _dashboardViewModel = StateObject(wrappedValue: DashboardViewModel(
            apiService: mockAPI,
            baseURL: mockURL,
            token: ""
        ))
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                MonitorTab(viewModel: dashboardViewModel)
                    .navigationTitle("Monitor")
                    .navigationBarTitleDisplayMode(.large)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                // Settings action
                            } label: {
                                Image(systemName: "gearshape")
                            }
                        }
                    }
            }
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
struct ControlTabPlaceholder: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 64))
                    .foregroundStyle(.secondary)
                
                Text("Control Tab")
                    .font(.title2.weight(.semibold))
                
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
            VStack(spacing: 16) {
                Image(systemName: "terminal")
                    .font(.system(size: 64))
                    .foregroundStyle(.secondary)
                
                Text("Terminal")
                    .font(.title2.weight(.semibold))
                
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
            VStack(spacing: 16) {
                Image(systemName: "folder")
                    .font(.system(size: 64))
                    .foregroundStyle(.secondary)
                
                Text("Files")
                    .font(.title2.weight(.semibold))
                
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
        .environmentObject(ConnectionViewModel())
}
