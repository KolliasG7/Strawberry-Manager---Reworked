# Swift iOS Migration Plan - Strawberry Manager

## Executive Summary

This document outlines the complete migration plan for rewriting Strawberry Manager from Flutter/Dart to native Swift/SwiftUI for iOS. This is a **major undertaking** requiring 80-120 hours of development time over 8-12 weeks.

**Status**: Planning Phase  
**Target**: iOS 17.0+ (SwiftUI 5.0)  
**Timeline**: 8-12 weeks  
**Effort**: 80-120 developer hours  

---

## Current State Analysis

### Flutter/Dart Codebase
- **Total LOC**: ~3,500 lines
- **Architecture**: Provider pattern, service-based
- **Platforms**: iOS, Android, macOS, Linux
- **Key Features**: 15 major features across 7 screens
- **Dependencies**: 12 packages (HTTP, WebSocket, notifications, charts, file picker, etc.)

### What We're Losing
❌ Android app functionality  
❌ Android Quick Settings tiles  
❌ macOS/Linux support  
❌ Cross-platform maintenance  
❌ Flutter's hot reload during development  

### What We're Gaining
✅ Native iOS performance  
✅ SwiftUI modern declarative syntax  
✅ Better iOS system integration  
✅ Access to latest iOS APIs immediately  
✅ Smaller app size (~30% reduction)  
✅ Better battery efficiency  
✅ Native iOS animations and gestures  

---

## Architecture Design

### Technology Stack

```
┌─────────────────────────────────────────────────┐
│                 SwiftUI Views                    │
├─────────────────────────────────────────────────┤
│              View Models (MVVM)                  │
├─────────────────────────────────────────────────┤
│         Services Layer (Networking/WS)           │
├─────────────────────────────────────────────────┤
│    Models & Data Transfer Objects (Codable)      │
├─────────────────────────────────────────────────┤
│   Foundation (URLSession, WebSocket, UserDefaults)│
└─────────────────────────────────────────────────┘
```

### Core Frameworks
- **SwiftUI**: UI layer
- **Combine**: Reactive programming (replaces Provider)
- **URLSession**: HTTP networking
- **URLSessionWebSocketTask**: WebSocket connections
- **UserDefaults**: Persistent storage
- **Charts**: Telemetry visualization (iOS 16+)
- **UniformTypeIdentifiers**: File handling
- **LocalAuthentication**: Biometric auth (optional)

### Architecture Pattern: MVVM + Combine

```swift
// View (SwiftUI)
struct DashboardView: View { 
    @StateObject var viewModel: DashboardViewModel
}

// ViewModel (ObservableObject)
class DashboardViewModel: ObservableObject {
    @Published var telemetry: TelemetryFrame?
    private let apiService: APIService
    private var cancellables = Set<AnyCancellable>()
}

// Service (Business Logic)
class APIService {
    func getTelemetry() -> AnyPublisher<TelemetryFrame, Error>
}

// Model (Codable)
struct TelemetryFrame: Codable {
    let cpu: CPUData?
    let ram: RAMData?
}
```

---

## Project Structure

