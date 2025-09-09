import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class SampleClothesGenerator {
  /// Generate sample clothing images programmatically
  static Future<void> generateSampleClothes() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final clothesDir = Directory('${directory.path}/sample_clothes');
      
      if (!await clothesDir.exists()) {
        await clothesDir.create(recursive: true);
      }

      // Generate dress image
      await _generateDressImage('${clothesDir.path}/brown_dress.png', const Color(0xFF8B7355));
      await _generateTShirtImage('${clothesDir.path}/orange_tshirt.png', const Color(0xFFE8A87C));
      await _generateTShirtImage('${clothesDir.path}/dark_tshirt.png', const Color(0xFF2D3748));
      
      print('Sample clothes generated successfully!');
    } catch (e) {
      print('Error generating sample clothes: $e');
    }
  }

  static Future<void> _generateDressImage(String path, Color color) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = const Size(200, 300);

    // Draw dress shape
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    // Draw shadow
    final shadowPath = Path();
    shadowPath.moveTo(50, 50);
    shadowPath.quadraticBezierTo(100, 30, 150, 50);
    shadowPath.lineTo(160, 280);
    shadowPath.quadraticBezierTo(100, 300, 40, 280);
    shadowPath.close();
    
    canvas.drawPath(shadowPath, shadowPaint);

    // Draw main dress
    final dressPath = Path();
    dressPath.moveTo(45, 45);
    dressPath.quadraticBezierTo(100, 25, 155, 45);
    dressPath.lineTo(165, 275);
    dressPath.quadraticBezierTo(100, 295, 35, 275);
    dressPath.close();
    
    canvas.drawPath(dressPath, paint);

    // Add highlights
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(const Offset(80, 100), 15, highlightPaint);
    canvas.drawCircle(const Offset(120, 150), 10, highlightPaint);

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.width.toInt(), size.height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    
    if (byteData != null) {
      final file = File(path);
      await file.writeAsBytes(byteData.buffer.asUint8List());
    }
  }

  static Future<void> _generateTShirtImage(String path, Color color) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = const Size(200, 200);

    // Draw t-shirt shape
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    // Draw shadow
    final shadowPath = Path();
    shadowPath.moveTo(40, 50);
    shadowPath.lineTo(30, 70);
    shadowPath.lineTo(50, 80);
    shadowPath.lineTo(50, 180);
    shadowPath.lineTo(150, 180);
    shadowPath.lineTo(150, 80);
    shadowPath.lineTo(170, 70);
    shadowPath.lineTo(160, 50);
    shadowPath.lineTo(140, 60);
    shadowPath.lineTo(60, 60);
    shadowPath.close();
    
    canvas.drawPath(shadowPath, shadowPaint);

    // Draw main t-shirt
    final tshirtPath = Path();
    tshirtPath.moveTo(35, 45);
    tshirtPath.lineTo(25, 65);
    tshirtPath.lineTo(45, 75);
    tshirtPath.lineTo(45, 175);
    tshirtPath.lineTo(155, 175);
    tshirtPath.lineTo(155, 75);
    tshirtPath.lineTo(175, 65);
    tshirtPath.lineTo(165, 45);
    tshirtPath.lineTo(145, 55);
    tshirtPath.lineTo(55, 55);
    tshirtPath.close();
    
    canvas.drawPath(tshirtPath, paint);

    // Add neckline
    final neckPaint = Paint()
      ..color = color.withOpacity(0.7)
      ..style = PaintingStyle.fill;
    
    final neckPath = Path();
    neckPath.moveTo(85, 55);
    neckPath.quadraticBezierTo(100, 45, 115, 55);
    neckPath.quadraticBezierTo(100, 70, 85, 55);
    
    canvas.drawPath(neckPath, neckPaint);

    // Add highlights
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(const Offset(70, 100), 8, highlightPaint);

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.width.toInt(), size.height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    
    if (byteData != null) {
      final file = File(path);
      await file.writeAsBytes(byteData.buffer.asUint8List());
    }
  }
}
