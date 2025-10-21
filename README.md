# Flutter Project Structure and Best Practices

## Project Structure

This Flutter project follows a well-organized structure based on best practices:

```
lib/
├── main.dart                   # Entry point of the application
├── app/                        # Core application setup
│   └── app.dart                # Main app widget
├── core/                       # Core functionality
│   ├── constants/              # Application constants
│   │   ├── app_constants.dart  # General app constants
│   │   ├── app_colors.dart     # Color definitions
│   │   ├── app_fonts.dart      # Font definitions
│   │   ├── app_spacing.dart    # Spacing definitions
│   │   └── app_design_tokens.dart # Combined design tokens
│   ├── utils/                  # Utility functions
│   └── services/               # Service classes
├── features/                   # Feature-based modules
├── shared/                     # Shared resources
│   ├── widgets/                # Reusable widgets
│   ├── theme/                  # Theme definitions
│   └── exceptions/             # Custom exceptions
└── ui/                         # UI related components
    ├── screens/                # Screen widgets
    ├── widgets/                # UI components
    └── routes/                 # Routing configuration
```

## Design System

This project implements a design system with centralized constants for:

1. **Colors**: Defined in `core/constants/app_colors.dart`
2. **Typography**: Defined in `core/constants/app_fonts.dart`
3. **Spacing**: Defined in `core/constants/app_spacing.dart`
4. **Design Tokens**: Combined in `core/constants/app_design_tokens.dart`

## Best Practices Implemented

1. **Separation of Concerns**: The project structure separates concerns by dividing code into core, features, and shared modules.

2. **Feature-first Organization**: Each feature is self-contained with its own views, viewmodels, models, and widgets.

3. **Clear Entry Point**: The `main.dart` file is clean and only responsible for starting the app.

4. **Theming**: Centralized theme management in the `shared/theme` directory.

5. **Routing**: Centralized routing configuration in the `ui/routes` directory.

6. **Constants**: Centralized constants management in the `core/constants` directory.

7. **Utility Functions**: Common utility functions are placed in the `core/utils` directory.

## Key Components

- **App**: The main application widget that sets up routing and theming.
- **Core**: Fundamental functionality used across the app.
- **Features**: Independent modules that implement specific functionality.
- **Shared**: Reusable components, themes, and utilities.
- **UI**: Screen-level UI components and routing.

## Running the Application

To run the application, use one of the following commands:

```bash
# Run on Chrome (web)
flutter run -d chrome

# Run on an attached device
flutter run

# Run on a specific platform
flutter run -d <device-name>
```

## Building the Application

To build the application for different platforms:

```bash
# Build for web
flutter build web

# Build for Android
flutter build apk

# Build for iOS
flutter build ios
```