```
StrawberryManager/
├── StrawberryManagerApp.swift              # App entry point
├── Models/
│   ├── Telemetry.swift                     # TelemetryFrame, CPUData, RAMData, etc.
│   ├── ProcessInfo.swift                   # Process list models
│   ├── FileItem.swift                      # File browser models
│   └── ConnectionState.swift               # Connection states enum
├── ViewModels/
│   ├── ConnectionViewModel.swift           # Manages connection state
│   ├── DashboardViewModel.swift            # Main dashboard logic
│   ├── TerminalViewModel.swift             # Terminal screen logic
│   ├── FilesViewModel.swift                # File manager logic
│   ├── ProcessesViewModel.swift            # Process list logic
│   └── SettingsViewModel.swift             # Settings logic
├── Views/
│   ├── ContentView.swift                   # Root navigation
│   ├── Connect/
│   │   └── ConnectView.swift               # Initial connection screen
│   ├── Dashboard/
│   │   ├── DashboardView.swift             # Main dashboard
│   │   ├── MonitorTab.swift                # Telemetry monitoring
│   │   ├── ControlTab.swift                # Fan/LED controls
│   │   └── Components/
│   │       ├── TelemetryCard.swift         # Reusable card views
│   │       ├── FanControlCard.swift        # Fan control widget
│   │       └── LEDControlCard.swift        # LED control widget
│   ├── Terminal/
│   │   └── TerminalView.swift              # PTY terminal
│   ├── Files/
│   │   ├── FilesView.swift                 # File browser
│   │   └── FileUploadView.swift            # Upload interface
│   ├── Processes/
│   │   └── ProcessesView.swift             # Process list
│   └── Settings/
│       └── SettingsView.swift              # App settings
├── Services/
│   ├── APIService.swift                    # HTTP API client
│   ├── WebSocketService.swift              # Telemetry WebSocket
│   ├── TerminalWebSocketService.swift      # Terminal WebSocket
│   ├── AuthenticationService.swift         # Token management
│   ├── NotificationService.swift           # Local notifications
│   └── StorageService.swift                # UserDefaults wrapper
├── Utilities/
│   ├── Extensions/
│   │   ├── View+Extensions.swift           # SwiftUI view helpers
│   │   ├── Color+Theme.swift               # Color palette
│   │   └── Publisher+Extensions.swift      # Combine helpers
│   ├── ErrorFormatter.swift                # User-friendly errors
│   └── NetworkMonitor.swift                # Connectivity status
├── Resources/
│   ├── Assets.xcassets                     # Images and colors
│   └── Info.plist                          # App configuration
└── Tests/
    ├── ServicesTests/                      # Unit tests for services
    ├── ViewModelTests/                     # Unit tests for view models
    └── UITests/                            # UI automation tests
```

---

## Feature Mapping & Implementation Phases

### Phase 1: Foundation (Week 1-2, 15-20 hours)

**Goal**: Basic connectivity and authentication

#### Tasks
- [ ] Create Xcode project with SwiftUI + Combine
- [ ] Implement base Models (Telemetry, CPUData, RAMData, etc.)
- [ ] Build APIService with URLSession
- [ ] Implement AuthenticationService with token storage
- [ ] Create StorageService for UserDefaults
- [ ] Build ConnectionViewModel
- [ ] Create ConnectView with connection form
- [ ] Implement error handling and ErrorFormatter
- [ ] Add NetworkMonitor for connectivity checks
- [ ] Write unit tests for services

#### Deliverables
```swift
// Working connection flow:
ConnectView -> ConnectionViewModel -> APIService -> Backend
// Token persistence
// Basic error handling
```

### Phase 2: Core Telemetry (Week 3-4, 20-25 hours)

**Goal**: Real-time telemetry display

#### Tasks
- [ ] Implement WebSocketService for telemetry
- [ ] Build DashboardViewModel
- [ ] Create DashboardView with tab navigation
- [ ] Implement MonitorTab with telemetry cards
- [ ] Add Charts framework integration for graphs
- [ ] Create TelemetryCard components
- [ ] Implement history tracking (circular buffer)
- [ ] Add auto-reconnection logic with exponential backoff
- [ ] Implement NotificationService
- [ ] Add temperature alerts
- [ ] Create ControlTab placeholder
- [ ] Write integration tests

#### Deliverables
```swift
// Real-time telemetry display
// CPU, RAM, Thermal graphs
// WebSocket auto-reconnection
// Status notifications
```

### Phase 3: Fan & LED Controls (Week 5, 10-15 hours)

**Goal**: Hardware control features

#### Tasks
- [ ] Build FanControlCard with slider
- [ ] Implement fan threshold API calls
- [ ] Create LEDControlCard with profile picker
- [ ] Implement LED profile API calls
- [ ] Add haptic feedback
- [ ] Create power controls (shutdown, reboot)
- [ ] Add confirmation dialogs
- [ ] Implement optimistic UI updates
- [ ] Write unit tests for control logic

#### Deliverables
```swift
// Working fan control (-10°C to 80°C)
// LED color profile switching
// Power actions with confirmations
```

### Phase 4: Terminal (Week 6, 12-18 hours)

**Goal**: Full PTY terminal support

