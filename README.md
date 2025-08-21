# PREMODA: A MOBILE-BASED APPAREL SUITABILITY PREVIEW FOR ONLINE SHOPPERS USING COMPUTER VISION

## Overview
PREMODA is a mobile application that allows online shoppers to virtually try on clothing items before making a purchase. Using computer vision and pose detection technology, users can see how different apparel items would look on them.

## Features
- Virtual try-on functionality using camera or uploaded photos
- Real-time pose detection
- Shopping cart management
- Product catalog browsing
- Category-based filtering

## Technology Stack
- **Frontend**: Flutter (Dart)
- **Backend**: Python Flask
- **ML/AI**: Google ML Kit for pose detection
- **Computer Vision**: Planned integration with CP-VTON or similar models

## Getting Started

### Prerequisites
- Flutter SDK
- Python 3.8+
- Android Studio or Xcode

### Installation

1. Clone the repository
```bash
git clone https://github.com/riri-des/2025-CP_PREMODA.git
cd 2025-CP_PREMODA
```

2. Install Flutter dependencies
```bash
flutter pub get
```

3. Set up the backend server
```bash
cd backend_example
python -m venv venv
venv\Scripts\activate  # On Windows
pip install -r requirements.txt
```

4. Run the backend server
```bash
python app.py
```

5. Update the backend URL in `lib/services/virtual_tryon_service.dart` with your IP address

6. Run the Flutter app
```bash
flutter run
```

## Contributing
This project is part of a capstone project. Contributions and suggestions are welcome.

## License
This project is for educational purposes.
