# Strawberry Manager - iOS (Swift/SwiftUI)

Native iOS rewrite of Strawberry Manager using Swift and SwiftUI.

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Architecture

- **Pattern**: MVVM with Combine
- **UI**: SwiftUI
- **Networking**: URLSession + Combine
- **Storage**: UserDefaults
- **Testing**: XCTest

## Project Structure

See [SWIFT_IOS_MIGRATION_PLAN.md](../SWIFT_IOS_MIGRATION_PLAN.md) for complete implementation plan.

## Getting Started

This branch contains the architecture scaffold. To begin development:

1. Open Xcode
2. Create new iOS App project named "StrawberryManager"
3. Copy files from this directory into the Xcode project
4. Follow the implementation plan phases

## Development Status

📋 **Phase 1: Foundation** - Not Started
- [ ] Project setup
- [ ] Models implementation
- [ ] APIService
- [ ] AuthenticationService
- [ ] ConnectionViewModel
- [ ] ConnectView

See migration plan for complete roadmap.
