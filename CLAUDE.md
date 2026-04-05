# CLAUDE.md

This file provides guidance to Claude Code when working in this repository.

## Project Overview

**Meal Planning Mobile Application** — Version 1.0 | 2026

A practical tool that solves the daily household problem of deciding what to cook. Users build a weekly meal plan in a structured format and get tools to organize nutrition, generate shopping lists, and track macros automatically.

### Problem
Repetitive daily meal decisions cause:
- Emotional fatigue and decision-making overhead
- Unplanned and inefficient grocery shopping
- Poor eating habits that are hard to track
- Lack of household meal coordination

### Solution
Users build a weekly meal plan with configurable daily meal slots (default: breakfast / lunch / dinner). Each slot supports multiple dishes. Dishes are stored in a personal library with ingredients, serving-based scaling, optional cooking instructions, and automatic nutritional calculations.

### Core Features (MVP)
- Weekly meal planning with configurable meal slots
- Personal dish library with ingredients and optional cooking instructions
- Automatic shopping list generation from the current meal plan
- Nutritional value calculation (calories / protein / fat / carbs) per dish and per day
- Built-in product database + manual entry fallback
- Full Android and iOS support

### Post-MVP (planned)
- Family / multi-user access and real-time sync
- Advanced nutrition analytics and reporting
- Integration with grocery delivery services
- Premium subscription (freemium model)

### Architectural Principles
- **Extensible dish model** — new fields can be added without breaking existing records (`extraFields` map).
- **Configurable meal slots** — default (breakfast / lunch / dinner) is a template, not a hard-coded constraint.
- **Multiple dishes per slot** — each meal slot supports N dishes as child items.
- **Base-unit ingredients** — quantities stored per 1 serving; scaling is handled at the application layer.
- **Derived nutrition** — calories/macros are computed on read from ingredients, never stored redundantly.
- **Dynamic shopping list** — generated from the current meal plan; supports API export.
- **Feature-first modular architecture** — new features can be added without large-scale refactoring.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.41.2 |
| Language | Dart 3.11.0 |
| State Management | Riverpod 2.x |
| Navigation | Go Router 14.x |
| Backend / API | Firebase (Auth, Firestore, Storage) |
| External API | Open Food Facts (free, no key) |
| HTTP | http 1.2.x |
| Testing | Flutter Test |

---

## Firebase

- **Project ID**: `cooking-app-3353b`
- **Android app**: `com.desperadoalex13.mobile_app`
- **iOS bundle**: `com.desperadoalex13.mobileApp`
- **Config files** (gitignored — never commit):
  - `android/app/google-services.json`
  - `ios/Runner/GoogleService-Info.plist`
  - `lib/core/firebase/firebase_options.dart`

---

## Repository Structure