#### Tasks
- [ ] Implement TerminalWebSocketService
- [ ] Build TerminalViewModel with buffer management
- [ ] Create TerminalView with NSAttributedString rendering
- [ ] Implement custom keyboard with special keys
- [ ] Add ANSI escape sequence parsing
- [ ] Implement terminal size reporting
- [ ] Add auto-scroll and scroll lock
- [ ] Create text selection and copy
- [ ] Handle reconnection with session persistence
- [ ] Write terminal rendering tests

#### Deliverables
```swift
// Full interactive terminal
// ANSI color support
// Special key handling (Ctrl, Tab, Arrow keys)
// Session reconnection
```

### Phase 5: File Manager (Week 7-8, 15-20 hours)

**Goal**: Browse, upload, download files

#### Tasks
- [ ] Build FilesViewModel with directory state
- [ ] Create FilesView with list/grid toggle
- [ ] Implement file browsing navigation
- [ ] Add file download with PHPickerViewController
- [ ] Implement file upload with document picker
- [ ] Create FileUploadView with progress tracking
- [ ] Add file deletion with confirmation
- [ ] Implement file preview (images, text)
- [ ] Add sharing via UIActivityViewController
- [ ] Handle storage permissions
- [ ] Write file operations tests

#### Deliverables
```swift
// File browser with navigation
// Upload with progress
// Download to Files app
// File deletion
// Share functionality
```

### Phase 6: Process Manager (Week 9, 8-12 hours)

**Goal**: View and manage processes

#### Tasks
- [ ] Build ProcessesViewModel
- [ ] Create ProcessesView with sortable list
- [ ] Implement process fetching and sorting
- [ ] Add pull-to-refresh
- [ ] Create process kill action with confirmation
- [ ] Add signal selection (SIGTERM, SIGKILL)
- [ ] Implement auto-refresh toggle
- [ ] Add search/filter functionality
- [ ] Write process management tests

#### Deliverables
```swift
// Sortable process list
// Kill process with signal selection
// Auto-refresh with configurable interval
```

### Phase 7: Settings & Polish (Week 10-11, 10-15 hours)

**Goal**: Settings, preferences, tunnel support

#### Tasks
- [ ] Build SettingsViewModel
- [ ] Create SettingsView with sections
- [ ] Implement graph visibility toggles
- [ ] Add notification preferences
- [ ] Implement reduce motion option
- [ ] Add password change flow
- [ ] Implement tunnel start/stop
- [ ] Create about screen with version info
- [ ] Add app icon and launch screen
- [ ] Implement accessibility labels
- [ ] Support Dynamic Type
- [ ] Add Dark Mode support (if not default)
- [ ] Write settings tests

#### Deliverables
```swift
// Full settings screen
// Password change
// Tunnel management
// Accessibility support
```

### Phase 8: Testing & Refinement (Week 12, 8-12 hours)

**Goal**: Polish, test, optimize

#### Tasks
- [ ] Comprehensive UI testing
- [ ] Performance profiling
- [ ] Memory leak detection (Instruments)
- [ ] Battery usage optimization
- [ ] Network efficiency testing
- [ ] Error scenario testing
- [ ] Accessibility audit
- [ ] Beta testing with TestFlight
- [ ] Bug fixes and polish
- [ ] App Store preparation

#### Deliverables
```swift
// Production-ready app
// Full test coverage
// Optimized performance
// TestFlight build
```

---

## Technical Specifications

### HTTP Networking

```swift
class APIService {
    private let baseURL: URL
    private var token: String?
    
    func request<T: Decodable>(
        _ endpoint: String,
        method: HTTPMethod = .get,
        body: Data? = nil
    ) -> AnyPublisher<T, Error> {
        var request = URLRequest(url: baseURL.appendingPathComponent(endpoint))
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = body
        
        return URLSession.shared
            .dataTaskPublisher(for: request)
            .retry(3)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }
                guard (200...299).contains(httpResponse.statusCode) else {
                    throw APIError.httpError(statusCode: httpResponse.statusCode)
                }
                return data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
```

### WebSocket Implementation

