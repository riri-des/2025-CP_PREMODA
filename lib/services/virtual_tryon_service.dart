import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'cart_service.dart';

class VirtualTryOnService {
  static final VirtualTryOnService _instance = VirtualTryOnService._internal();
  factory VirtualTryOnService() => _instance;
  VirtualTryOnService._internal();

  // Segmind IDM VTON API configuration
  static const String _segmindApiKey = 'SG_81022f8ae44da459';
  static const String _segmindBaseUrl = 'https://api.segmind.com/v1/idm-vton';
  static const Map<String, String> _segmindHeaders = {
    'x-api-key': _segmindApiKey,
    'Content-Type': 'application/json',
  };

  /// Process image for virtual try-on using Segmind IDM VTON API
  Future<String?> processVirtualTryOn({
    required String imagePath,
    required List<CartItem> selectedItems,
  }) async {
    try {
      print('🚀 Starting Segmind IDM VTON process...');
      
      // Process each item through the Segmind API
      String? currentImagePath = imagePath;
      
      for (CartItem item in selectedItems) {
        print('🔄 Processing item: ${item.product.name}');
        
        // Call the Segmind IDM VTON API for realistic virtual try-on
        final resultPath = await _callSegmindVTONAPI(
          personImagePath: currentImagePath!,
          clothingItem: item,
        );
        
        if (resultPath != null) {
          currentImagePath = resultPath;
          print('✅ Successfully processed: ${item.product.name}');
        } else {
          print('❌ Failed to process item: ${item.product.name}');
          // Return original image if API fails
          return imagePath;
        }
      }
      
      return currentImagePath;
    } catch (e) {
      print('💥 Virtual try-on error: $e');
      return null;
    }
  }
  
  /// Call the Segmind IDM VTON API for virtual try-on processing
  Future<String?> _callSegmindVTONAPI({
    required String personImagePath,
    required CartItem clothingItem,
  }) async {
    try {
      print('🌐 Calling Segmind IDM VTON API...');
      
      // Convert images to base64
      final String personBase64 = await _imageToBase64(personImagePath);
      final String clothingBase64 = await _getClothingImageBase64(clothingItem);
      
      if (clothingBase64.isEmpty) {
        print('⚠️ No clothing image available for ${clothingItem.product.name}');
        return null;
      }
      
      // Prepare API request body
      final Map<String, dynamic> requestBody = {
        'human_img': personBase64,
        'garm_img': clothingBase64,
        'garment_des': clothingItem.product.description ?? clothingItem.product.name,
        'is_checked': true,
        'is_checked_crop': false,
        'denoise_steps': 30,
        'seed': 42,
      };
      
      print('📤 Sending request to Segmind...');
      
      // Make API call
      final response = await http.post(
        Uri.parse(_segmindBaseUrl),
        headers: _segmindHeaders,
        body: json.encode(requestBody),
      );
      
      print('📥 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        // The response should be the image data directly
        final Directory tempDir = await getTemporaryDirectory();
        final String fileName = 'segmind_vton_${DateTime.now().millisecondsSinceEpoch}.png';
        final String filePath = '${tempDir.path}/$fileName';
        
        final File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        
        print('💾 Saved result to: $filePath');
        return filePath;
      } else {
        print('❌ Segmind API Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('💥 Segmind API call error: $e');
      return null;
    }
  }
  
  /// Convert image file to base64 string
  Future<String> _imageToBase64(String imagePath) async {
    try {
      final File imageFile = File(imagePath);
      final Uint8List imageBytes = await imageFile.readAsBytes();
      return base64Encode(imageBytes);
    } catch (e) {
      print('Error converting image to base64: $e');
      return '';
    }
  }
  
  /// Get clothing image as base64 string
  Future<String> _getClothingImageBase64(CartItem clothingItem) async {
    try {
      if (clothingItem.product.images.isEmpty) {
        return '';
      }
      
      final String imageUrl = clothingItem.product.images.first.url;
      print('🖼️ Fetching clothing image from: $imageUrl');
      
      // Download the image from URL
      final response = await http.get(Uri.parse(imageUrl));
      
      if (response.statusCode == 200) {
        return base64Encode(response.bodyBytes);
      } else {
        print('❌ Failed to download clothing image: ${response.statusCode}');
        return '';
      }
    } catch (e) {
      print('💥 Error getting clothing image: $e');
      return '';
    }
  }
}