```
Mobile-App/
├── lib/
│   ├── main.dart                         # App entry point, Firebase init, ProviderScope
│   ├── app.dart                          # Root widget, MaterialApp.router, theme
│   ├── core/
│   │   ├── router/
│   │   │   ├── app_router.dart           # Go Router + ShellRoute + bottom nav
│   │   │   └── app_routes.dart           # Route path constants
│   │   ├── theme/
│   │   │   └── app_theme.dart            # Material 3 light/dark themes
│   │   └── firebase/
│   │       ├── firebase_options.dart     # Generated Firebase config (gitignored)
│   │       └── firebase_providers.dart   # Riverpod providers for Auth/Firestore/Storage
│   ├── core/
│   │   ├── logging/
│   │   │   └── app_log_service.dart          # Singleton file logger (daily log, uid, ISO timestamps)
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/auth_repository.dart     # signIn/register/signOut/getProfile/watchProfile/updateProfile
│   │   │   ├── domain/user_profile.dart      # UserProfile model; mealSlots: List<String>; defaultMealSlots
│   │   │   └── presentation/
│   │   │       ├── auth_controller.dart
│   │   │       ├── profile_providers.dart    # userProfileProvider, userSlotsProvider, profileMutationProvider
│   │   │       ├── login_screen.dart
│   │   │       ├── register_screen.dart
│   │   │       └── splash_screen.dart
│   │   ├── meal_plan/
│   │   │   ├── data/meal_plan_repository.dart  # watchWeek / savePlan / fetchWeek
│   │   │   ├── domain/meal_plan_model.dart     # MealPlan, DayPlan, MealSlot
│   │   │   └── presentation/
│   │   │       ├── meal_plan_screen.dart       # Week + 7-day TabBarView; slot defaults from userSlotsProvider
│   │   │       └── meal_plan_providers.dart    # selectedWeekProvider, mealPlanProvider, mealPlanMutationProvider
│   │   ├── dish_library/
│   │   │   ├── data/
│   │   │   │   ├── dish_repository.dart      # Firestore CRUD: users/{uid}/dishes/{id}
│   │   │   │   ├── dish_seeder.dart          # 7 starter Ukrainian breakfast dishes (seed_* IDs)
│   │   │   │   └── csv_dish_parser.dart      # RFC-4180 CSV parser → List<Dish>; strips amounts, sets defaults
│   │   │   ├── domain/
│   │   │   │   ├── dish_model.dart           # Dish, Ingredient (extensible)
│   │   │   │   └── product_model.dart        # ProductEntry (per-100g nutrition, defaultUnit)
│   │   │   └── presentation/
│   │   │       ├── dish_library_screen.dart  # List + dual FAB (add / import CSV) + starter import
│   │   │       ├── dish_detail_screen.dart   # Read-only detail view (outside ShellRoute)
│   │   │       ├── dish_form_screen.dart     # Add/Edit dish form; product DB search + auto-scaling
│   │   │       └── dish_providers.dart       # dishesProvider, dishMutationProvider, productsProvider
│   │   ├── settings/
│   │   │   └── presentation/
│   │   │       └── settings_screen.dart      # Meal slot management: add / rename / delete / reorder
│   │   └── shopping_list/
│   │       ├── domain/shopping_list_model.dart
│   │       └── presentation/shopping_list_screen.dart
│   └── shared/
│       ├── widgets/
│       │   ├── loading_indicator.dart
│       │   └── error_view.dart
│       └── utils/
│           └── date_utils.dart
├── test/                                 # Unit and widget tests
├── integration_test/                     # Integration tests
├── assets/
│   ├── images/
│   ├── icons/
│   └── data/                            # Bundled product database
│       └── products.json                # 100 common foods (per-100g: kcal/protein/fat/carbs)
├── android/                             # Android native config
├── ios/                                 # iOS native config
├── pubspec.yaml
└── CLAUDE.md
```

---

## Development Commands

```bash
# Flutter SDK is at C:\flutter\bin — add to PATH or use full path

# Get dependencies
flutter pub get

# Run the app
flutter run -d chrome        # Web (fastest for development)
flutter run -d android       # Android emulator / device
flutter run -d ios           # iOS simulator / device

# Analyze and format
flutter analyze
dart format .

# Tests
flutter test

# Build
flutter build apk
flutter build ios

# Code generation (Riverpod)
dart run build_runner build --delete-conflicting-outputs
dart run build_runner watch  # watch mode
```

---

## Environment Setup (Windows)

| Tool | Location |
|---|---|
| Flutter SDK | `C:\flutter` |
| Dart SDK | `C:\flutter\bin\cache\dart-sdk` |
| Android SDK | `C:\Users\oleks\AppData\Local\Android\Sdk` |
| Android Studio | `C:\Program Files\Android\Android Studio` |
| Java (JBR) | `C:\Program Files\Android\Android Studio\jbr` |

---

## Coding Conventions