```swift
class WebSocketService: ObservableObject {
    @Published var isConnected = false
    @Published var latestFrame: TelemetryFrame?
    
    private var webSocketTask: URLSessionWebSocketTask?
    private var reconnectAttempts = 0
    private let maxReconnectDelay = 30.0
    
    func connect(to url: URL, token: String) {
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        webSocketTask = URLSession.shared.webSocketTask(with: request)
        webSocketTask?.resume()
        receiveMessage()
    }
    
    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                self?.handleMessage(message)
                self?.receiveMessage() // Continue receiving
            case .failure(let error):
                self?.handleError(error)
            }
        }
    }
    
    private func scheduleReconnect() {
        let delay = min(pow(2.0, Double(reconnectAttempts)), maxReconnectDelay)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.reconnectAttempts += 1
            self?.connect(to: self?.url ?? URL(string: "ws://localhost")!, token: self?.token ?? "")
        }
    }
}
```

### Charts Integration

```swift
import Charts

struct TelemetryGraphView: View {
    let data: [Double]
    let color: Color
    let label: String
    
    var body: some View {
        Chart {
            ForEach(Array(data.enumerated()), id: \.offset) { index, value in
                LineMark(
                    x: .value("Time", index),
                    y: .value("Value", value)
                )
                .foregroundStyle(color.gradient)
                .interpolationMethod(.catmullRom)
            }
        }
        .chartYScale(domain: 0...100)
        .chartXAxis(.hidden)
        .chartYAxis {
            AxisMarks(position: .leading, values: [0, 50, 100])
        }
        .frame(height: 120)
    }
}
```

---

## Risk Assessment

### High Risks
🔴 **Timeline Underestimation** - Complex features like terminal may take longer  
🔴 **Testing Coverage** - Need comprehensive tests to match Flutter stability  
🔴 **Loss of Android Users** - Alienating existing Android user base  

### Medium Risks
🟡 **API Changes** - Backend API changes during migration could break things  
🟡 **Performance Issues** - WebSocket handling needs careful optimization  
🟡 **Feature Creep** - Temptation to add iOS-only features delays completion  

### Low Risks
🟢 **SwiftUI Limitations** - SwiftUI is mature enough for all required features  
🟢 **Developer Learning Curve** - Swift/SwiftUI are well-documented  

---

## Migration Strategy

### Parallel Development (Recommended)
- Keep Flutter app maintained
- Build Swift app alongside
- Release Swift as "Strawberry Manager iOS"
- Maintain both for 6-12 months
- Deprecate Flutter iOS eventually

### Big Bang Replacement (Not Recommended)
- Stop Flutter development
- Complete Swift rewrite
- Replace Flutter app entirely
- **Risk**: Long gap without updates

---

## Testing Strategy

### Unit Tests (60+ tests)
- All service methods
- ViewModel business logic
- Model encoding/decoding
- Error handling paths
- Authentication flows

### Integration Tests (20+ tests)
- API service end-to-end
- WebSocket connection lifecycle
- File upload/download flows
- Authentication with token refresh

### UI Tests (30+ tests)
- Critical user flows
- Navigation between screens
- Form validation
- Error state handling
- Accessibility

### Manual Testing
- Various iOS versions (17.0-18.x)
- Different device sizes (SE, Pro, Pro Max, iPad)
- Network conditions (good, poor, offline)
- Background/foreground transitions
- Memory pressure scenarios

---

## Deployment & Distribution

### Requirements
- Apple Developer Account ($99/year)
- Code signing certificates
- App Store Connect setup
- TestFlight for beta testing

### App Store Metadata
```
Name: Strawberry Manager (iOS)
Subtitle: PS4 Linux Remote Manager
Category: Developer Tools
Age Rating: 4+
Privacy Policy: Required
Support URL: Required
Keywords: ps4, linux, remote, manager, telemetry
```

### Version Strategy
```
1.0.0 - Initial Swift release (feature parity)
1.1.0 - iOS-specific features (widgets, shortcuts)
1.2.0 - Performance optimizations
2.0.0 - Major UI redesign
```

---

## Success Criteria

### Functional
✅ All 15 Flutter features working  
✅ Telemetry updates < 1 second latency  
✅ Terminal fully interactive  
✅ File operations reliable  
✅ Stable WebSocket connections  
✅ Proper error handling  

