import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'supabase_cart_service.dart';

class VirtualTryOnService {
  static final VirtualTryOnService _instance = VirtualTryOnService._internal();
  factory VirtualTryOnService() => _instance;
  VirtualTryOnService._internal();

  // Segmind IDM VTON API configuration
  static const String _segmindApiKey = 'SG_aff45d4351404687';
  static const String _segmindBaseUrl = 'https://api.segmind.com/v1/idm-vton';
  static const Map<String, String> _segmindHeaders = {
    'x-api-key': _segmindApiKey,
    'Content-Type': 'application/json',
  };

  // Try-On Diffusion RapidAPI configuration
  static const String _rapidApiKey = 'b75e64c226msha16712b015a584ep10a98ajsne4c7d3c56848';
  static const String _rapidApiHost = 'try-on-diffusion.p.rapidapi.com';
  static const String _rapidApiUrl = 'https://try-on-diffusion.p.rapidapi.com/try-on-file';

  /// Process image for virtual try-on using Try-On Diffusion RapidAPI or Segmind
  Future<String?> processVirtualTryOn({
    required String imagePath,
    required List<CartItem> selectedItems,
    String? modelImagePath,
    bool useRapidAPI = true,
  }) async {
    try {
      if (useRapidAPI && modelImagePath != null) {
        print(' Starting Try-On Diffusion RapidAPI process...');
        
        // Process each item through the RapidAPI
        String? currentImagePath = modelImagePath;
        
        for (CartItem item in selectedItems) {
          print(' Processing item: ${item.product.name}');
          
          // Call the Try-On Diffusion RapidAPI
          final resultPath = await _callRapidAPITryOn(
            modelImagePath: currentImagePath!,
            clothingItem: item,
          );
          
          if (resultPath != null) {
            currentImagePath = resultPath;
            print(' Successfully processed: ${item.product.name}');
          } else {
            print(' Failed to process item: ${item.product.name}');
            // Return original image if API fails
            return modelImagePath;
          }
        }
        
        return currentImagePath;
      } else {
        print(' Starting Segmind IDM VTON process...');
        
        // Process each item through the Segmind API
        String? currentImagePath = imagePath;
        
        for (CartItem item in selectedItems) {
          print(' Processing item: ${item.product.name}');
          
          // Call the Segmind IDM VTON API for realistic virtual try-on
          final resultPath = await _callSegmindVTONAPI(
            personImagePath: currentImagePath!,
            clothingItem: item,
          );
          
          if (resultPath != null) {
            currentImagePath = resultPath;
            print(' Successfully processed: ${item.product.name}');
          } else {
            print(' Failed to process item: ${item.product.name}');
            // Return original image if API fails
            return imagePath;
          }
        }
        
        return currentImagePath;
      }
    } catch (e) {
      print(' Virtual try-on error: $e');
      return null;
    }
  }
  
