// ConnectionState.swift
// Connection state management

import Foundation

enum ConnectionState: Equatable {
    case idle
    case connecting
    case connected
    case error(String)
    case needsAuth
    
    var isConnected: Bool {
        if case .connected = self { return true }
        return false
    }
    
    var errorMessage: String? {
        if case .error(let message) = self { return message }
        return nil
    }
}
