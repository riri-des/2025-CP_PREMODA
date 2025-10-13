# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

Project: PREMODA (Flutter)

Summary
- Mobile Flutter app for AI-powered virtual try-on in e-commerce.
- Integrates camera capture, Segmind IDM VTON, optional Try-On Diffusion via RapidAPI, and Supabase for auth/data.

Core commands
- Install deps
  - flutter pub get
- Analyze (lint)
  - flutter analyze
- Format (consistent code style)
  - flutter format lib test
- Run app (attach an emulator/device first)
  - flutter run
  - List devices: flutter devices
  - Run on a specific device: flutter run -d <device_id>
- Tests
  - Run all: flutter test
  - Run one file: flutter test test/widget_test.dart
  - Run a single test (by name pattern): flutter test test/widget_test.dart -n "Premoda app smoke test"
- Build
  - Android (debug): flutter build apk --debug
  - Android (release): flutter build apk --release
  - iOS (on macOS): flutter build ios
- Update native splash (configured in pubspec.yaml via flutter_native_splash)
  - dart run flutter_native_splash:create

Environment and configuration
- Supabase
  - Copy lib/services/supabase_config.dart.template to lib/services/supabase_config.dart and fill supabaseUrl and supabaseAnonKey.
  - main.dart conditionally initializes Supabase via SupabaseConfig.isConfigured; ensure your concrete lib/services/supabase_config.dart provides the properties referenced by main.dart.
- EmailJS
  - Copy lib/services/emailjs_config.dart.template to lib/services/emailjs_config.dart and fill serviceId, templateId, publicKey (and privateKey if used).
- Assets
  - pubspec.yaml includes assets/images/. Ensure images exist, especially for splash and UI assets referenced in the code.

High-level architecture
- Entry point: lib/main.dart
  - Initializes Flutter bindings.
  - Conditionally initializes Supabase (Supabase.initialize) based on SupabaseConfig.
  - PremodaApp sets MaterialApp theme (Google Fonts, Material 3) and launches the initial screen (Welcome -> SignUp/LogIn flows) leading to HomeScreen.

- Screens (UI)
  - HomeScreen (lib/home_screen.dart): main navigation via PageView and bottom nav; composes sections like categories, featured, and uses widgets/product_card.dart and widgets/new_collection_grid_slider.dart.
  - VirtualTryOnCamera (lib/screens/virtual_tryon_camera.dart):
    - Requests camera permission (permission_handler) and initializes the preferred (front) camera (camera plugin).
    - Captures an image and invokes VirtualTryOnService.processVirtualTryOn.
    - Shows a result dialog with the generated image saved to a temporary file.
  - VerificationScreen (lib/verification_screen.dart): OTP-style verification inputs and actions to verify/resend codes via AuthService.
  - Additional screens referenced: cart_screen.dart, category_screen.dart, profile_screen.dart, verification_screen.dart (compose the app shell and flows).

- Services (application logic)
  - AuthService (lib/services/auth_service.dart)
    - Wraps Supabase auth flows: sign-up with OTP, sign-in, profile updates, password change/reset.
    - Provides helpers for email/password validation and user/session accessors.
  - ProductService (lib/services/product_service.dart)
    - Reads from Supabase tables (products, product_images) with filters (category, featured, trending, newArrival, status=active, visibility=visible) and ordering/pagination.
    - Exposes queries for featured/trending/new arrivals, search, categories, recommendations, and a stored procedure call (increment_product_views).
  - CartService (lib/services/cart_service.dart)
    - Local in-memory cart with add/update/remove/select operations and totals.
    - CartItem model holds selection (size/color), quantity, and selection state used by virtual try-on.
  - VirtualTryOnService (lib/services/virtual_tryon_service.dart)
    - Orchestrates try-on processing per selected cart item, sequentially mutating the working image.
    - Two backends:
      - Segmind IDM VTON (https://api.segmind.com/v1/idm-vton): JSON POST sending base64 of human and garment images; response bytes saved to a temp file.
      - Try-On Diffusion via RapidAPI (https://try-on-diffusion.p.rapidapi.com/try-on-file): multipart POST with model image file + clothing image URL; response bytes saved to a temp file.
    - Helpers convert local images to base64 and download clothing images by URL.
    - Controlled by useRapidAPI flag; defaults to RapidAPI path when a model image path is provided.

- Data models
  - Product and ProductImage (lib/models/product_model.dart)
    - Rich product attributes (status, visibility, flags like featured/trending/newArrival, arrays for colors/sizes/tags).
    - ProductImage includes isPrimary and sortOrder.

- Utilities
  - SampleClothesGenerator (lib/utils/create_sample_clothes.dart)
    - Programmatically renders simple clothing PNGs (dress/t-shirt) to the app documents directory (useful for demos/tests).

Tooling and linting
- analysis_options.yaml includes flutter_lints (5.x). Use flutter analyze to surface issues.

Testing
- Widget tests exist under test/, e.g., test/widget_test.dart covers title visibility and basic navigation from the welcome screen.
- Run a single widget test: flutter test test/widget_test.dart -n "Navigate to Sign Up screen test"

Notes derived from README.md
- Flutter 3.35.2 (Dart 3.9.0) targeted; camera + permissions required for try-on.
- Supabase is the primary backend for auth/database; Segmind IDM VTON is used for core try-on; EmailJS for verification flow.
- Basic quickstart is: flutter pub get, configure templates, flutter run.
