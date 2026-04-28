// DashboardViewModel.swift
// Main dashboard view model managing telemetry and WebSocket connection

import Foundation
import Combine

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var telemetryFrame: TelemetryFrame?
    @Published var webSocketState: WebSocketState = .disconnected
    
    // History buffers for graphs (circular buffer, max 50 points)
    @Published var cpuHistory: [Double] = []
    @Published var ramHistory: [Double] = []
    @Published var tempHistory: [Double] = []
    @Published var fanHistory: [Double] = []
    
    private let maxHistoryPoints = 50
    
    private var webSocketService: WebSocketService?
    private var cancellables = Set<AnyCancellable>()
    
    let apiService: APIService
    
    init(apiService: APIService, baseURL: URL, token: String) {
        self.apiService = apiService
        
        // Initialize WebSocket service
        self.webSocketService = WebSocketService(baseURL: baseURL, token: token)
        
        setupSubscriptions()
        connectWebSocket()
    }
    
    private func setupSubscriptions() {
        // Subscribe to WebSocket state changes
        webSocketService?.$state
            .receive(on: DispatchQueue.main)
            .assign(to: &$webSocketState)
        
        // Subscribe to telemetry frames
        webSocketService?.telemetryPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] frame in
                self?.handleTelemetryFrame(frame)
            }
            .store(in: &cancellables)
    }
    
    private func handleTelemetryFrame(_ frame: TelemetryFrame) {
        telemetryFrame = frame
        
        // Update history buffers
        if let cpu = frame.cpu?.percent {
            appendToHistory(&cpuHistory, value: cpu)
        }
        
        if let ram = frame.ram?.percent {
            appendToHistory(&ramHistory, value: ram)
        }
        
        if let temp = frame.fan?.apuTempC {
            appendToHistory(&tempHistory, value: temp)
        }
        
        if let rpm = frame.fan?.rpm {
            appendToHistory(&fanHistory, value: Double(rpm))
        }
    }
    
    private func appendToHistory(_ history: inout [Double], value: Double) {
        history.append(value)
        if history.count > maxHistoryPoints {
            history.removeFirst()
        }
    }
    
    func connectWebSocket() {
        webSocketService?.connect()
    }
    
    func retryConnection() {
        webSocketService?.connect()
    }
    
    func updateURL(_ url: URL) {
        webSocketService?.updateURL(url)
    }
    
    deinit {
        webSocketService?.disconnect()
    }
}
