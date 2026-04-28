// WebSocketService.swift
// WebSocket service for real-time telemetry streaming

import Foundation
import Combine

enum WebSocketState: Equatable {
    case disconnected
    case connecting
    case connected
}

class WebSocketService: NSObject, ObservableObject {
    @Published var state: WebSocketState = .disconnected
    @Published var latestFrame: TelemetryFrame?
    
    private var webSocketTask: URLSessionWebSocketTask?
    private var baseURL: URL
    private var token: String
    private var cancellables = Set<AnyCancellable>()
    
    private var reconnectAttempts = 0
    private let maxReconnectDelay = 30.0
    private var reconnectTimer: Timer?
    
    private let telemetrySubject = PassthroughSubject<TelemetryFrame, Never>()
    var telemetryPublisher: AnyPublisher<TelemetryFrame, Never> {
        telemetrySubject.eraseToAnyPublisher()
    }
    
    init(baseURL: URL, token: String) {
        self.baseURL = baseURL
        self.token = token
        super.init()
    }
    
    func updateURL(_ url: URL) {
        self.baseURL = url
        disconnect()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.connect()
        }
    }
    
    func updateToken(_ newToken: String) {
        self.token = newToken
    }
    
    func connect() {
        disconnect()
        reconnectAttempts = 0
        tryConnect()
    }
    
    private func tryConnect() {
        state = .connecting
        
        // Convert HTTP(S) URL to WS(S)
        var wsURLString = baseURL.absoluteString
        if wsURLString.hasPrefix("https://") {
            wsURLString = wsURLString.replacingOccurrences(of: "https://", with: "wss://")
        } else if wsURLString.hasPrefix("http://") {
            wsURLString = wsURLString.replacingOccurrences(of: "http://", with: "ws://")
        } else {
            wsURLString = "ws://\(wsURLString)"
        }
        
        guard let wsURL = URL(string: "\(wsURLString)/ws/telemetry") else {
            scheduleReconnect()
            return
        }
        
        var request = URLRequest(url: wsURL)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        webSocketTask = URLSession.shared.webSocketTask(with: request)
        webSocketTask?.resume()
        
        receiveMessage()
    }
    
    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let message):
                self.handleMessage(message)
                self.receiveMessage() // Continue receiving
                
            case .failure(let error):
                print("[WebSocketService] Receive error: \(error)")
                self.scheduleReconnect()
            }
        }
    }
    
    private func handleMessage(_ message: URLSessionWebSocketTask.Message) {
        switch message {
        case .string(let text):
            guard let data = text.data(using: .utf8) else { return }
            decodeFrame(data)
            
        case .data(let data):
            decodeFrame(data)
            
        @unknown default:
            break
        }
    }
    
    private func decodeFrame(_ data: Data) {
        do {
            let decoder = JSONDecoder()
            let frame = try decoder.decode(TelemetryFrame.self, from: data)
            
            DispatchQueue.main.async { [weak self] in
                self?.reconnectAttempts = 0
                self?.state = .connected
                self?.latestFrame = frame
                self?.telemetrySubject.send(frame)
            }
        } catch {
            print("[WebSocketService] Decode error: \(error)")
        }
    }
    
    private func scheduleReconnect() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.state = .disconnected
            self.reconnectTimer?.invalidate()
            
            let delay = min(pow(2.0, Double(self.reconnectAttempts)), self.maxReconnectDelay)
            
            self.reconnectTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
                guard let self = self else { return }
                self.reconnectAttempts += 1
                self.tryConnect()
            }
        }
    }
    
    func disconnect() {
        reconnectTimer?.invalidate()
        reconnectTimer = nil
        
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        
        DispatchQueue.main.async { [weak self] in
            self?.state = .disconnected
        }
    }
    
    deinit {
        disconnect()
    }
}
