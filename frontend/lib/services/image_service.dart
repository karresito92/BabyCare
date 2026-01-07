import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ImageService {
  final ImagePicker _picker = ImagePicker();

  Future<String?> pickImageAsBase64() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image == null) return null;

      // Para web, usar readAsBytes directamente
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);
      
      // Retornar con prefijo data URL
      return 'data:image/jpeg;base64,$base64Image';
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  Future<String?> takePhotoAsBase64() async {
    try {
      // En web, la cámara no está disponible, usar galería
      if (kIsWeb) {
        return await pickImageAsBase64();
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image == null) return null;

      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);
      
      return 'data:image/jpeg;base64,$base64Image';
    } catch (e) {
      print('Error taking photo: $e');
      return null;
    }
  }
}