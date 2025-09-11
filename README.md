# PREMODA: A MOBILE-BASED APPAREL SUITABILITY PREVIEW FOR ONLINE SHOPPERS USING COMPUTER VISION
## Overview
PREMODA is a professional mobile application that revolutionizes online shopping through AI-powered virtual try-on technology. Users can realistically preview how clothing items will look on them before making purchases, reducing returns and improving shopping confidence.

## System Architecture

### Core Logic
```
User Photo + Selected Items → Segmind IDM VTON API → Realistic Try-On Results
```

**Processing Flow:**
1. **Capture**: User takes photo via device camera
2. **Convert**: Images converted to base64 format  
3. **Process**: Segmind AI generates realistic virtual try-on
4. **Display**: User views results and makes informed purchase decisions

### Technology Stack

**Frontend**
- **Framework**: Flutter 3.35.2 (Dart 3.9.0)
- **UI/UX**: Material Design with Google Fonts
- **Camera**: Native camera integration with permissions
- **State Management**: Service-based architecture

**Backend Services**
- **Virtual Try-On**: Segmind IDM VTON API (Deep Learning)
- **Authentication**: Supabase + EmailJS verification
- **Database**: Supabase (PostgreSQL)
- **Storage**: Local temporary storage for processing

**Key Features**
- Professional AI-powered virtual try-on using computer vision
- Multi-item try-on with sequential processing
- Secure authentication with email verification
- Real-time product catalog management
- Responsive cross-platform mobile experience

## Getting Started

### Prerequisites
- Flutter SDK (3.35.2+)
- Android Studio (with Android SDK)
- Device or emulator for testing

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/riri-des/2025-CP_PREMODA.git
cd premoda
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Configure services** (Optional)
   - Update Supabase configuration in `lib/services/supabase_config.dart.template`
   - Configure EmailJS in `lib/services/emailjs_config.dart.template`

4. **Run the application**
```bash
flutter run
```

### API Configuration
The app uses Segmind IDM VTON API for virtual try-on processing. The API key is pre-configured but can be updated in `lib/services/virtual_tryon_service.dart` if needed.

## Contributing
This project is part of a capstone project. Contributions and suggestions are welcome.

## License
This project is for educational purposes.
