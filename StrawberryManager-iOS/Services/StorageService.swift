// StorageService.swift
// UserDefaults wrapper for persistent storage

import Foundation

class StorageService {
    static let shared = StorageService()
    
    private let defaults = UserDefaults.standard
    
    private enum Keys {
        static let serverAddress = "ps4_addr"
        static let isTunnel = "ps4_is_tunnel"
        static let authToken = "ps4_token"
        static let showCPUGraph = "show_cpu_graph"
        static let showRAMGraph = "show_ram_graph"
        static let showThermalGraph = "show_thermal_graph"
        static let showNotifications = "show_notifications"
        static let reduceMotion = "reduce_motion"
    }
    
    private init() {}
    
    // MARK: - Connection Settings
    
    var serverAddress: String? {
        get { defaults.string(forKey: Keys.serverAddress) }
        set { defaults.set(newValue, forKey: Keys.serverAddress) }
    }
    
    var isTunnel: Bool {
        get { defaults.bool(forKey: Keys.isTunnel) }
        set { defaults.set(newValue, forKey: Keys.isTunnel) }
    }
    
    var authToken: String? {
        get { defaults.string(forKey: Keys.authToken) }
        set { defaults.set(newValue, forKey: Keys.authToken) }
    }
    
    // MARK: - UI Preferences
    
    var showCPUGraph: Bool {
        get { defaults.object(forKey: Keys.showCPUGraph) as? Bool ?? true }
        set { defaults.set(newValue, forKey: Keys.showCPUGraph) }
    }
    
    var showRAMGraph: Bool {
        get { defaults.object(forKey: Keys.showRAMGraph) as? Bool ?? true }
        set { defaults.set(newValue, forKey: Keys.showRAMGraph) }
    }
    
    var showThermalGraph: Bool {
        get { defaults.object(forKey: Keys.showThermalGraph) as? Bool ?? true }
        set { defaults.set(newValue, forKey: Keys.showThermalGraph) }
    }
    
    var showNotifications: Bool {
        get { defaults.object(forKey: Keys.showNotifications) as? Bool ?? true }
        set { defaults.set(newValue, forKey: Keys.showNotifications) }
    }
    
    var reduceMotion: Bool {
        get { defaults.bool(forKey: Keys.reduceMotion) }
        set { defaults.set(newValue, forKey: Keys.reduceMotion) }
    }
    
    // MARK: - Utility Methods
    
    func clearAll() {
        serverAddress = nil
        authToken = nil
        isTunnel = false
    }
}
