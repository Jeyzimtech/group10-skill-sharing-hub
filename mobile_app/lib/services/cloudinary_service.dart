import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/foundation.dart';

class CloudinaryService {
  static final CloudinaryService _instance = CloudinaryService._internal();
  factory CloudinaryService() => _instance;
  CloudinaryService._internal();

  final CloudinaryPublic _cloudinary = CloudinaryPublic(
    'dgdmw0fu7', // Cloud name from user
    'Skills-hub', // Updated upload preset
    cache: false,
  );


  /// Uploads an image file to Cloudinary and returns the secure URL.
  Future<String?> uploadImage(File imageFile) async {
    try {
      CloudinaryResponse response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          folder: 'profile_pictures',
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      return response.secureUrl;
    } catch (e) {
      debugPrint('Cloudinary upload error: $e');
      return null;
    }
  }

  /// Uploads an image from bytes (useful for web if needed, though this is a mobile app)
  Future<String?> uploadImageBytes(Uint8List bytes, String fileName) async {
    try {
      CloudinaryResponse response = await _cloudinary.uploadFile(
        CloudinaryFile.fromByteData(
          bytes.buffer.asByteData(),
          identifier: fileName,
          folder: 'profile_pictures',
          resourceType: CloudinaryResourceType.Image,
        ),

      );
      return response.secureUrl;
    } catch (e) {
      debugPrint('Cloudinary upload error: $e');
      return null;
    }
  }
}
