import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:image/image.dart' as img;
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../cart_screen.dart';

/// Helper class for points
class Point {
  final double x;
  final double y;

  Point(this.x, this.y);
}

class VirtualTryOnService {
  static final VirtualTryOnService _instance = VirtualTryOnService._internal();
  factory VirtualTryOnService() => _instance;
  VirtualTryOnService._internal();

  // Backend API configuration
  // TODO: Replace with your actual backend URL
  static const String _baseUrl = 'http://192.168.254.112:8000'; // Change this to your backend URL
  static const String _virtualTryOnEndpoint = '/api/virtual-tryon';
  
  final PoseDetector _poseDetector = PoseDetector(
    options: PoseDetectorOptions(
      model: PoseDetectionModel.accurate,
      mode: PoseDetectionMode.single,
    ),
  );

  /// Process image for virtual try-on using backend API
  Future<String?> processVirtualTryOn({
    required String imagePath,
    required List<CartItem> selectedItems,
  }) async {
    try {
      print('Starting virtual try-on process...');
      
      // First, do a quick pose detection to ensure there's a person in the image
      final File imageFile = File(imagePath);
      final InputImage inputImage = InputImage.fromFile(imageFile);
      
      final List<Pose> poses = await _poseDetector.processImage(inputImage);
      
      if (poses.isEmpty) {
        throw Exception('No person detected in the image');
      }
      
      // Process each item through the API
      String? currentImagePath = imagePath;
      
      for (CartItem item in selectedItems) {
        print('Processing item: ${item.name}');
        
        // Call the backend API for realistic virtual try-on
        final resultPath = await _callVirtualTryOnAPI(
          personImagePath: currentImagePath!,
          clothingItem: item,
        );
        
        if (resultPath != null) {
          currentImagePath = resultPath;
        } else {
          print('Failed to process item: ${item.name}');
          // Fall back to local processing if API fails
          currentImagePath = await _processLocally(currentImagePath, item);
        }
      }
      
      return currentImagePath;
    } catch (e) {
      print('Virtual try-on error: $e');
      return null;
    }
  }
  
