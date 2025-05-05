# Camino de Santiago Pilgrim App

A Flutter mobile application for pilgrims walking the Camino de Santiago, providing essential features like GPS navigation, nearby infrastructure recommendations, and community engagement.

## Features

- **GPS-Based Navigation**: Real-time position tracking on Camino routes with off-route alerts
- **Curated Infrastructure Listings**: Top suggestions for accommodations, restaurants, pharmacies, and landmarks
- **Recommended Journeys**: Data-driven stage recommendations and route planning
- **Community Forum**: Share tips, ask questions, and report trail conditions
- **Information Hub**: Emergency contacts, pilgrim services, and FAQs

## Getting Started

### Prerequisites

- Flutter SDK (2.0.0 or later)
- Dart SDK (2.12.0 or later)
- Android Studio / Visual Studio Code
- Android SDK / Xcode (for iOS)

### Installation

1. Clone the repository:
   ```
   git clone https://github.com/yourusername/camino-pilgrim-app.git
   ```

2. Navigate to the project directory:
   ```
   cd camino-pilgrim-app
   ```

3. Install dependencies:
   ```
   flutter pub get
   ```

4. Run the app:
   ```
   flutter run
   ```

## Project Structure

```
lib/
├── config/            # App configuration, routes, theme
├── core/              # Core utilities and helpers
├── data/              # Data layer
│   ├── datasource/    # Remote and local data sources
│   ├── models/        # Data models
│   └── repositories/  # Repository implementations
├── domain/            # Domain layer
│   ├── entities/      # Business entities
│   ├── repositories/  # Repository interfaces
│   └── usecases/      # Business logic
└── presentation/      # UI layer
    ├── bloc/          # State management
    ├── pages/         # App screens
    └── widgets/       # Reusable UI components
```

## Tech Stack

- **Mobile Framework**: Flutter
- **Mapping & GPS**: Google Maps SDK / Mapbox SDK
- **State Management**: Flutter Bloc
- **Local Storage**: SQLite & Shared Preferences
- **HTTP Client**: Dio

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgements

- Camino de Santiago Official Resources
- Flutter Team and Community
- Contributors to this project
