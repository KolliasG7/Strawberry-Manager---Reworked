// Telemetry.swift
// Telemetry data models matching backend API

import Foundation

struct TelemetryFrame: Codable, Equatable {
    let ts: Double
    let fan: FanData?
    let cpu: CPUData?
    let ram: RAMData?
    let swap: SwapData?
    let disk: [DiskData]
    let net: [NetData]
    let uptimeS: Int
    let tunnel: TunnelStatus?
    let error: String?
    
    enum CodingKeys: String, CodingKey {
        case ts, fan, cpu, ram, swap, disk, net
        case uptimeS = "uptime_s"
        case tunnel, error
    }
    
    var isError: Bool { error != nil }
    
    var uptimeFormatted: String {
        let days = uptimeS / 86400
        let hours = (uptimeS % 86400) / 3600
        let minutes = (uptimeS % 3600) / 60
        
        if days > 0 {
            return "\(days)d \(hours)h \(minutes)m"
        } else if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    var primaryNet: NetData? {
        guard !net.isEmpty else { return nil }
        // Find first non-loopback interface with traffic
        return net.first { $0.iface != "lo" && ($0.bytesSentS > 0 || $0.bytesRecvS > 0) }
            ?? net.first { $0.iface != "lo" }
            ?? net.first
    }
}

struct CPUData: Codable, Equatable {
    let percent: Double
    let perCore: [Double]
    let coreCount: Int
    let freqMhz: Double
    let freqMaxMhz: Double
    let load1: Double
    let load5: Double
    let load15: Double
    
    enum CodingKeys: String, CodingKey {
        case percent
        case perCore = "per_core"
        case coreCount = "core_count"
        case freqMhz = "freq_mhz"
        case freqMaxMhz = "freq_max_mhz"
        case load1 = "load_1"
        case load5 = "load_5"
        case load15 = "load_15"
    }
}

struct RAMData: Codable, Equatable {
    let totalMb: Double
    let usedMb: Double
    let availableMb: Double
    let cachedMb: Double
    let buffersMb: Double
    let percent: Double
    
    enum CodingKeys: String, CodingKey {
        case totalMb = "total_mb"
        case usedMb = "used_mb"
        case availableMb = "available_mb"
        case cachedMb = "cached_mb"
        case buffersMb = "buffers_mb"
        case percent
    }
}

struct SwapData: Codable, Equatable {
    let totalMb: Double
    let usedMb: Double
    let percent: Double
    
    enum CodingKeys: String, CodingKey {
        case totalMb = "total_mb"
        case usedMb = "used_mb"
        case percent
    }
}

struct DiskData: Codable, Equatable {
    let mount: String
    let device: String
    let fstype: String
    let totalGb: Double
    let usedGb: Double
    let freeGb: Double
    let percent: Double
    let readBps: Double
    let writeBps: Double
    
    enum CodingKeys: String, CodingKey {
        case mount, device, fstype
        case totalGb = "total_gb"
        case usedGb = "used_gb"
        case freeGb = "free_gb"
        case percent
        case readBps = "read_bps"
        case writeBps = "write_bps"
    }
}

struct NetData: Codable, Equatable {
    let iface: String
    let bytesSentS: Double
    let bytesRecvS: Double
    let packetsSent: Int
    let packetsRecv: Int
    let errin: Int
    let errout: Int
    
    enum CodingKeys: String, CodingKey {
        case iface
        case bytesSentS = "bytes_sent_s"
        case bytesRecvS = "bytes_recv_s"
        case packetsSent = "packets_sent"
        case packetsRecv = "packets_recv"
        case errin, errout
    }
}

struct FanData: Codable, Equatable {
    let rpm: Int
    let thresholdC: Int
    let apuTempC: Double
    
    enum CodingKeys: String, CodingKey {
        case rpm
        case thresholdC = "threshold_c"
        case apuTempC = "apu_temp_c"
    }
}

struct TunnelStatus: Codable, Equatable {
    let state: String
    let url: String?
    
    var isRunning: Bool { state == "running" }
}