  /// Call the backend API for virtual try-on processing
  Future<String?> _callVirtualTryOnAPI({
    required String personImagePath,
    required CartItem clothingItem,
  }) async {
    try {
      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl$_virtualTryOnEndpoint'),
      );
      
      // Add person image
      request.files.add(
        await http.MultipartFile.fromPath(
          'person_image',
          personImagePath,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
      
      // Add clothing image if available, otherwise send clothing details
      if (clothingItem.imagePath != null) {
        // For now, we'll send the image path. In a real implementation,
        // you'd load the actual clothing image file
        request.fields['clothing_image_path'] = clothingItem.imagePath!;
      }
      
      // Add clothing metadata
      request.fields['clothing_name'] = clothingItem.name;
      request.fields['clothing_type'] = _getClothingType(clothingItem);
      request.fields['clothing_color'] = '#${clothingItem.color.value.toRadixString(16).substring(2)}';
      request.fields['clothing_size'] = clothingItem.size ?? 'M';
      
      // Send request
      print('Sending request to backend API at $_baseUrl$_virtualTryOnEndpoint');
      print('Request fields: ${request.fields}');
      
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        // Parse response
        final responseData = json.decode(response.body);
        
        if (responseData['success'] == true) {
          // Download the result image
          final resultImageUrl = responseData['result_image_url'];
          print('Downloading result from: $resultImageUrl');
          return await _downloadAndSaveImage(resultImageUrl);
        } else {
          print('API Error: ${responseData['error']}');
          return null;
        }
      } else {
        print('HTTP Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('API call error: $e');
      return null;
    }
  }
  
  /// Download image from URL and save locally
  Future<String?> _downloadAndSaveImage(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      
      if (response.statusCode == 200) {
        final Directory tempDir = await getTemporaryDirectory();
        final String fileName = 'vton_result_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final String filePath = '${tempDir.path}/$fileName';
        
        final File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        
        return filePath;
      }
      
      return null;
    } catch (e) {
      print('Error downloading image: $e');
      return null;
    }
  }
  
  /// Get clothing type string for API
  String _getClothingType(CartItem item) {
    if (_isDress(item)) return 'dress';
    if (_isPolo(item)) return 'polo';
    if (_isTShirt(item)) return 'tshirt';
    return 'unknown';
  }
  
  /// Fallback to local processing if API is unavailable
  Future<String?> _processLocally(String imagePath, CartItem item) async {
    try {
      print('Falling back to local processing...');
      
      final File imageFile = File(imagePath);
      final Uint8List imageBytes = await imageFile.readAsBytes();
      img.Image? originalImage = img.decodeImage(imageBytes);
      
      if (originalImage == null) {
        return null;
      }
      
      // Simple overlay as fallback
      // This is just a placeholder - the real magic happens on the server
      img.Image processedImage = originalImage;
      
      // Add a simple watermark to indicate local processing
      img.drawString(
        processedImage,
        'Local Processing (API Unavailable)',
        font: img.arial14,
        x: 10,
        y: 10,
        color: img.ColorRgba8(255, 0, 0, 200),
      );
      
      return await _saveProcessedImage(processedImage);
    } catch (e) {
      print('Local processing error: $e');
      return null;
    }
  }

  /// Overlay clothing item on the detected body with improved fitting
  Future<img.Image> _overlayClothingItem(
    img.Image baseImage,
    Pose pose,
    CartItem item,
  ) async {
    try {
      // Get key body landmarks
      final landmarks = pose.landmarks;
      
      // Find relevant landmarks based on clothing type
      PoseLandmark? leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
      PoseLandmark? rightShoulder = landmarks[PoseLandmarkType.rightShoulder];
      PoseLandmark? leftHip = landmarks[PoseLandmarkType.leftHip];
      PoseLandmark? rightHip = landmarks[PoseLandmarkType.rightHip];
      
      if (leftShoulder == null || rightShoulder == null) {
        return baseImage; // Skip if key landmarks not detected
      }
      
      // Calculate dimensions and position based on item type
      print('DEBUG: Processing item: ${item.name}');
      if (_isDress(item)) {
        print('DEBUG: Overlaying dress with improved fitting');
        return await _overlayDressImproved(baseImage, pose, item);
      } else if (_isPolo(item)) {
        print('DEBUG: Overlaying polo shirt with improved fitting');
        return await _overlayPoloImproved(baseImage, pose, item);
      } else if (_isTShirt(item)) {
        print('DEBUG: Overlaying t-shirt with improved fitting');
        return await _overlayTShirtImproved(baseImage, pose, item);
      }
      
      print('DEBUG: No matching clothing type found for: ${item.name}');
      return baseImage;
    } catch (e) {
      print('Clothing overlay error: $e');
      return baseImage;
    }
  }

  /// Overlay dress on detected body
  Future<img.Image> _overlayDress(
    img.Image baseImage,
    Pose pose,
    CartItem item,
  ) async {
    // Get key landmarks
    final landmarks = pose.landmarks;
    PoseLandmark? leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
    PoseLandmark? rightShoulder = landmarks[PoseLandmarkType.rightShoulder];
    PoseLandmark? leftHip = landmarks[PoseLandmarkType.leftHip];
    PoseLandmark? rightHip = landmarks[PoseLandmarkType.rightHip];
    
    if (leftShoulder == null || rightShoulder == null || 
        leftHip == null || rightHip == null) {
      return baseImage;
    }
    
    // Calculate dress dimensions
    double shoulderWidth = (rightShoulder.x - leftShoulder.x).abs();
    double dressLength = ((leftHip.y + rightHip.y) / 2 - (leftShoulder.y + rightShoulder.y) / 2).abs() * 1.5;
    
    // Create dress overlay (simplified colored rectangle with transparency)
    img.Image dressOverlay = _createDressOverlay(
      shoulderWidth.toInt(),
      dressLength.toInt(),
      item.color,
    );
    
    // Calculate position to center the dress
    int centerX = ((leftShoulder.x + rightShoulder.x) / 2).toInt();
    int topY = ((leftShoulder.y + rightShoulder.y) / 2).toInt();
    
    // Composite the dress onto the base image
    img.compositeImage(
      baseImage,
      dressOverlay,
      dstX: centerX - (dressOverlay.width ~/ 2),
      dstY: topY,
      blend: img.BlendMode.overlay,
    );
    
    return baseImage;
  }

  /// Overlay polo shirt on detected body
  Future<img.Image> _overlayPolo(
    img.Image baseImage,
    Pose pose,
    CartItem item,
  ) async {
    // Get key landmarks for polo shirt
    final landmarks = pose.landmarks;
    PoseLandmark? leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
    PoseLandmark? rightShoulder = landmarks[PoseLandmarkType.rightShoulder];
    
    if (leftShoulder == null || rightShoulder == null) {
      return baseImage;
    }
    
    // Calculate dimensions for the overlay
    double shoulderWidth = (rightShoulder.x - leftShoulder.x).abs() * 1.5;
    double shirtLength = shoulderWidth * 1.2;
    
    img.Image? poloOverlay;
    
    // Try to load the polo image from assets
    if (item.imagePath != null) {
      try {
        final ByteData data = await rootBundle.load(item.imagePath!);
        final List<int> bytes = data.buffer.asUint8List();
        img.Image? rawImage = img.decodeImage(Uint8List.fromList(bytes));
        
        if (rawImage != null) {
          poloOverlay = img.copyResize(
            rawImage,
            width: shoulderWidth.toInt(),
            height: shirtLength.toInt(),
            interpolation: img.Interpolation.linear,
          );
        }
      } catch (e) {
        print('Error loading polo image: $e');
      }
    }
    
    // Fallback to creating a polo shape if image loading fails
    if (poloOverlay == null) {
      poloOverlay = _createPoloOverlay(
        shoulderWidth.toInt(),
        shirtLength.toInt(),
        item.color,
      );
    }
    
    // Calculate position
    int centerX = ((leftShoulder.x + rightShoulder.x) / 2).toInt();
    int topY = ((leftShoulder.y + rightShoulder.y) / 2).toInt() - 40;
    
    // Composite the polo shirt onto the base image
    img.compositeImage(
      baseImage,
      poloOverlay,
      dstX: centerX - (poloOverlay.width ~/ 2),
      dstY: topY,
      blend: img.BlendMode.overlay,
    );
    
    return baseImage;
  }

  /// Overlay t-shirt on detected body
  Future<img.Image> _overlayTShirt(
    img.Image baseImage,
    Pose pose,
    CartItem item,
  ) async {
    // Get key landmarks for t-shirt
    final landmarks = pose.landmarks;
    PoseLandmark? leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
    PoseLandmark? rightShoulder = landmarks[PoseLandmarkType.rightShoulder];
    PoseLandmark? leftElbow = landmarks[PoseLandmarkType.leftElbow];
    PoseLandmark? rightElbow = landmarks[PoseLandmarkType.rightElbow];
    
    if (leftShoulder == null || rightShoulder == null) {
      return baseImage;
    }
    
    // Calculate t-shirt dimensions
    double shoulderWidth = (rightShoulder.x - leftShoulder.x).abs() * 1.2;
    double shirtLength = shoulderWidth * 0.8; // T-shirt is typically shorter than dress
    
    // Create t-shirt overlay
    img.Image tshirtOverlay = _createTShirtOverlay(
      shoulderWidth.toInt(),
      shirtLength.toInt(),
      item.color,
    );
    
    // Calculate position
    int centerX = ((leftShoulder.x + rightShoulder.x) / 2).toInt();
    int topY = ((leftShoulder.y + rightShoulder.y) / 2).toInt() - 20;
    
    // Composite the t-shirt onto the base image
    img.compositeImage(
      baseImage,
      tshirtOverlay,
      dstX: centerX - (tshirtOverlay.width ~/ 2),
      dstY: topY,
      blend: img.BlendMode.overlay,
    );
    
    return baseImage;
  }

  /// Create dress overlay image
  img.Image _createDressOverlay(int width, int height, Color color) {
    img.Image overlay = img.Image(width: width, height: height);
    
    // Create dress shape with A-line silhouette
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        double progress = y / height;
        
        // A-line dress shape (wider at bottom)
        double shoulderWidth = width * 0.4;
        double bottomWidth = width * 0.9;
        double currentWidth = shoulderWidth + (bottomWidth - shoulderWidth) * progress;
        
        double centerX = width / 2;
        double leftEdge = centerX - currentWidth / 2;
        double rightEdge = centerX + currentWidth / 2;
        
        if (x >= leftEdge && x <= rightEdge) {
          // Create gradient effect
          double distanceFromCenter = (x - centerX).abs() / (currentWidth / 2);
          double alpha = 120 + (60 * (1 - distanceFromCenter)); // More opaque in center
          
          // Add vertical gradient for depth
          double verticalGradient = 1.0 - (progress * 0.3);
          alpha *= verticalGradient;
          
          img.ColorRgba8 pixelColor = img.ColorRgba8(
            (color.red * verticalGradient).toInt().clamp(0, 255),
            (color.green * verticalGradient).toInt().clamp(0, 255),
            (color.blue * verticalGradient).toInt().clamp(0, 255),
            alpha.toInt().clamp(0, 255),
          );
          
          overlay.setPixel(x, y, pixelColor);
        }
      }
    }
    