  /// Call the Segmind IDM VTON API for virtual try-on processing
  Future<String?> _callSegmindVTONAPI({
    required String personImagePath,
    required CartItem clothingItem,
  }) async {
    try {
      print(' Calling Segmind IDM VTON API...');
      
      // Convert images to base64
      final String personBase64 = await _imageToBase64(personImagePath);
      final String clothingBase64 = await _getClothingImageBase64(clothingItem);
      
      if (clothingBase64.isEmpty) {
        print(' No clothing image available for ${clothingItem.product.name}');
        return null;
      }
      
      // Prepare API request body
      final Map<String, dynamic> requestBody = {
        'human_img': personBase64,
        'garm_img': clothingBase64,
        'garment_des': clothingItem.product.description ?? clothingItem.product.name,
        // IDM-VTON params per Segmind docs
        'crop': true, // use cropping if needed (3:4 check)
        'seed': 42,
        'steps': 30,
        'category': _mapSegmindCategory(clothingItem.product.category),
        // DressCode version only for dresses per docs
        'force_dc': _mapSegmindCategory(clothingItem.product.category) == 'dresses',
        // ensure we want the composed image, not only mask
        'mask_only': false,
      };
      
      print(' Sending request to Segmind...');
      
      // Make API call
      final response = await http.post(
        Uri.parse(_segmindBaseUrl),
        headers: _segmindHeaders,
        body: json.encode(requestBody),
      );
      
      print(' Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        // The response should be the image data directly
        final Directory tempDir = await getTemporaryDirectory();
        final String fileName = 'segmind_vton_${DateTime.now().millisecondsSinceEpoch}.png';
        final String filePath = '${tempDir.path}/$fileName';
        
        final File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        
        print(' Saved result to: $filePath');
        return filePath;
      } else {
        print(' Segmind API Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print(' Segmind API call error: $e');
      return null;
    }
  }

  /// Map local product categories to Segmind IDM-VTON expected enum
  /// Defaults to 'upper_body'. Possible values include 'upper_body', 'lower_body', 'dresses'.
  String _mapSegmindCategory(String rawCategory) {
    final c = rawCategory.toLowerCase();
    // Dresses
    if (c.contains('dress')) return 'dresses';
    // Lower body
    if (c.contains('pants') ||
        c.contains('trousers') ||
        c.contains('jeans') ||
        c.contains('shorts') ||
        c.contains('skirt') ||
        c.contains('bottom')) {
      return 'lower_body';
    }
    // Default to upper body for shirts, tees, tops, hoodies, jackets, coats, etc.
    return 'upper_body';
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
      print(' Fetching clothing image from: $imageUrl');
      
      // Download the image from URL
      final response = await http.get(Uri.parse(imageUrl));
      
      if (response.statusCode == 200) {
        return base64Encode(response.bodyBytes);
      } else {
        print(' Failed to download clothing image: ${response.statusCode}');
        return '';
      }
    } catch (e) {
      print(' Error getting clothing image: $e');
      return '';
    }
  }

  /// Call the Try-On Diffusion RapidAPI for virtual try-on processing
  Future<String?> _callRapidAPITryOn({
    required String modelImagePath,
    required CartItem clothingItem,
  }) async {
    try {
      print(' Calling Try-On Diffusion RapidAPI...');

      // Verify avatar/person image exists (to be sent as 'avatar_image')
      final File modelFile = File(modelImagePath);
      if (!await modelFile.exists()) {
        print(' Model image file not found: $modelImagePath');
        return null;
      }

      // Ensure we have a clothing image; download and save to temp to send as file
      if (clothingItem.product.images.isEmpty) {
        print(' No clothing image available for ${clothingItem.product.name}');
        return null;
      }

      final String clothingImageUrl = clothingItem.product.images.first.url;
      print(' Downloading clothing image for upload: $clothingImageUrl');
      final clothingResp = await http.get(Uri.parse(clothingImageUrl));
      if (clothingResp.statusCode != 200) {
        print(' Failed to download clothing image: ${clothingResp.statusCode}');
        return null;
      }
      // Determine clothing content type and extension
      final clothingCtHeader = clothingResp.headers['content-type'] ?? '';
      String clothingSubtype;
      if (clothingCtHeader.contains('image/')) {
        clothingSubtype = clothingCtHeader.split('/').last;
      } else if (clothingImageUrl.toLowerCase().endsWith('.png')) {
        clothingSubtype = 'png';
      } else if (clothingImageUrl.toLowerCase().endsWith('.jpg') || clothingImageUrl.toLowerCase().endsWith('.jpeg')) {
        clothingSubtype = 'jpeg';
      } else if (clothingImageUrl.toLowerCase().endsWith('.webp')) {
        clothingSubtype = 'webp';
      } else {
        clothingSubtype = 'jpeg';
      }

      print(' Sending request to RapidAPI...');

      // Create multipart request to /try-on-file
      var request = http.MultipartRequest('POST', Uri.parse(_rapidApiUrl));

      // Headers
      request.headers.addAll({
        'x-rapidapi-host': _rapidApiHost,
        'x-rapidapi-key': _rapidApiKey,
      });

      // Files
      final avatarFile = File(modelImagePath);
      final avatarBytes = await avatarFile.readAsBytes();
      final lower = modelImagePath.toLowerCase();
      String avatarSubtype;
      if (lower.endsWith('.png')) {
        avatarSubtype = 'png';
      } else if (lower.endsWith('.webp')) {
        avatarSubtype = 'webp';
      } else {
        avatarSubtype = 'jpeg';
      }
      request.files.add(http.MultipartFile.fromBytes(
        'avatar_image',
        avatarBytes,
        filename: 'avatar.${avatarSubtype}',
        contentType: MediaType('image', avatarSubtype),
      ));

      request.files.add(http.MultipartFile.fromBytes(
        'clothing_image',
        clothingResp.bodyBytes,
        filename: 'clothing.${clothingSubtype}',
        contentType: MediaType('image', clothingSubtype),
      ));

      // Send
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      print(' Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final String fileName = 'rapidapi_tryon_${DateTime.now().millisecondsSinceEpoch}.png';
        final Directory tempDir = await getTemporaryDirectory();
        final String filePath = '${tempDir.path}/$fileName';
        final File outFile = File(filePath);
        await outFile.writeAsBytes(response.bodyBytes);
        print(' Saved result to: $filePath');
        return filePath;
      } else {
        print(' RapidAPI Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print(' RapidAPI call error: $e');
      return null;
    }
  }
}
