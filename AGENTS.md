# AGENTS.md

## Scope
- This guide is for AI coding agents working in `flex_printing` (Flutter app).
- Prefer updating app code under `lib/` and tests under `test/`; do not edit generated outputs under `build/`.

## Project Structure (Current)
- Entry and app wiring: `lib/main.dart`
- Routing shell/layout: `lib/pages/root_layout.dart`
- Main pages: `lib/pages/home_page/`, `lib/pages/products_page/`, `lib/pages/contactus_page/`, `lib/pages/admin_page/`
- Shared UI primitives: `lib/shared_widgets/ui_helper.dart`, `lib/shared_widgets/product_image_upload_box.dart`
- Models: `lib/models/` (notably `lib/models/product/` and `lib/models/System/`)
- Image methods: `lib/methods/images/`
- Theme: `lib/theme/app_theme.dart`
- Supabase config: `lib/config/supabase_config.dart`

## Architecture and Navigation Conventions
- Routing uses `go_router` in `lib/main.dart` with `RootLayout` wrapping page content.
- Top-level routes are `/`, `/products`, `/contact`, `/admin` (see `lib/main.dart`).
- Home in-page section navigation is query-parameter driven (`/?section=about` and `/?section=events`) and handled by `HomeContent.initialSection` + keyed `Scrollable.ensureVisible` logic in `lib/pages/home_page/home_page.dart`.
- Navigation UI exists in two modes inside `lib/pages/root_layout.dart`:
  - desktop/tablet: `Navbar`
  - compact/mobile: menu dialog via `showTopMenu`

## UI and Responsiveness Patterns
- Responsiveness combines `MediaQuery` width breakpoints with `System.isMobile` from `lib/models/System/system.dart` (conditional imports for web/io/stub).
- Shared controls should use `UiHelper` helpers where possible (`button`, `title`, `inputField`) from `lib/shared_widgets/ui_helper.dart`.
- App typography/theme values come from `AppTheme` and configured fonts in `pubspec.yaml` (`PaytoneOne`, `RedHatDisplay`).

## Data and Integration Boundaries
- Supabase is initialized at startup in `main()` (`lib/main.dart`) using constants from `lib/config/supabase_config.dart`.
- Current admin product flow is in-memory only (no persistence): `lib/pages/admin_page/admin_page.dart` creates `Product` objects and logs/snackbars on save.
- Product images are represented by original/compressed bytes (`lib/models/product/product_image.dart`), added through `ProductImageUploadBox`.
- Image selection/compression pipeline:
  - pick: `pickImageFile()` in `lib/methods/images/image_picker_utils.dart`
  - compress: `compressImageBytes()` using `compute(...)` isolate + `image` package
  - drag/drop support: `desktop_drop` in `lib/shared_widgets/product_image_upload_box.dart`
- Banner images are discovered from `AssetManifest` with fallback static list in `lib/methods/images/fetch_images.dart`.

## Workflow Commands
- Install deps: `flutter pub get`
- Analyze: `flutter analyze`
- Tests: `flutter test`
- Web build: `flutter build web`
- CI-like web build helper exists in `build.sh` (clones Flutter, then runs `flutter pub get` + `flutter build web`).

## Testing Notes
- Widget tests in `test/widget_test.dart` set a desktop-ish test window and assert nav/home behavior.
- Supabase initialization test is in `test/supabase_config_test.dart`.
- When changing route labels, route paths, or home section behavior, update `test/widget_test.dart` expectations accordingly.