    // Add waistline detail
    _addWaistline(overlay, width, height, color);
    
    return overlay;
  }

  /// Create polo shirt overlay image
  img.Image _createPoloOverlay(int width, int height, Color color) {
    img.Image overlay = img.Image(width: width, height: height);

    // Create polo shirt shape
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        double progress = y / height;

        // Polo shirt body shape
        double bodyWidth = width * 0.7;
        double centerX = width / 2;
        double leftEdge = centerX - bodyWidth / 2;
        double rightEdge = centerX + bodyWidth / 2;

        // Add sleeves for upper portion (top 35%)
        if (progress < 0.35) {
          double sleeveExtension = width * 0.15 * (1 - progress / 0.35);
          leftEdge -= sleeveExtension;
          rightEdge += sleeveExtension;
        }

        if (x >= leftEdge && x <= rightEdge) {
          // Create gradient effect
          double distanceFromCenter = (x - centerX).abs() / (bodyWidth / 2);
          double alpha = 140 + (40 * (1 - distanceFromCenter));

          // Add subtle depth gradient
          double depthGradient = 1.0 - (distanceFromCenter * 0.2);

          img.ColorRgba8 pixelColor = img.ColorRgba8(
            (color.red * depthGradient).toInt().clamp(0, 255),
            (color.green * depthGradient).toInt().clamp(0, 255),
            (color.blue * depthGradient).toInt().clamp(0, 255),
            alpha.toInt().clamp(0, 255),
          );

          overlay.setPixel(x, y, pixelColor);
        }
      }
    }

    // Add polo collar
    _addPoloCollar(overlay, width, height, color);

    return overlay;
  }

  /// Create t-shirt overlay image
  img.Image _createTShirtOverlay(int width, int height, Color color) {
    img.Image overlay = img.Image(width: width, height: height);
    
    // Create t-shirt shape with proper sleeves
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        double progress = y / height;
        
        // T-shirt body shape (rectangular with slight taper)
        double bodyWidth = width * 0.7;
        double centerX = width / 2;
        double leftEdge = centerX - bodyWidth / 2;
        double rightEdge = centerX + bodyWidth / 2;
        
        // Add sleeves for upper portion (top 30%)
        if (progress < 0.3) {
          double sleeveExtension = width * 0.15 * (1 - progress / 0.3);
          leftEdge -= sleeveExtension;
          rightEdge += sleeveExtension;
        }
        
        if (x >= leftEdge && x <= rightEdge) {
          // Create gradient effect
          double distanceFromCenter = (x - centerX).abs() / (bodyWidth / 2);
          double alpha = 140 + (40 * (1 - distanceFromCenter));
          
          // Add subtle depth gradient
          double depthGradient = 1.0 - (distanceFromCenter * 0.2);
          
          img.ColorRgba8 pixelColor = img.ColorRgba8(
            (color.red * depthGradient).toInt().clamp(0, 255),
            (color.green * depthGradient).toInt().clamp(0, 255),
            (color.blue * depthGradient).toInt().clamp(0, 255),
            alpha.toInt().clamp(0, 255),
          );
          
          overlay.setPixel(x, y, pixelColor);
        }
      }
    }
    
    // Add neckline
    _addNeckline(overlay, width, height, color);
    
    return overlay;
  }

  /// Add basic shading to clothing for more realistic appearance
  void _addClothingShading(img.Image overlay, img.ColorRgba8 baseColor) {
    int width = overlay.width;
    int height = overlay.height;
    
    // Add subtle gradient for depth
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        double gradientFactor = 1.0 - (x / width) * 0.1; // Subtle left-to-right gradient
        
        img.ColorRgba8 shadedColor = img.ColorRgba8(
          (baseColor.r * gradientFactor).toInt().clamp(0, 255),
          (baseColor.g * gradientFactor).toInt().clamp(0, 255),
          (baseColor.b * gradientFactor).toInt().clamp(0, 255),
          baseColor.a.toInt(),
        );
        
        overlay.setPixel(x, y, shadedColor);
      }
    }
  }

  /// Add t-shirt specific details
  void _addTShirtDetails(img.Image overlay, img.ColorRgba8 baseColor) {
    // Add basic shading
    _addClothingShading(overlay, baseColor);
    
    // Add a subtle neckline (simple rounded rectangle)
    int neckWidth = (overlay.width * 0.3).toInt();
    int neckHeight = (overlay.height * 0.15).toInt();
    int neckX = (overlay.width - neckWidth) ~/ 2;
    int neckY = 0;
    
    // Create semi-transparent neckline
    img.ColorRgba8 neckColor = img.ColorRgba8(
      baseColor.r.toInt(),
      baseColor.g.toInt(),
      baseColor.b.toInt(),
      80, // More transparent for neckline
    );
    
    img.fillRect(
      overlay,
      x1: neckX,
      y1: neckY,
      x2: neckX + neckWidth,
      y2: neckY + neckHeight,
      color: neckColor,
    );
  }

  /// Save processed image to device storage
  Future<String> _saveProcessedImage(img.Image processedImage) async {
    final Directory tempDir = await getTemporaryDirectory();
    final String fileName = 'virtual_tryon_${DateTime.now().millisecondsSinceEpoch}.png';
    final String filePath = '${tempDir.path}/$fileName';
    
    final File file = File(filePath);
    await file.writeAsBytes(img.encodePng(processedImage));
    
    return filePath;
  }

  /// Check if item is a dress
  bool _isDress(CartItem item) {
    return item.name.toLowerCase().contains('dress');
  }

  /// Check if item is a polo shirt
  bool _isPolo(CartItem item) {
    bool isPolo = item.name.toLowerCase().contains('polo');
    print('DEBUG: Checking if "${item.name}" is polo: $isPolo');
    return isPolo;
  }

  /// Check if item is a t-shirt
  bool _isTShirt(CartItem item) {
    return item.name.toLowerCase().contains('t-shirt') || 
           item.name.toLowerCase().contains('tshirt') ||
           (item.name.toLowerCase().contains('shirt') && !_isPolo(item));
  }

  /// Add waistline detail to dress
  void _addWaistline(img.Image overlay, int width, int height, Color color) {
    int waistY = (height * 0.4).toInt(); // Waist at 40% of dress height
    int waistHeight = 3;
    
    // Add darker waistline
    img.ColorRgba8 waistColor = img.ColorRgba8(
      (color.red * 0.7).toInt().clamp(0, 255),
      (color.green * 0.7).toInt().clamp(0, 255),
      (color.blue * 0.7).toInt().clamp(0, 255),
      180,
    );
    
    img.fillRect(
      overlay,
      x1: 0,
      y1: waistY,
      x2: width,
      y2: waistY + waistHeight,
      color: waistColor,
    );
  }
  
  /// Add polo collar detail
  void _addPoloCollar(img.Image overlay, int width, int height, Color color) {
    // Polo collar dimensions
    int collarWidth = (width * 0.3).toInt();
    int collarHeight = (height * 0.15).toInt();
    int collarX = (width - collarWidth) ~/ 2;
    int collarY = 2;
    
    // Create collar outline (darker color)
    img.ColorRgba8 collarColor = img.ColorRgba8(
      (color.red * 0.8).toInt().clamp(0, 255),
      (color.green * 0.8).toInt().clamp(0, 255),
      (color.blue * 0.8).toInt().clamp(0, 255),
      160,
    );
    
    // Draw collar outline
    for (int i = 0; i < 3; i++) {
      // Top horizontal line
      img.drawLine(overlay,
          x1: collarX,
          y1: collarY + i,
          x2: collarX + collarWidth,
          y2: collarY + i,
          color: collarColor);
      
      // Left vertical line
      img.drawLine(overlay,
          x1: collarX + i,
          y1: collarY,
          x2: collarX + i,
          y2: collarY + collarHeight,
          color: collarColor);
      
      // Right vertical line
      img.drawLine(overlay,
          x1: collarX + collarWidth - i,
          y1: collarY,
          x2: collarX + collarWidth - i,
          y2: collarY + collarHeight,
          color: collarColor);
    }
    
    // Add button placket (vertical line down center)
    int placketX = width ~/ 2;
    img.ColorRgba8 placketColor = img.ColorRgba8(
      (color.red * 0.7).toInt().clamp(0, 255),
      (color.green * 0.7).toInt().clamp(0, 255),
      (color.blue * 0.7).toInt().clamp(0, 255),
      140,
    );
    
    for (int y = collarY + collarHeight; y < collarY + collarHeight + (height * 0.2).toInt(); y++) {
      overlay.setPixel(placketX, y, placketColor);
      overlay.setPixel(placketX + 1, y, placketColor);
    }
    
    // Add small buttons
    _addPoloButtons(overlay, placketX, collarY + collarHeight + 10, height, placketColor);
  }
  
  /// Add small buttons to polo shirt
  void _addPoloButtons(img.Image overlay, int centerX, int startY, int height, img.ColorRgba8 buttonColor) {
    int buttonSpacing = (height * 0.08).toInt();
    int buttonSize = 3;
    
    // Add 2-3 small buttons
    for (int i = 0; i < 3; i++) {
      int buttonY = startY + (i * buttonSpacing);
      if (buttonY + buttonSize < overlay.height) {
        // Draw small circular button
        for (int dy = -buttonSize; dy <= buttonSize; dy++) {
          for (int dx = -buttonSize; dx <= buttonSize; dx++) {
            if (dx * dx + dy * dy <= buttonSize * buttonSize) {
              int x = centerX + dx;
              int y = buttonY + dy;
              if (x >= 0 && x < overlay.width && y >= 0 && y < overlay.height) {
                overlay.setPixel(x, y, buttonColor);
              }
            }
          }
        }
      }
    }
  }

  /// Add neckline detail to t-shirt
  void _addNeckline(img.Image overlay, int width, int height, Color color) {
    int neckWidth = (width * 0.25).toInt();
    int neckHeight = (height * 0.12).toInt();
    int neckX = (width - neckWidth) ~/ 2;
    int neckY = 5;
    
    // Create rounded neckline by clearing pixels in oval shape
    for (int y = neckY; y < neckY + neckHeight; y++) {
      for (int x = neckX; x < neckX + neckWidth; x++) {
        // Calculate if pixel is inside oval
        double normalizedX = (x - neckX - neckWidth / 2) / (neckWidth / 2);
        double normalizedY = (y - neckY - neckHeight / 2) / (neckHeight / 2);
        
        if (normalizedX * normalizedX + normalizedY * normalizedY <= 1.0) {
          // Make neckline more transparent
          img.ColorRgba8 neckColor = img.ColorRgba8(
            color.red,
            color.green,
            color.blue,
            60, // Very transparent for neckline opening
          );
          overlay.setPixel(x, y, neckColor);
        }
      }
    }
  }

  /// Improved dress overlay with better body fitting
  Future<img.Image> _overlayDressImproved(
    img.Image baseImage,
    Pose pose,
    CartItem item,
  ) async {
    final landmarks = pose.landmarks;
    PoseLandmark? leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
    PoseLandmark? rightShoulder = landmarks[PoseLandmarkType.rightShoulder];
    PoseLandmark? leftHip = landmarks[PoseLandmarkType.leftHip];
    PoseLandmark? rightHip = landmarks[PoseLandmarkType.rightHip];
    PoseLandmark? leftElbow = landmarks[PoseLandmarkType.leftElbow];
    PoseLandmark? rightElbow = landmarks[PoseLandmarkType.rightElbow];
    PoseLandmark? leftWrist = landmarks[PoseLandmarkType.leftWrist];
    PoseLandmark? rightWrist = landmarks[PoseLandmarkType.rightWrist];
    
    if (leftShoulder == null || rightShoulder == null || 
        leftHip == null || rightHip == null) {
      return baseImage;
    }
    
    // Create body mask for better fitting
    img.Image bodyMask = await _createBodyMask(baseImage, pose);
    
    // Load clothing texture/pattern
    img.Image? clothingTexture = await _loadClothingTexture(item);
    
    // Create dress silhouette that follows body contours
    img.Image dressOverlay = await _createContourFittedDress(
      baseImage.width,
      baseImage.height,
      pose,
      item,
      clothingTexture,
    );
    
    // Apply the overlay with proper masking to preserve colors
    return _applyClothingWithMask(baseImage, dressOverlay, bodyMask);
  }
  
  /// Improved polo overlay with better body fitting
  Future<img.Image> _overlayPoloImproved(
    img.Image baseImage,
    Pose pose,
    CartItem item,
  ) async {
    final landmarks = pose.landmarks;
    PoseLandmark? leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
    PoseLandmark? rightShoulder = landmarks[PoseLandmarkType.rightShoulder];
    
    if (leftShoulder == null || rightShoulder == null) {
      return baseImage;
    }
    
    // Create body mask for torso area
    img.Image bodyMask = await _createTorsoMask(baseImage, pose);
    
    // Load clothing texture/pattern
    img.Image? clothingTexture = await _loadClothingTexture(item);
    
    // Create polo silhouette that follows body contours
    img.Image poloOverlay = await _createContourFittedPolo(
      baseImage.width,
      baseImage.height,
      pose,
      item,
      clothingTexture,
    );
    
    // Apply the overlay with proper masking
    return _applyClothingWithMask(baseImage, poloOverlay, bodyMask);
  }
  
  /// Improved t-shirt overlay with better body fitting
  Future<img.Image> _overlayTShirtImproved(
    img.Image baseImage,
    Pose pose,
    CartItem item,
  ) async {
    final landmarks = pose.landmarks;
    PoseLandmark? leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
    PoseLandmark? rightShoulder = landmarks[PoseLandmarkType.rightShoulder];
    
    if (leftShoulder == null || rightShoulder == null) {
      return baseImage;
    }
    
    // Create body mask for torso area
    img.Image bodyMask = await _createTorsoMask(baseImage, pose);
    
    // Load clothing texture/pattern
    img.Image? clothingTexture = await _loadClothingTexture(item);
    
    // Create t-shirt silhouette that follows body contours
    img.Image tshirtOverlay = await _createContourFittedTShirt(
      baseImage.width,
      baseImage.height,
      pose,
      item,
      clothingTexture,
    );
    
    // Apply the overlay with proper masking
    return _applyClothingWithMask(baseImage, tshirtOverlay, bodyMask);
  }
  
  /// Create body mask for better clothing application
  Future<img.Image> _createBodyMask(img.Image baseImage, Pose pose) async {
    img.Image mask = img.Image(width: baseImage.width, height: baseImage.height);
    final landmarks = pose.landmarks;
    
    // Get key body points
    List<Point> bodyPoints = [];
    
    // Add torso outline points in clockwise order
    if (landmarks[PoseLandmarkType.leftShoulder] != null) {
      bodyPoints.add(Point(landmarks[PoseLandmarkType.leftShoulder]!.x, 
                           landmarks[PoseLandmarkType.leftShoulder]!.y));
    }
    if (landmarks[PoseLandmarkType.rightShoulder] != null) {
      bodyPoints.add(Point(landmarks[PoseLandmarkType.rightShoulder]!.x, 
                           landmarks[PoseLandmarkType.rightShoulder]!.y));
    }
    if (landmarks[PoseLandmarkType.rightHip] != null) {
      bodyPoints.add(Point(landmarks[PoseLandmarkType.rightHip]!.x, 
                           landmarks[PoseLandmarkType.rightHip]!.y));
    }
    if (landmarks[PoseLandmarkType.leftHip] != null) {
      bodyPoints.add(Point(landmarks[PoseLandmarkType.leftHip]!.x, 
                           landmarks[PoseLandmarkType.leftHip]!.y));
    }
    
    // Fill the body area in the mask
    if (bodyPoints.length >= 4) {
      _fillPolygon(mask, bodyPoints, img.ColorRgba8(255, 255, 255, 255));
    }
    
    return mask;
  }
  
  /// Create torso-specific mask
  Future<img.Image> _createTorsoMask(img.Image baseImage, Pose pose) async {
    img.Image mask = img.Image(width: baseImage.width, height: baseImage.height);
    final landmarks = pose.landmarks;
    
    // Get torso landmarks
    PoseLandmark? leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
    PoseLandmark? rightShoulder = landmarks[PoseLandmarkType.rightShoulder];
    PoseLandmark? leftElbow = landmarks[PoseLandmarkType.leftElbow];
    PoseLandmark? rightElbow = landmarks[PoseLandmarkType.rightElbow];
    
    if (leftShoulder != null && rightShoulder != null) {
      // Create torso mask based on shoulder width and estimated torso length
      double shoulderWidth = (rightShoulder.x - leftShoulder.x).abs();
      double centerX = (leftShoulder.x + rightShoulder.x) / 2;
      double centerY = (leftShoulder.y + rightShoulder.y) / 2;
      
      // Estimate torso dimensions
      int torsoWidth = (shoulderWidth * 1.2).toInt();
      int torsoHeight = (shoulderWidth * 1.5).toInt();
      
      // Create elliptical torso mask
      for (int y = 0; y < baseImage.height; y++) {
        for (int x = 0; x < baseImage.width; x++) {
          double normalizedX = (x - centerX) / (torsoWidth / 2);
          double normalizedY = (y - centerY) / (torsoHeight / 2);
          
          if (normalizedX * normalizedX + normalizedY * normalizedY <= 1.0) {
            mask.setPixel(x, y, img.ColorRgba8(255, 255, 255, 255));
          }
        }
      }
    }
    
    return mask;
  }
  
  /// Load clothing texture from assets or create pattern
  Future<img.Image?> _loadClothingTexture(CartItem item) async {
    if (item.imagePath != null) {
      try {
        final ByteData data = await rootBundle.load(item.imagePath!);
        final List<int> bytes = data.buffer.asUint8List();
        return img.decodeImage(Uint8List.fromList(bytes));
      } catch (e) {
        print('Error loading clothing texture: $e');
      }
    }
    return null;
  }
  
  /// Create contour-fitted dress
  Future<img.Image> _createContourFittedDress(
    int width,
    int height,
    Pose pose,
    CartItem item,
    img.Image? texture,
  ) async {
    img.Image overlay = img.Image(width: width, height: height);
    final landmarks = pose.landmarks;
    
    PoseLandmark? leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
    PoseLandmark? rightShoulder = landmarks[PoseLandmarkType.rightShoulder];
    PoseLandmark? leftHip = landmarks[PoseLandmarkType.leftHip];
    PoseLandmark? rightHip = landmarks[PoseLandmarkType.rightHip];
    
    if (leftShoulder == null || rightShoulder == null || leftHip == null || rightHip == null) {
      return overlay;
    }
    
    // Calculate dress contour points
    List<Point> dressContour = [];
    
    // Top (shoulders)
    double shoulderY = (leftShoulder.y + rightShoulder.y) / 2;
    dressContour.add(Point(leftShoulder.x - 20, shoulderY));
    dressContour.add(Point(rightShoulder.x + 20, shoulderY));
    
    // Waist (between shoulders and hips)
    double waistY = shoulderY + (((leftHip.y + rightHip.y) / 2) - shoulderY) * 0.6;
    double waistWidth = (rightShoulder.x - leftShoulder.x) * 0.8;
    double centerX = (leftShoulder.x + rightShoulder.x) / 2;
    dressContour.add(Point(centerX + waistWidth / 2, waistY));
    
    // Bottom (flared)
    double bottomY = (leftHip.y + rightHip.y) / 2 + 100; // Extend below hips
    double bottomWidth = (rightHip.x - leftHip.x) * 1.3;
    dressContour.add(Point(centerX + bottomWidth / 2, bottomY));
    dressContour.add(Point(centerX - bottomWidth / 2, bottomY));
    
    // Left side
    dressContour.add(Point(centerX - waistWidth / 2, waistY));
    
    // Fill dress shape with texture or solid color
    if (texture != null) {
      _fillPolygonWithTexture(overlay, dressContour, texture);
    } else {
      _fillPolygon(overlay, dressContour, img.ColorRgba8(
        item.color.red,
        item.color.green,
        item.color.blue,
        200, // Semi-transparent
      ));
    }
    
    return overlay;
  }
  
  /// Create contour-fitted polo
  Future<img.Image> _createContourFittedPolo(
    int width,
    int height,
    Pose pose,
    CartItem item,
    img.Image? texture,
  ) async {
    img.Image overlay = img.Image(width: width, height: height);
    final landmarks = pose.landmarks;
    
    PoseLandmark? leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
    PoseLandmark? rightShoulder = landmarks[PoseLandmarkType.rightShoulder];
    PoseLandmark? leftElbow = landmarks[PoseLandmarkType.leftElbow];
    PoseLandmark? rightElbow = landmarks[PoseLandmarkType.rightElbow];
    
    if (leftShoulder == null || rightShoulder == null) {
      return overlay;
    }
    
    // Calculate polo contour following body shape
    double centerX = (leftShoulder.x + rightShoulder.x) / 2;
    double centerY = (leftShoulder.y + rightShoulder.y) / 2;
    double shoulderWidth = (rightShoulder.x - leftShoulder.x).abs();
    
    // Create fitted polo shape
    List<Point> poloContour = [];
    
    // Collar area (narrower)
    poloContour.add(Point(centerX - shoulderWidth * 0.3, centerY - 30));
    poloContour.add(Point(centerX + shoulderWidth * 0.3, centerY - 30));
    
    // Shoulders (with sleeves)
    poloContour.add(Point(rightShoulder.x + 40, rightShoulder.y));
    
    // Right side down to waist
    double waistY = centerY + shoulderWidth * 0.8;
    poloContour.add(Point(centerX + shoulderWidth * 0.5, waistY));
    
    // Bottom edge
    poloContour.add(Point(centerX - shoulderWidth * 0.5, waistY));
    
    // Left side with sleeve
    poloContour.add(Point(leftShoulder.x - 40, leftShoulder.y));
    
    // Fill polo shape
    if (texture != null) {
      _fillPolygonWithTexture(overlay, poloContour, texture);
    } else {
      _fillPolygon(overlay, poloContour, img.ColorRgba8(
        item.color.red,
        item.color.green,
        item.color.blue,
        200,
      ));
    }
    
    // Add polo details (collar, buttons)
    _addImprovedPoloDetails(overlay, centerX.toInt(), centerY.toInt(), item.color);
    
    return overlay;
  }
  
  /// Create contour-fitted t-shirt
  Future<img.Image> _createContourFittedTShirt(
    int width,
    int height,
    Pose pose,
    CartItem item,
    img.Image? texture,
  ) async {
    img.Image overlay = img.Image(width: width, height: height);
    final landmarks = pose.landmarks;
    
    PoseLandmark? leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
    PoseLandmark? rightShoulder = landmarks[PoseLandmarkType.rightShoulder];
    
    if (leftShoulder == null || rightShoulder == null) {
      return overlay;
    }
    
    double centerX = (leftShoulder.x + rightShoulder.x) / 2;
    double centerY = (leftShoulder.y + rightShoulder.y) / 2;
    double shoulderWidth = (rightShoulder.x - leftShoulder.x).abs();
    
    // Create fitted t-shirt shape
    List<Point> tshirtContour = [];
    
    // Neckline
    tshirtContour.add(Point(centerX - shoulderWidth * 0.25, centerY - 25));
    tshirtContour.add(Point(centerX + shoulderWidth * 0.25, centerY - 25));
    
    // Shoulders with short sleeves
    tshirtContour.add(Point(rightShoulder.x + 35, rightShoulder.y));
    tshirtContour.add(Point(rightShoulder.x + 35, rightShoulder.y + 50));
    
    // Right side to waist
    double waistY = centerY + shoulderWidth * 0.7;
    tshirtContour.add(Point(centerX + shoulderWidth * 0.45, waistY));
    
    // Bottom edge
    tshirtContour.add(Point(centerX - shoulderWidth * 0.45, waistY));
    
    // Left side with short sleeve
    tshirtContour.add(Point(leftShoulder.x - 35, leftShoulder.y + 50));
    tshirtContour.add(Point(leftShoulder.x - 35, leftShoulder.y));
    
    // Fill t-shirt shape
    if (texture != null) {
      _fillPolygonWithTexture(overlay, tshirtContour, texture);
    } else {
      _fillPolygon(overlay, tshirtContour, img.ColorRgba8(
        item.color.red,
        item.color.green,
        item.color.blue,
        200,
      ));
    }
    
    // Add t-shirt neckline
    _addImprovedNeckline(overlay, centerX.toInt(), (centerY - 25).toInt(), shoulderWidth.toInt(), item.color);
    
    return overlay;
  }
  
  /// Apply clothing with proper masking to preserve colors
  img.Image _applyClothingWithMask(img.Image baseImage, img.Image clothingOverlay, img.Image bodyMask) {
    img.Image result = img.copyResize(baseImage, width: baseImage.width, height: baseImage.height);
    
    for (int y = 0; y < result.height; y++) {
      for (int x = 0; x < result.width; x++) {
        img.Pixel maskPixel = bodyMask.getPixel(x, y);
        img.Pixel clothingPixel = clothingOverlay.getPixel(x, y);
        
        // Only apply clothing where there's body mask and clothing overlay
        if (maskPixel.a > 0 && clothingPixel.a > 0) {
          // Use alpha blending to preserve clothing colors
          double alpha = clothingPixel.a / 255.0;
          img.Pixel basePixel = result.getPixel(x, y);
          
          int newR = (clothingPixel.r * alpha + basePixel.r * (1 - alpha)).round();
          int newG = (clothingPixel.g * alpha + basePixel.g * (1 - alpha)).round();
          int newB = (clothingPixel.b * alpha + basePixel.b * (1 - alpha)).round();
          
          result.setPixel(x, y, img.ColorRgba8(newR, newG, newB, 255));
        }
      }
    }
    
    return result;
  }
  
  /// Fill polygon with solid color
  void _fillPolygon(img.Image image, List<Point> points, img.ColorRgba8 color) {
    if (points.length < 3) return;
    
    // Simple polygon fill using scanline algorithm
    int minY = points.map((p) => p.y as int).reduce((a, b) => a < b ? a : b);
    int maxY = points.map((p) => p.y as int).reduce((a, b) => a > b ? a : b);
    
    for (int y = minY; y <= maxY; y++) {
      List<int> intersections = [];
      
      for (int i = 0; i < points.length; i++) {
        int j = (i + 1) % points.length;
        Point p1 = points[i];
        Point p2 = points[j];
        
        if ((p1.y as int) <= y && y < (p2.y as int) || (p2.y as int) <= y && y < (p1.y as int)) {
          double x = (p1.x as double) + ((y - (p1.y as int)) / ((p2.y as int) - (p1.y as int))) * ((p2.x as int) - (p1.x as int));
          intersections.add(x.round());
        }
      }
      
      intersections.sort();
      for (int i = 0; i < intersections.length - 1; i += 2) {
        for (int x = intersections[i]; x <= intersections[i + 1]; x++) {
          if (x >= 0 && x < image.width && y >= 0 && y < image.height) {
            image.setPixel(x, y, color);
          }
        }
      }
    }
  }
  
  /// Fill polygon with texture
  void _fillPolygonWithTexture(img.Image image, List<Point> points, img.Image texture) {
    if (points.length < 3) return;
    
    int minY = points.map((p) => p.y as int).reduce((a, b) => a < b ? a : b);
    int maxY = points.map((p) => p.y as int).reduce((a, b) => a > b ? a : b);
    
    for (int y = minY; y <= maxY; y++) {
      List<int> intersections = [];
      
      for (int i = 0; i < points.length; i++) {
        int j = (i + 1) % points.length;
        Point p1 = points[i];
        Point p2 = points[j];
        
        if ((p1.y as int) <= y && y < (p2.y as int) || (p2.y as int) <= y && y < (p1.y as int)) {
          double x = (p1.x as double) + ((y - (p1.y as int)) / ((p2.y as int) - (p1.y as int))) * ((p2.x as int) - (p1.x as int));
          intersections.add(x.round());
        }
      }
      
      intersections.sort();
      for (int i = 0; i < intersections.length - 1; i += 2) {
        for (int x = intersections[i]; x <= intersections[i + 1]; x++) {
          if (x >= 0 && x < image.width && y >= 0 && y < image.height) {
            // Sample texture
            int texX = x % texture.width;
            int texY = y % texture.height;
            img.Pixel texPixel = texture.getPixel(texX, texY);
            
            img.ColorRgba8 color = img.ColorRgba8(
              texPixel.r.toInt(),
              texPixel.g.toInt(),
              texPixel.b.toInt(),
              200, // Semi-transparent
            );
            
            image.setPixel(x, y, color);
          }
        }
      }
    }
  }
  
  /// Add improved polo details
  void _addImprovedPoloDetails(img.Image overlay, int centerX, int centerY, Color color) {
    // Add collar with better proportions
    int collarWidth = 60;
    int collarHeight = 25;
    
    img.ColorRgba8 collarColor = img.ColorRgba8(
      (color.red * 0.8).toInt().clamp(0, 255),
      (color.green * 0.8).toInt().clamp(0, 255),
      (color.blue * 0.8).toInt().clamp(0, 255),
      180,
    );
    
    // Draw collar
    img.fillRect(overlay,
        x1: centerX - collarWidth ~/ 2,
        y1: centerY - 30,
        x2: centerX + collarWidth ~/ 2,
        y2: centerY - 5,
        color: collarColor);
    
    // Add button placket
    for (int i = 0; i < 3; i++) {
      int buttonY = centerY + (i * 20);
      img.fillCircle(overlay,
          x: centerX,
          y: buttonY,
          radius: 3,
          color: img.ColorRgba8(50, 50, 50, 200));
    }
  }
  
  /// Add improved neckline
  void _addImprovedNeckline(img.Image overlay, int centerX, int centerY, int width, Color color) {
    int neckWidth = (width * 0.4).toInt();
    int neckHeight = 30;
    
    // Create rounded neckline by making it more transparent
    for (int y = centerY; y < centerY + neckHeight; y++) {
      for (int x = centerX - neckWidth ~/ 2; x < centerX + neckWidth ~/ 2; x++) {
        if (x >= 0 && x < overlay.width && y >= 0 && y < overlay.height) {
          // Elliptical neckline
          double normalizedX = (x - centerX) / (neckWidth / 2);
          double normalizedY = (y - centerY) / (neckHeight / 2);
          
          if (normalizedX * normalizedX + normalizedY * normalizedY <= 1.0) {
            overlay.setPixel(x, y, img.ColorRgba8(0, 0, 0, 0)); // Transparent
          }
        }
      }
    }
  }
  
  /// Dispose resources
  void dispose() {
    _poseDetector.close();
  }
}
