// MonitorTab.swift
// Monitoring tab with real-time telemetry display

import SwiftUI

struct MonitorTab: View {
    @ObservedObject var viewModel: DashboardViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Connection status banner
                if viewModel.webSocketState != .connected {
                    ConnectionBanner(state: viewModel.webSocketState) {
                        viewModel.retryConnection()
                    }
                }
                
                // System overview
                if let frame = viewModel.telemetryFrame {
                    SystemOverview(frame: frame)
                }
                
                // CPU Graph
                if !viewModel.cpuHistory.isEmpty {
                    TelemetryCard(title: "CPU Usage", icon: "cpu", accentColor: .cpuColor) {
                        TelemetryGraph(
                            data: viewModel.cpuHistory,
                            color: .cpuColor,
                            yAxisMax: 100,
                            unit: "%"
                        )
                        
                        if let cpu = viewModel.telemetryFrame?.cpu {
                            Divider()
                            
                            VStack(spacing: 8) {
                                MetricRow(label: "Cores", value: "\(cpu.coreCount)")
                                MetricRow(
                                    label: "Frequency",
                                    value: String(format: "%.1f GHz", cpu.freqMhz / 1000)
                                )
                                MetricRow(
                                    label: "Load (1m)",
                                    value: String(format: "%.2f", cpu.load1)
                                )
                            }
                        }
                    }
                }
                
                // RAM Graph
                if !viewModel.ramHistory.isEmpty {
                    TelemetryCard(title: "Memory Usage", icon: "memorychip", accentColor: .ramColor) {
                        TelemetryGraph(
                            data: viewModel.ramHistory,
                            color: .ramColor,
                            yAxisMax: 100,
                            unit: "%"
                        )
                        
                        if let ram = viewModel.telemetryFrame?.ram {
                            Divider()
                            
                            VStack(spacing: 8) {
                                MetricRow(
                                    label: "Total",
                                    value: String(format: "%.0f MB", ram.totalMb)
                                )
                                MetricRow(
                                    label: "Used",
                                    value: String(format: "%.0f MB", ram.usedMb)
                                )
                                MetricRow(
                                    label: "Cached",
                                    value: String(format: "%.0f MB", ram.cachedMb)
                                )
                            }
                        }
                    }
                }
                
                // Thermal Graph
                if !viewModel.tempHistory.isEmpty {
                    let tempColor: Color = {
                        guard let temp = viewModel.tempHistory.last else { return .cyan }
                        return Color.temperatureColor(for: temp)
                    }()
                    
                    TelemetryCard(title: "Temperature", icon: "thermometer.medium", accentColor: tempColor) {
                        TelemetryGraph(
                            data: viewModel.tempHistory,
                            color: tempColor,
                            yAxisMax: 100,
                            unit: "°C"
                        )
                        
                        if let fan = viewModel.telemetryFrame?.fan {
                            Divider()
                            
                            VStack(spacing: 8) {
                                MetricRow(
                                    label: "APU Temperature",
                                    value: String(format: "%.0f°C", fan.apuTempC),
                                    color: Color.temperatureColor(for: fan.apuTempC)
                                )
                                MetricRow(
                                    label: "Fan Speed",
                                    value: fan.rpm == 0 ? "Off" : "\(fan.rpm) RPM"
                                )
                                MetricRow(
                                    label: "Fan Threshold",
                                    value: "\(fan.thresholdC)°C"
                                )
                            }
                        }
                    }
                }
                
