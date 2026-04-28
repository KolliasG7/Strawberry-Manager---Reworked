// ProcessInfo.swift
// Process information model

import Foundation

struct ProcessInfo: Codable, Identifiable, Equatable {
    let pid: Int
    let threads: Int
    let name: String
    let user: String
    let status: String
    let cmdline: String
    let cpuPct: Double
    let memRssMb: Double
    let memPct: Double
    
    var id: Int { pid }
    
    enum CodingKeys: String, CodingKey {
        case pid, threads, name, user, status, cmdline
        case cpuPct = "cpu_pct"
        case memRssMb = "mem_rss_mb"
        case memPct = "mem_pct"
    }
}

struct ProcessListResponse: Codable {
    let processes: [ProcessInfo]
}
