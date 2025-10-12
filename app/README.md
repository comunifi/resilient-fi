# Comunifi - Resilient Finance App

A Flutter application built for decentralized social finance, featuring Nostr protocol integration and Web3 capabilities.

## Project Overview

This is a Flutter app that combines social networking with financial features, built using the Nostr protocol for decentralized communication and Web3 integration for blockchain functionality.

## Architecture & Project Structure

### Core Dependencies
- **Flutter SDK**: ^3.9.2
- **Routing**: `go_router` for declarative routing
- **State Management**: `provider` for state management
- **UI Framework**: `flywind` (custom design system) with Cupertino widgets
- **Blockchain**: `web3dart` for Ethereum integration
- **Nostr Protocol**: Custom `dart_nostr` package for decentralized social features
- **Storage**: `shared_preferences` for local data persistence

### Directory Structure

```
lib/
├── main.dart                 # App entry point with router initialization
├── router/
│   └── router.dart          # GoRouter configuration and route definitions
├── state/                   # State management using Provider
│   ├── state.dart          # Main state provider setup
│   ├── feed.dart           # Social feed state management
│   ├── account.dart        # User account state
│   └── post.dart           # Post-related state
├── services/               # External service integrations
│   ├── nostr/             # Nostr protocol service
│   │   ├── nostr.dart     # WebSocket-based Nostr relay communication
│   │   └── README.md      # Nostr service documentation
│   └── secure/            # Security and credential management
│       └── secure.dart    # Secure storage for private keys
├── models/                 # Data models and serialization
│   ├── nostr_event.dart   # Nostr event model with JSON serialization
│   ├── post.dart          # Social post model
│   └── transaction.dart   # Financial transaction model
├── screens/               # UI screens organized by feature
│   ├── home.dart          # Landing/onboarding screen
│   ├── design_system.dart # Design system showcase
│   └── feed/              # Social feed screens
│       ├── screen.dart    # Main feed screen
│       ├── new_post.dart  # Create new post
│       ├── profile.dart   # User profile
│       └── post/          # Individual post details
│           └── screen.dart
├── widgets/               # Reusable UI components
│   ├── post_card.dart     # Post display component
│   ├── transaction_card.dart # Transaction display
│   └── send_receive_widget.dart # Financial action widget
├── design/                # Design system components
│   ├── button.dart        # Custom button variants
│   ├── card.dart          # Card components
│   ├── avatar.dart        # User avatar component
│   ├── sheet.dart         # Modal sheet components
│   └── spinner.dart       # Loading indicators
└── utils/                 # Utility functions
    └── delay.dart         # Helper utilities
```

## Key Architectural Patterns

### Routing (`lib/router/`)
- **GoRouter**: Declarative routing with nested routes
- **Shell Routes**: Provides consistent app shell with state management
- **Route Guards**: Handles authentication and deep linking
- **Dynamic Routes**: User-specific routes (`/:userId/posts`)

### State Management (`lib/state/`)
- **Provider Pattern**: Centralized state management
- **Scoped State**: State providers are scoped to specific route sections
- **Service Integration**: State classes interact with services, not widgets directly
- **Key States**:
  - `FeedState`: Manages social feed data and Nostr subscriptions
  - `AccountState`: Handles user authentication and credentials
  - `PostState`: Manages individual post interactions

### Services (`lib/services/`)
- **Nostr Service**: WebSocket-based communication with Nostr relays
  - Real-time event streaming
  - Subscription management
  - Event publishing and signing
- **Secure Service**: Credential and key management
  - Private key storage
  - Nostr key pair generation
  - Secure preferences handling

### Models (`lib/models/`)
- **JSON Serialization**: All models support JSON serialization/deserialization
- **Nostr Integration**: Models align with Nostr protocol specifications
- **Type Safety**: Strong typing with Dart's type system

### UI Architecture
- **Cupertino Design**: iOS-style UI components throughout
- **Custom Design System**: `flywind` package provides consistent theming
- **Component-Based**: Reusable widgets in `lib/widgets/` and `lib/design/`
- **Screen Organization**: Feature-based screen organization

## Development Guidelines

### Adding New Features
1. **Models**: Define data models in `lib/models/` with JSON serialization
2. **Services**: Create service classes in `lib/services/` for external integrations
3. **State**: Add state management in `lib/state/` using Provider
4. **Screens**: Create screens in `lib/screens/` following feature organization
5. **Routing**: Update `lib/router/router.dart` for new routes

### State Management Best Practices
- Use Provider for app-wide state
- Keep state classes focused on specific domains
- Services should be called from state, not directly from widgets
- Use local state only for UI-specific concerns (animations, form inputs)

### Service Integration
- All external API calls go through service classes
- Services handle authentication, error handling, and data transformation
- State classes consume services and provide data to UI

## Getting Started

### Prerequisites
- Flutter SDK ^3.9.2
- Dart SDK (comes with Flutter)

### Setup Instructions

1. **Clone and Install Dependencies**
   ```bash
   flutter pub get
   ```

2. **Environment Configuration**
   Create a `.env` file in the project root with the following variables:
   ```bash
   # Copy the example environment file
   cp .env.example .env
   ```
   
   Or create `.env` manually with:
   ```env
   # Nostr Relay Configuration
   # Replace with your preferred Nostr relay URL
   RELAY_URL=wss://relay.damus.io
   
   # Deep Link Domains (optional - currently commented out in router)
   # DEEPLINK_DOMAINS=example.com,app.example.com
   ```

3. **Run the Application**
   ```bash
   flutter run
   ```

### First Launch
The app will automatically:
- Generate Nostr credentials (public/private key pair) on first launch
- Store credentials securely using SharedPreferences
- Connect to the configured Nostr relay for social features
- Initialize the Web3 connection for blockchain functionality

### Development
- The app uses hot reload for development
- State management is handled through Provider
- Nostr events are streamed in real-time via WebSocket connections
