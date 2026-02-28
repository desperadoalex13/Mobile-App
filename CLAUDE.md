# CLAUDE.md

This file provides guidance to Claude Code when working in this repository.

## Project Overview
PROJECT DESCRIPTION
Meal Planning Mobile Application
Version 1.0  |  2026
1. Project Overview
The Meal Planning Mobile Application is a practical tool that solves a universal daily problem faced by every household: what to cook for breakfast, lunch, and dinner? Instead of spending time and mental energy figuring out meals every single day, users build their weekly menu in a structured format and get all the tools they need to organize their nutrition efficiently.

2. Problem
Every day, millions of people face the same recurring task: deciding what to eat. While it may seem trivial at first, the repetitive nature of this decision accumulates over time and leads to:
    • Emotional fatigue and frustration from constant daily decision-making
    • Unplanned and inefficient grocery shopping
    • Poor eating habits that are difficult to track or improve
    • Lack of coordination around meals within a household

3. Solution
The application allows users to build a weekly meal plan organized by daily meal slots. The default meal structure follows a standard three-meal pattern — breakfast, lunch, and dinner — however, the application architecture must allow users to define their own custom daily meal schedule according to their personal preferences.

Users select dishes from a personal library or create and add new dishes. Each meal slot can contain one or more dishes. For example, breakfast may consist of scrambled eggs alone (1 item) or scrambled eggs and coffee (2 items). Lunch may include mashed potatoes, meatballs, and a salad (3 items). This structure applies consistently across all meal slots.

Adding a new dish to the library includes the following fields:
    • Name of the dish
    • Number of servings the recipe is designed for (base unit: 1 serving = 1 person). The system automatically scales ingredient quantities based on the number of people and days the dish is planned for.
    • List of ingredients with weight or volume specified per 1 serving. All further calculations — total ingredient quantities, shopping list, and nutritional values (calories/macros) — are performed automatically by the system based on this base value.
    • Optional: cooking instructions (a step-by-step list of actions with timing required to prepare the dish)
    • The dish creation architecture must be extensible — the fields listed above are a starting point, not a hard limit. The data model must support adding new fields in future iterations without breaking existing data.

Nutritional values (calories, protein, fat, carbohydrates) are calculated automatically based on the ingredients in each dish. Nutritional data is sourced from a built-in product database (bundled with the app) with the ability for users to enter values manually for any product not found in the database. This combination ensures calculation accuracy while maintaining flexibility for non-standard or regional ingredients.

Based on the ingredients across all planned dishes, a shopping list is generated automatically and can be exported via API. This is the core functionality for MVP, but the codebase architecture must be designed to support continuous expansion and integration of new features over time.

4. Target Audience
    • Families and households looking to organize weekly meal planning
    • Individuals tracking caloric intake and macronutrient balance
    • People who want to reduce time and stress around grocery shopping
    • Couples and multi-person households needing shared meal coordination

5. Core Features
5.1 Meal Planning
    • Weekly calendar with configurable daily meal slots (default: breakfast, lunch, dinner). Each meal slot supports one or more dishes as sub-items.
    • Manual selection and addition of dishes from the personal library to any meal slot
    • Ability to copy a full menu from a previous week or individual day

5.2 Shopping List
    • Automatic shopping list generation based on the current week's meal plan
    • Manual editing and item check-off (mark as purchased)
    • Grouping of items by product category
    • Export via API for integration with external services

5.3 Dish Library & Recipes
    • Personal library of user-created dishes
    • Each dish linked to its ingredients and optional cooking instructions
    • Step-by-step preparation instructions with timing

5.4 Nutrition Tracking (Calories / Macros)
    • Display of calories, protein, fat, and carbohydrates per dish (calculated automatically from ingredients and serving count)
    • Daily and weekly nutrition summary
    • Nutritional data source: built-in product database + manual entry for products not found in the database

5.5 Family / Multi-User Access
    • Add multiple family members to a single account
    • Shared meal plan and shopping list across all members
    • Real-time synchronization across devices

6. Monetization
Freemium model — core functionality is free, advanced features available via a paid subscription.

Free Plan	Premium Plan
Weekly meal planning	Unlimited meal history
Basic shopping list	Advanced nutrition analytics
Up to 10 saved dishes	Unlimited dish library
Single user	Family access (up to 5 members)
	Nutrition reports & insights

7. Technology Stack (MVP)
Layer	Technology
Framework	Flutter
Language	Dart
State Management	Riverpod
Navigation	Go Router
Backend / API (MVP)	Firebase (Auth, Firestore, Storage)
Testing (MVP)	Flutter Test