- Follow the official [Dart style guide](https://dart.dev/guides/language/effective-dart/style).
- `snake_case` for file names, `PascalCase` for classes, `camelCase` for variables/functions.
- Prefer `const` constructors wherever possible.
- Keep widgets small — extract sub-widgets when `build()` grows large.
- Use Riverpod providers for all shared/global state; avoid `setState` beyond local UI state.
- Use Go Router for all navigation; define routes in `app_routes.dart`.
- Suffix files by type: `_screen.dart`, `_widget.dart`, `_provider.dart`, `_repository.dart`.

---

## Claude Code Guidelines

- Read existing code before suggesting modifications.
- Do not introduce new dependencies without discussing them first.
- Do not create files unless strictly necessary — prefer editing existing ones.
- Do not add comments unless the logic is non-obvious.
- Match the style, patterns, and conventions already present in the codebase.
- Do not auto-commit unless explicitly asked.

---

## Security Rules (mandatory — apply to every session)

### No credential exposure
- **Never hardcode** API keys, tokens, passwords, secrets, or connection strings in any source file.
- **Never commit** credential files. The following are gitignored and must stay that way:
  - `android/app/google-services.json`
  - `ios/Runner/GoogleService-Info.plist`
  - `lib/core/firebase/firebase_options.dart`
  - `env.json`, `*.env`, `.env.*`, `key.properties`
- Firebase config in Dart must always come from the gitignored `firebase_options.dart` — never inline values.
- If a secret is needed at build time, pass it via `--dart-define` or `--dart-define-from-file`.

### Security check before every commit
Before committing or pushing, verify:
1. `git diff --staged` contains no API keys, tokens, or passwords.
2. No new credential files are being staged (`git status`).
3. `.gitignore` still covers all sensitive files.

### If a credential is found exposed
1. **Revoke it immediately** at the issuing service (GitHub, Firebase Console, etc.).
2. Remove it from any local config files (e.g. `~/.claude/settings.json`).
3. Rotate to a new credential and store it in a password manager — not in plain-text files.

---

## Implemented Features

### Authentication
- Firebase Auth sign-in, register, sign-out
- Firestore user profile created on registration (`users/{uid}`)
- Router guard: splash → login (unauthenticated) or meal-plan (authenticated)
- Auth events logged via `AppLogService`

### Error Logging (`AppLogService`)
- Singleton at `lib/core/logging/app_log_service.dart`
- Writes to `<app-documents>/logs/app_YYYY-MM-DD.log` (daily rotation)
- Entry format: `[ISO timestamp] [LEVEL] [uid:xxx] message`
- `setUserId(uid)` / `setUserId(null)` to attach user identity to entries
- `AppLogService.forTest(File)` constructor for unit testing without mocking
- Initialized in `main.dart`; `FlutterError.onError` routes Flutter framework errors to the log

### Dish Library
- Full CRUD: Firestore subcollection `users/{uid}/dishes/{dishId}`
- Navigation flow: list → detail (`/dishes/detail`) → edit form (`/dishes/form`)
- Both detail and form screens are **outside** `ShellRoute` (full screen, no bottom nav)
- Tap dish tile → detail; popup "Edit" → form directly
- Navigate to form: `context.push(AppRoutes.dishForm)` (add) or `context.push(AppRoutes.dishForm, extra: dish)` (edit)
- Nutrition totals (calories/protein/fat/carbs) computed live from ingredients — never stored
- Ingredient amounts stored as `double` per serving; `_fmtNum()` helper trims trailing `.0` in UI
- `DishMutationController` logs all save/delete successes and failures

### Dish Labels
- `Dish.labels: List<String>` — optional meal-type tags; stored in Firestore as `'labels'`; defaults to `[]` (backwards-compatible)
- `Dish.availableLabels = ['Breakfast', 'Lunch', 'Dinner']` — single source of truth on the model
- **Form**: `FilterChip` row between Servings and Ingredients; multi-select, any combination allowed
- **Detail screen**: label chips rendered in the info row with `primaryContainer` colour
- **Library tile**: labels appended to subtitle text (`· Breakfast, Lunch`)
- **Filter bar** (`_LabelFilterBar`): horizontal scrollable chip row at top of dish list; `All` + one chip per label; tap to filter, tap active chip to clear; empty result shows `No "X" dishes.`

### Product Database (local)
- 100 common foods in `assets/data/products.json`; per-100g: kcal / protein / fat / carbs + `defaultUnit`
- `ProductEntry` model in `lib/features/dish_library/domain/product_model.dart`
- `productsProvider` (FutureProvider) in `dish_providers.dart` — loads from asset bundle once, cached
- `_ProductSearchDialog` in `dish_form_screen.dart` — search + tap to auto-fill ingredient name, unit, nutrition
- `_IngredientDialog` recalculates nutrition live as amount changes when a product is linked
- Ingredient `productId`: `product.id` when linked to DB entry; `'manual_\${ms}'` for manual entry

### Open Food Facts API (online ingredient search)
- `lib/features/dish_library/data/open_food_facts_service.dart` — `OpenFoodFactsService` + `openFoodFactsServiceProvider`
- Free API, no key required; required header: `User-Agent: MealPlannerApp/1.0 (github.com/desperadoalex13)`
- Endpoint: `GET https://world.openfoodfacts.org/api/v2/search?q=<term>&fields=code,product_name,nutriments&page_size=20`
- Nutrition fields parsed: `nutriments["energy-kcal_100g"]`, `["proteins_100g"]`, `["fat_100g"]`, `["carbohydrates_100g"]`
- Skips products with any missing nutrition; 8s timeout; all exceptions caught → returns `[]` silently
- Returns `List<ProductEntry>` with `id: 'off_<barcode>'`, `category: 'online'`
- `_ProductSearchDialog` shows local results instantly; 400ms debounce fires API call; online results appended with "Local database" / "Online results" section headers; small spinner + "Searching online…" text during fetch; silent fallback when offline
- `http: ^1.2.0` in `pubspec.yaml`

### Dish Import
- **Starter dishes**: `DishSeeder.starterDishes` — 7 Ukrainian breakfast dishes with fixed `seed_*` IDs (safe re-import via Firestore `set()`)
- **CSV import**: `CsvDishParser.parse(String)` in `csv_dish_parser.dart`
  - Handles RFC-4180 format: quoted multi-line cells, `""` escape, trailing-newline-optional
  - Column 1 = dish name, Column 2 = ingredient lines (one per line)
  - Strips `" - amount unit"` suffix from each line to extract clean ingredient name
  - Defaults per ingredient: `amountPerServing=1`, `unit='pcs'`, `protein=1`, `fat=1`, `carbs=1`, `calories=0`
  - Dish IDs: `csv_\${base}_\${index}` — always creates new dishes (no overwrite on re-import)
  - Skips rows where dish name or ingredients column is empty (header rows)
  - Strips UTF-8 BOM at file start
- **UI** (`DishLibraryScreen`):
  - Dual FAB: small upload icon FAB (CSV) + primary `+` FAB (manual add)
  - Empty state: "Import starter dishes" + "Import from CSV" buttons
  - Import flow: file picker → parse → confirm dialog (shows dish count) → batch save to Firestore
  - `file_picker: ^8.1.0` used with `withData: true` for cross-platform byte access

### Meal Plan
- Firestore: `users/{uid}/mealPlans/{YYYY-MM-DD}` (Monday as document key)
- `selectedWeekProvider` (StateProvider<DateTime>) — holds current Monday
- `mealPlanProvider` (StreamProvider<MealPlan?>) — live watch; null = no plan yet (lazy creation)
- `mealPlanMutationProvider` (AsyncNotifier) — addDish / removeDish / copyWeek / copyDay
- `TabController(length: 8)` — Week overview + 7 individual day tabs
- Slot defaults come from `userSlotsProvider` (not hardcoded `MealSlot.defaults`)
- Copy week / copy day from previous week — returns `bool hadContent` for snackbar feedback

### Configurable Meal Slots
- `UserProfile.mealSlots: List<String>` stored in Firestore at `users/{uid}`
- `UserProfile.defaultMealSlots = ['Breakfast', 'Lunch', 'Dinner']` — fallback only
- `userProfileProvider` (StreamProvider) — live stream of profile document
- `userSlotsProvider` (Provider<List<String>>) — derived from profile; falls back to defaults
- `profileMutationProvider` (AsyncNotifier) — `updateSlots(List<String>)` calls `updateProfile(uid, {mealSlots: ...})`
- Settings screen (`/settings`, 4th bottom nav tab): `ReorderableListView` supporting add / rename / delete / reorder
- Rename/delete only affects new lazy-created days; existing Firestore plan docs keep their slot names

### Multilanguage (i18n)
- **Languages**: English (`en`) + Ukrainian (`uk`); extensible — add a new `.arb` file and re-run `flutter gen-l10n`
- **ARB files**: `lib/l10n/app_en.arb` (template) + `lib/l10n/app_uk.arb` (~90 keys each)
- **Code generation**: `flutter gen-l10n` reads `l10n.yaml` → outputs `lib/l10n/app_localizations.dart` + per-locale files
- **`l10n.yaml`**: `arb-dir: lib/l10n`, `template-arb-file: app_en.arb`, `nullable-getter: false`
- **`pubspec.yaml`**: `flutter: generate: true` + `intl: ^0.20.2` + `shared_preferences` for persistence
- **Locale provider**: `lib/core/locale/locale_provider.dart`
  - `localeProvider` — `StateProvider<Locale>` initialized to saved locale at startup
  - `loadSavedLocale()` — reads from `SharedPreferences` (called in `main()` before `runApp`)
  - `saveLocale(Locale)` — persists locale code to `SharedPreferences`
- **Extension**: `lib/l10n/l10n.dart`
  - `context.l10n` — shorthand for `AppLocalizations.of(context)`
  - `context.localizeLabel(String)` — translates English Firestore label keys (`'Breakfast'` → `'Сніданок'`)
  - `context.dayAbbr(int weekday)` — returns localized weekday abbreviation (1=Mon…7=Sun)
- **Dish labels** stored as English keys in Firestore (`'Breakfast'`/`'Lunch'`/`'Dinner'`); translated in UI only via `localizeLabel` — no data migration needed
- **Settings screen** — Language section at top: two tiles (English / Ukrainian) with checkmark on active; tap to switch locale instantly and persist
- All widget tests that render screens must wrap with `AppLocalizations.localizationsDelegates` + `supportedLocales`

### Testing
- **82 tests** in `test/` — all pass, zero analyzer issues
- `mocktail: ^1.0.4` (not ^0.3.0 — conflicts with custom_lint)
- `// ignore: subtype_of_sealed_class` required for mocking Firestore sealed classes
- Widget test stubs for `authControllerProvider` must **extend `AuthController`**, not `AsyncNotifier<void>` directly
- Use `dart analyze lib/` instead of `flutter analyze` to avoid OOM crash on Windows

---

## Notes

- `firebase_options.dart` is manually maintained (no FlutterFire CLI — Windows auth restrictions). Regenerate by copying values from Firebase console when project config changes.
- `flutter analyze` must pass with zero issues before committing.
- Web platform folder (`web/`) is not generated yet — run `flutter create . --platforms web` to add it.
- `ScaffoldWithNavBar` renders a route-aware localized title in its AppBar — uses `context.l10n` inside `build()`.
- `flutter analyze` may OOM on Windows with Dart 3.11 (`analysis server exited with code -1073740791`). Use `dart analyze lib/` instead — produces identical results without the crash.
- After editing ARB files, run `flutter gen-l10n` to regenerate `lib/l10n/app_localizations*.dart`. The command reads `l10n.yaml` automatically.
- `intl` must be pinned to `^0.20.2` (Flutter SDK pins it; `^0.19.0` causes version conflict).