### Non-Functional
✅ App size < 15 MB  
✅ Battery drain < 5% per hour  
✅ Memory usage < 100 MB  
✅ 0 crashes in TestFlight  
✅ 4.0+ star rating  
✅ Accessibility score 90%+  

### Performance Benchmarks
- App launch: < 1 second
- Connection time: < 2 seconds
- WebSocket reconnect: < 5 seconds
- File upload (10MB): < 30 seconds
- Memory footprint: < 80 MB steady state

---

## Cost-Benefit Analysis

### Development Costs
- **Engineer Time**: 80-120 hours @ $50-150/hr = $4,000-$18,000
- **Apple Developer**: $99/year
- **Testing Devices**: $0 (simulators) - $1,000 (physical devices)
- **Total**: ~$4,100 - $19,100 first year

### Maintenance Costs (Annual)
- **Bug fixes**: 20 hours
- **iOS updates**: 10 hours
- **Feature additions**: 40 hours
- **Total**: ~70 hours/year = $3,500-$10,500/year

### Benefits
- Native performance and UX
- Better App Store visibility
- Potential for more users
- Lower crash rates
- Better battery efficiency
- Access to latest iOS features

### Break-Even Analysis
Need significant user growth or monetization to justify costs vs. maintaining Flutter app.

---

## Alternatives Considered

### 1. Modernize Flutter UI with Cupertino Widgets
**Pros**: Much faster (2-4 weeks), keeps Android support  
**Cons**: Not "truly native"  
**Recommendation**: Better ROI unless native is critical requirement

### 2. React Native
**Pros**: Cross-platform, large ecosystem  
**Cons**: Not as performant, still a rewrite  
**Recommendation**: No advantage over Flutter

### 3. Kotlin Multiplatform Mobile (KMM)
**Pros**: Share business logic, native UI  
**Cons**: Immature, still need Swift for iOS UI  
**Recommendation**: Too experimental

---

## Recommendations

### For Most Use Cases
**Modernize the Flutter app** with Cupertino widgets and improved UI/UX. This gives you:
- iOS-like appearance and animations
- 90% of native feel
- 10% of the effort
- Keep Android support
- Faster time to market

### For Native-First Strategy
**Proceed with Swift rewrite** if:
- iOS is the primary/only platform
- You have 3+ months for development
- Native performance is critical
- You want to leverage iOS-exclusive APIs
- You're willing to abandon Android users

### Hybrid Approach
1. Start with Flutter Cupertino modernization (quick win)
2. Evaluate user feedback and metrics
3. If native iOS demand justifies cost, begin Swift rewrite
4. Run both in parallel during transition

---

## Next Steps

### If Proceeding with Swift Rewrite

1. **Week 0 - Preparation**
   - Set up Xcode project
   - Create this document's GitHub issue with milestones
   - Set up CI/CD with GitHub Actions
   - Configure TestFlight

2. **Week 1-2 - Phase 1**
   - Begin foundation work
   - Weekly progress updates
   - Adjust timeline based on actual velocity

3. **Week 3-8 - Core Features**
   - Implement Phases 2-5
   - Bi-weekly builds to TestFlight
   - Gather feedback

4. **Week 9-12 - Polish & Release**
   - Implement Phases 6-8
   - Final testing
   - App Store submission

### If Starting with Flutter Modernization

1. Create new branch `feature/ios-cupertino-ui`
2. Replace Material widgets with Cupertino
3. Implement iOS-style navigation
4. Add iOS animations
5. Polish and release (2-4 weeks)

---

## Conclusion

This is a **major project** requiring significant investment. The decision should be based on:

1. **User Base**: Are most users on iOS? Will Android users be disappointed?
2. **Business Goals**: Does native iOS provide competitive advantage?
3. **Resources**: Can you dedicate 80-120 hours over 3 months?
4. **Maintenance**: Can you maintain iOS-specific codebase long-term?

**Recommendation**: Unless native iOS is a hard requirement, start with Flutter UI modernization. It provides most benefits at 10% of the cost and maintains platform flexibility.

---

**Document Version**: 1.0  
**Last Updated**: 2026-04-28  
**Status**: Planning Phase  
**Next Review**: After Phase 1 completion or at decision point
