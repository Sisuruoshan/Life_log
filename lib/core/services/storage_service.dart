import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';

class StorageService {
  /// Converts an image file to a base64 string for direct database storage
  Future<String?> uploadImage(File file, String userId, String folder) async {
    try {
      final bytes = await file.readAsBytes();
      final base64String = base64Encode(bytes);
      // Optional: Add prefix so the UI knows it's a base64 image
      return 'data:image/jpeg;base64,$base64String';
    } catch (e) {
      debugPrint('Error encoding image to base64: $e');
      return null;
    }
  }

  Future<void> deleteImage(String imageUrl) async {
    // No-op for base64 images since they are deleted when the document is deleted
  }
}
