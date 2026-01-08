# Motiva

A beautifully crafted daily motivation app that delivers wisdom to your home screen through native widgets.

## Features

- **Daily Quotes** - Fresh motivational content every day with unique ordering per user
- **Home Screen Widgets** - Native iOS and Android widgets in multiple sizes (2x2, 4x2, 4x4, 4x1)
- **Streak Tracking** - Stay motivated with daily engagement tracking
- **Share to Social** - Export quotes to Instagram, Twitter, and WhatsApp
- **Dark Mode** - Full support for light and dark themes
- **Offline First** - All content available without internet

## Screenshots

<!-- Add your screenshots here -->
| Home | Widget | Detail |
|------|--------|--------|
| ![Home](screenshots/home.png) | ![Widget](screenshots/widget.png) | ![Detail](screenshots/detail.png) |

## Tech Stack

- **Flutter** - Cross-platform UI framework
- **BLoC Pattern** - State management with flutter_bloc
- **Clean Architecture** - Separation of concerns with domain, data, and presentation layers
- **Hive** - Fast, lightweight local database
- **Jetpack Glance** - Native Android widgets with Compose
- **WidgetKit** - Native iOS widgets with SwiftUI

## Architecture

```
lib/
├── core/           # Shared utilities, themes, constants
├── di/             # Dependency injection with GetIt
└── features/
    ├── quote/      # Daily quote feature
    ├── streak/     # Engagement tracking
    ├── sharing/    # Social media sharing
    └── home_widget/ # Widget data sync
```

## Getting Started

1. Clone the repository
   ```bash
   git clone https://github.com/K1llly/motiva.git
   ```

2. Install dependencies
   ```bash
   flutter pub get
   ```

3. Add your quotes data
   ```bash
   cp lib/core/data/quotes_data.example.dart lib/core/data/quotes_data.dart
   # Edit quotes_data.dart with your content
   ```

4. Run the app
   ```bash
   flutter run
   ```

## Build

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

## License

MIT License - see [LICENSE](LICENSE) for details.
