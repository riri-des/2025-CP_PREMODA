# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

Project summary
- Flutter mobile app for AI-powered virtual try-on and e-commerce.
- Frontend: Flutter (Dart), Material 3, Google Fonts, camera and media plugins.
- Backend: Supabase (auth, DB, storage), external AI try-on (Segmind IDM VTON or Try-On Diffusion via RapidAPI), payments via PayMongo.

Common commands
- Install deps
```bash path=null start=null
flutter pub get
```
- Run app (pick device with flutter devices)
```bash path=null start=null
flutter run
```
- Run on web (if enabled)
```bash path=null start=null
flutter run -d chrome
```
- Build Android APK / App Bundle / Web
```bash path=null start=null
flutter build apk --release
flutter build appbundle --release
flutter build web --release
```
- Lint / static analysis and quick fixes
```bash path=null start=null
flutter analyze
dart fix --apply
```
- Format code
```bash path=null start=null
dart format .
```
- Tests
```bash path=null start=null
# Run all tests
flutter test

# Run single file
flutter test test/widget_test.dart

# Run single test by name (pattern)
flutter test -t "partial test name"

# With coverage (optional)
flutter test --coverage
```
- Asset tooling configured in pubspec
```bash path=null start=null
# Native splash
flutter pub run flutter_native_splash:create
# Launcher icons (Android)
flutter pub run flutter_launcher_icons
```

Big-picture architecture
- Entry and routing
  - lib/main.dart bootstraps Flutter, optionally initializes Supabase via lib/services/supabase_config.dart, and defines routes/home (WelcomeScreen, LogInScreen, HomeScreen).
- Screen layer (feature-first)
  - Core flows live in lib/ and lib/screens/: onboarding (welcome/login/signup/verification), catalog and categories, cart/checkout, profile, orders, addresses, legal (privacy/terms), and the virtual try-on camera.
- Service layer (logic + I/O)
  - Supabase integration: auth_service.dart (signup/login, OTP verification, profile sync), product_service.dart (product queries/filters, images), address_service.dart, order_service.dart, supabase_cart_service.dart (cart and atomic order creation), profile_service.dart (aggregated profile/stats), emailjs_service.dart (custom OTP email flow), supabase_config.dart (URL/key + readiness check).
  - Payments: paymongo_service.dart (sources, payment intents, payment methods, attach, status helpers; amounts in centavos).
  - AI Try-On: virtual_tryon_service.dart orchestrates sequential item try-on; two backends:
    - Try-On Diffusion via RapidAPI: multipart upload of avatar and clothing image, returns composed PNG to a temp file.
    - Segmind IDM VTON: base64 payload of human and garment; maps local categories to Segmind categories; writes result to a temp file.
- Data models and UI components
  - lib/models/: product_model.dart, user_model.dart; widgets in lib/widgets/ (product card, collection slider), utilities in lib/utils/.
- Debug helpers
  - lib/debug/ contains quick auth/debug screens for local testing.

Configuration touchpoints (before running features)
- Supabase
  - Update credentials in lib/services/supabase_config.dart or copy from lib/services/supabase_config.dart.template and import the real file. Main initializes Supabase only when SupabaseConfig.isConfigured is true.
- EmailJS (custom OTP email flow)
  - Configure lib/services/emailjs_config.dart (template provided) used by emailjs_service.dart and auth_service.dart for verification code delivery.
- PayMongo (payments)
  - Replace test keys in lib/services/paymongo_service.dart with your own (test/live). See PAYMONGO_INTEGRATION.md for flow details and testing notes.
- Virtual Try-On APIs
  - lib/services/virtual_tryon_service.dart contains API keys and endpoints for Segmind and RapidAPI. The processVirtualTryOn() method can switch between backends via useRapidAPI and requires a model image and selected cart items; outputs a temp image path for display.
- Assets and permissions
  - pubspec.yaml declares assets/images/ and Material icons. Android/iOS/web splash and icons are configured via flutter_native_splash and flutter_launcher_icons. Camera, storage, and URL launcher permissions are required per plugin docs.

Testing notes
- Tests currently include test/widget_test.dart; extend with widget/integration tests as needed. Use -t to filter individual tests.

Key internal docs
- README.md: project overview, stack, quick start.
- PAYMONGO_INTEGRATION.md: setup, flows (GCash, bank transfer), troubleshooting, future enhancements.
- PROFILE_SETUP_README.md: Supabase schema and policies for profiles/addresses/orders/wishlists/reviews, Flutter integration patterns.
- supabase_schema.sql: schema reference for backend tables and relations.
