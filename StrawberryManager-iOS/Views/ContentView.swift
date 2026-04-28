// ContentView.swift
// Root navigation controller

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var connectionViewModel: ConnectionViewModel
    
    var body: some View {
        Group {
            switch connectionViewModel.state {
            case .idle, .connecting, .error, .needsAuth:
                ConnectView()
            case .connected:
                DashboardView()
            }
        }
        .animation(.easeInOut, value: connectionViewModel.state)
    }
}

#Preview {
    ContentView()
        .environmentObject(ConnectionViewModel())
}