8. MVP Scope
The first release (MVP) includes the following functionality:
    • User registration and authentication via Firebase Auth
    • Weekly meal planning with configurable daily meal slots (default: breakfast / lunch / dinner)
    • Personal dish library with ingredients, serving-based scaling, and optional cooking instructions
    • Automatic shopping list generation from the current meal plan
    • Nutritional value calculation (calories / macros) per dish and per day
    • Built-in product database for nutritional data + manual entry fallback
    • Full support for Android and iOS

Planned for post-MVP releases:
    • Family / multi-user access and real-time sync
    • Advanced nutrition analytics and reporting
    • Integration with online grocery stores and delivery services
    • Premium subscription implementation

9. Architectural Principles
This section is intended as a reference for the development team and for use with AI-assisted development tools (e.g. Claude Code).

    • The data model for dish creation must be extensible. New fields must be addable without breaking existing dish records.
    • The daily meal slot structure must be configurable per user. The default (breakfast / lunch / dinner) is a starting template, not a hard-coded constraint.
    • Each meal slot must support multiple dishes as child items, with individual portion counts per dish.
    • All ingredient quantities are stored as a base value per 1 serving. Scaling logic (by number of people and days) is handled by the application layer, not stored as a separate field.
    • Nutritional calculations are derived values — they are computed on read from ingredient data, not stored redundantly.
    • The shopping list is generated dynamically from the current meal plan. It must support API export for integration with third-party services.
    • The codebase must follow a modular, feature-based architecture to allow new features to be integrated without large-scale refactoring.
**Mobile-App** — a mobile application project. Update this section with specifics as the project evolves.

## Tech Stack

- **Framework**: Flutter
- **Language**: Dart
- **State Management**: Riverpod
- **Navigation**: Go Router
- **Backend / API**: Firebase
- **Testing**: Flutter Test

## Repository Structure

```
Mobile-App/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── app.dart                  # Root widget & router setup
│   ├── features/                 # Feature-first structure
│   │   └── <feature>/
│   │       ├── data/             # Repositories, data sources
│   │       ├── domain/           # Models, entities
│   │       └── presentation/     # Screens, widgets, providers
│   ├── shared/
│   │   ├── widgets/              # Reusable UI components
│   │   ├── providers/            # App-wide Riverpod providers
│   │   └── utils/                # Helpers and extensions
│   └── core/
│       ├── router/               # Go Router configuration
│       ├── theme/                # App theme and styles
│       └── firebase/             # Firebase initialization
├── test/                         # Unit and widget tests
├── integration_test/             # Integration tests
├── assets/                       # Images, fonts, static files
├── android/                      # Android-specific config
├── ios/                          # iOS-specific config
├── pubspec.yaml                  # Dependencies
└── CLAUDE.md                     # This file
```

## Development Commands

```bash
# Get dependencies
flutter pub get

# Run the app
flutter run

# Run on a specific platform
flutter run -d android
flutter run -d ios
flutter run -d chrome

# Run tests
flutter test

# Lint and format
flutter analyze
dart format .

# Build
flutter build apk
flutter build ios
```

## Coding Conventions

- Follow official [Dart style guide](https://dart.dev/guides/language/effective-dart/style).
- Use `snake_case` for file names, `PascalCase` for classes, `camelCase` for variables/functions.
- Prefer `const` constructors wherever possible to optimize widget rebuilds.
- Keep widgets small and focused — extract sub-widgets when a build method grows large.
- Use Riverpod providers for all shared/global state; avoid `setState` beyond purely local UI state.
- Use Go Router for all navigation; define routes centrally.
- Suffix files by type: `_screen.dart`, `_widget.dart`, `_provider.dart`, `_repository.dart`.

## Claude Code Guidelines

- Read existing code before suggesting modifications.
- Do not introduce new dependencies without discussing them first.
- Do not create files unless strictly necessary — prefer editing existing ones.
- Do not add comments unless the logic is non-obvious.
- Match the style, patterns, and conventions already present in the codebase.
- Do not auto-commit unless explicitly asked.
- Security: avoid hardcoding secrets, API keys, or credentials — use environment variables.

## Environment Variables

Flutter uses `--dart-define` or `--dart-define-from-file` to pass secrets at build time. Never hardcode keys in Dart source files.

```bash
# Example: run with environment config
flutter run --dart-define-from-file=env.json
```

Keep `env.json` in `.gitignore`. Provide an `env.example.json` documenting required keys. Firebase config is handled via `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) — do not commit these files.

## Notes

<!-- Add project-specific notes, gotchas, or decisions here over time -->
