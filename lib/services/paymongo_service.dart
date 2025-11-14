import 'dart:convert';
import 'package:http/http.dart' as http;

class PayMongoService {
  // Get your API keys from https://dashboard.paymongo.com/developers
  // Using TEST keys for development - switch to LIVE keys for production
  static const String _secretKey = 'sk_test_Bg62CmbsnJvQHddA5nhMA3Ku'; // Test secret key
  static const String _publicKey = 'pk_test_PeUDz5VpJk3a47QHjv8uvreB'; // Test public key
  static const String _baseUrl = 'https://api.paymongo.com/v1';

  /// Creates a PayMongo source for GCash or GrabPay
  /// [amount] should be in centavos (e.g., 10000 = PHP 100.00)
  /// [type] should be 'gcash' or 'grab_pay'
  Future<Map<String, dynamic>?> createSource({
    required int amount,
    required String type,
    required String description,
    Map<String, dynamic>? billing,
  }) async {
    try {
      final credentials = base64Encode(utf8.encode('$_secretKey:'));
      
      final response = await http.post(
        Uri.parse('$_baseUrl/sources'),
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'data': {
            'attributes': {
              'amount': amount,
              'redirect': {
                'success': 'https://your-app.com/payment/success',
                'failed': 'https://your-app.com/payment/failed',
              },
              'type': type,
              'currency': 'PHP',
              'description': description,
              if (billing != null) 'billing': billing,
            }
          }
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['data'];
      } else {
        print('PayMongo Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('PayMongo Exception: $e');
      return null;
    }
  }

  /// Creates a payment intent for direct bank transfer
  /// [amount] should be in centavos (e.g., 10000 = PHP 100.00)
  Future<Map<String, dynamic>?> createPaymentIntent({
    required int amount,
    required String description,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final credentials = base64Encode(utf8.encode('$_secretKey:'));
      
      final response = await http.post(
        Uri.parse('$_baseUrl/payment_intents'),
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'data': {
            'attributes': {
              'amount': amount,
              'payment_method_allowed': [
                'card',
                'paymaya',
                'gcash',
                'grab_pay',
              ],
              'payment_method_options': {
                'card': {'request_three_d_secure': 'any'}
              },
              'currency': 'PHP',
              'description': description,
              'statement_descriptor': 'PREMODA',
              if (metadata != null) 'metadata': metadata,
            }
          }
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['data'];
      } else {
        print('PayMongo Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('PayMongo Exception: $e');
      return null;
    }
  }

  /// Creates a payment method for attaching to payment intent
  Future<Map<String, dynamic>?> createPaymentMethod({
    required String type,
    Map<String, dynamic>? details,
  }) async {
    try {
      final credentials = base64Encode(utf8.encode('$_publicKey:'));
      
      final response = await http.post(
        Uri.parse('$_baseUrl/payment_methods'),
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'data': {
            'attributes': {
              'type': type,
              if (details != null) 'details': details,
            }
          }
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['data'];
      } else {
        print('PayMongo Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('PayMongo Exception: $e');
      return null;
    }
  }

  /// Attaches a payment method to a payment intent
  Future<Map<String, dynamic>?> attachPaymentIntent({
    required String paymentIntentId,
    required String paymentMethodId,
    String? clientKey,
  }) async {
    try {
      final credentials = base64Encode(utf8.encode('$_secretKey:'));
      
      final response = await http.post(
        Uri.parse('$_baseUrl/payment_intents/$paymentIntentId/attach'),
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'data': {
            'attributes': {
              'payment_method': paymentMethodId,
              if (clientKey != null) 'client_key': clientKey,
            }
          }
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['data'];
      } else {
        print('PayMongo Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('PayMongo Exception: $e');
      return null;
    }
  }

  /// Retrieves payment intent status
  Future<Map<String, dynamic>?> getPaymentIntent(String paymentIntentId) async {
    try {
      final credentials = base64Encode(utf8.encode('$_secretKey:'));
      
      final response = await http.get(
        Uri.parse('$_baseUrl/payment_intents/$paymentIntentId'),
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      } else {
        print('PayMongo Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('PayMongo Exception: $e');
      return null;
    }
  }

  /// Retrieves source status
  Future<Map<String, dynamic>?> getSource(String sourceId) async {
    try {
      final credentials = base64Encode(utf8.encode('$_secretKey:'));
      
      final response = await http.get(
        Uri.parse('$_baseUrl/sources/$sourceId'),
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      } else {
        print('PayMongo Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('PayMongo Exception: $e');
      return null;
    }
  }

  /// Convert amount from PHP to centavos
  static int convertToCentavos(double amount) {
    return (amount * 100).round();
  }

  /// Convert amount from centavos to PHP
  static double convertToPhp(int centavos) {
    return centavos / 100;
  }
}