                // Disk and Network info
                if let frame = viewModel.telemetryFrame {
                    HStack(spacing: 16) {
                        // Primary disk
                        if let disk = frame.disk.first {
                            TelemetryCard(title: "Disk", icon: "internaldrive", accentColor: .purple) {
                                VStack(spacing: 8) {
                                    MetricRow(
                                        label: "Used",
                                        value: String(format: "%.1f / %.1f GB", disk.usedGb, disk.totalGb)
                                    )
                                    MetricRow(
                                        label: "Usage",
                                        value: String(format: "%.0f%%", disk.percent)
                                    )
                                }
                            }
                        }
                        
                        // Network
                        if let net = frame.primaryNet {
                            TelemetryCard(title: "Network", icon: "network", accentColor: .green) {
                                VStack(spacing: 8) {
                                    MetricRow(
                                        label: "↓ Download",
                                        value: formatBytes(net.bytesRecvS)
                                    )
                                    MetricRow(
                                        label: "↑ Upload",
                                        value: formatBytes(net.bytesSentS)
                                    )
                                }
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .background(Color.appBackground)
    }
    
    private func formatBytes(_ bytes: Double) -> String {
        let mb = bytes / 1024 / 1024
        if mb >= 1 {
            return String(format: "%.1f MB/s", mb)
        } else {
            let kb = bytes / 1024
            return String(format: "%.0f KB/s", kb)
        }
    }
}

// System overview card
struct SystemOverview: View {
    let frame: TelemetryFrame
    
    var body: some View {
        TelemetryCard(title: "System", icon: "server.rack", accentColor: .blue) {
            VStack(spacing: 8) {
                MetricRow(label: "Uptime", value: frame.uptimeFormatted)
                
                if let cpu = frame.cpu {
                    MetricRow(
                        label: "CPU",
                        value: String(format: "%.0f%%", cpu.percent),
                        color: .cyan
                    )
                }
                
                if let ram = frame.ram {
                    MetricRow(
                        label: "Memory",
                        value: String(format: "%.0f%%", ram.percent),
                        color: .purple
                    )
                }
                
                if let fan = frame.fan {
                    MetricRow(
                        label: "Temperature",
                        value: String(format: "%.0f°C", fan.apuTempC),
                        color: Color.temperatureColor(for: fan.apuTempC)
                    )
                }
            }
        }
    }
}

// Connection status banner
struct ConnectionBanner: View {
    let state: WebSocketState
    let onRetry: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: state == .connecting ? "antenna.radiowaves.left.and.right" : "exclamationmark.triangle")
                .foregroundStyle(state == .connecting ? .blue : .orange)
            
            Text(state == .connecting ? "Connecting..." : "Disconnected")
                .font(.subheadline)
                .foregroundStyle(.primary)
            
            Spacer()
            
            if state == .disconnected {
                Button("Retry") {
                    onRetry()
                }
                .font(.subheadline.weight(.medium))
            } else {
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(0.8)
            }
        }
        .padding()
        .background(Color.appSecondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    // Mock ViewModel for preview
    class MockDashboardViewModel: DashboardViewModel {
        init() {
            let mockAPI = APIService(baseURL: URL(string: "http://localhost")!, token: "")
            super.init(
                apiService: mockAPI,
                baseURL: URL(string: "http://localhost")!,
                token: ""
            )
            
            // Add mock data
            self.cpuHistory = [20, 25, 30, 35, 40, 45, 50, 45, 40, 35]
            self.ramHistory = [60, 62, 65, 63, 68, 70, 72, 69, 65, 63]
            self.tempHistory = [55, 58, 62, 65, 68, 70, 68, 65, 60, 58]
            self.fanHistory = [3000, 3200, 3400, 3600, 3800, 4000, 3800, 3600, 3400, 3200]
            
            // Mock frame
            self.telemetryFrame = TelemetryFrame(
                ts: Date().timeIntervalSince1970,
                fan: FanData(rpm: 3500, thresholdC: 70, apuTempC: 65),
                cpu: CPUData(percent: 35, perCore: [30, 35, 40, 35], coreCount: 4, freqMhz: 2400, freqMaxMhz: 3000, load1: 1.5, load5: 1.3, load15: 1.1),
                ram: RAMData(totalMb: 8192, usedMb: 5120, availableMb: 3072, cachedMb: 1024, buffersMb: 512, percent: 62.5),
                swap: nil,
                disk: [DiskData(mount: "/", device: "/dev/sda1", fstype: "ext4", totalGb: 500, usedGb: 250, freeGb: 250, percent: 50, readBps: 1024, writeBps: 2048)],
                net: [NetData(iface: "eth0", bytesSentS: 1024000, bytesRecvS: 2048000, packetsSent: 100, packetsRecv: 150, errin: 0, errout: 0)],
                uptimeS: 86400,
                tunnel: nil,
                error: nil
            )
            
            self.webSocketState = .connected
        }
    }
    
    return NavigationStack {
        MonitorTab(viewModel: MockDashboardViewModel())
            .navigationTitle("Monitor")
    }
}
