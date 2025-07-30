import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_service.dart';

class ImageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final ImagePicker _picker = ImagePicker();

  /// Pick image from gallery or camera
  static Future<XFile?> pickImage({required ImageSource source}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  /// Compress and resize image
  static Future<Uint8List?> compressImage(XFile imageFile) async {
    try {
      Uint8List imageBytes;

      if (kIsWeb) {
        imageBytes = await imageFile.readAsBytes();
      } else {
        imageBytes = await File(imageFile.path).readAsBytes();
      }

      // Decode image
      img.Image? image = img.decodeImage(imageBytes);
      if (image == null) return null;

      // Resize image to max 512x512 while maintaining aspect ratio
      img.Image resized = img.copyResize(
        image,
        width: image.width > image.height ? 512 : null,
        height: image.height > image.width ? 512 : null,
      );

      // Compress as JPEG with 80% quality
      List<int> compressedBytes = img.encodeJpg(resized, quality: 80);
      return Uint8List.fromList(compressedBytes);
    } catch (e) {
      print('Error compressing image: $e');
      return null;
    }
  }

  /// Upload profile photo to Firebase Storage
  static Future<String?> uploadProfilePhoto(XFile imageFile) async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      // Compress image
      final Uint8List? compressedImage = await compressImage(imageFile);
      if (compressedImage == null) {
        throw Exception('Failed to compress image');
      }

      // Create reference to storage location with unique filename
      final String fileName =
          'profile_${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref = _storage
          .ref()
          .child('profile_photos')
          .child(fileName);

      // Upload image with metadata
      final UploadTask uploadTask = ref.putData(
        compressedImage,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'userId': user.uid,
            'uploadedAt': DateTime.now().toIso8601String(),
            'originalName': imageFile.name,
          },
        ),
      );

      // Wait for upload to complete
      final TaskSnapshot snapshot = await uploadTask;

      // Verify upload was successful
      if (snapshot.state != TaskState.success) {
        throw Exception('Upload failed with state: ${snapshot.state}');
      }

      // Get download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      // Update user profile in Firestore
      await FirebaseService.updateUserProfile(user.uid, {
        'profilePhotoUrl': downloadUrl,
        'profilePhotoUpdatedAt': DateTime.now().toIso8601String(),
      });

      print('Profile photo uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Error uploading profile photo: $e');
      rethrow; // Re-throw to let caller handle the error
    }
  }

  /// Delete old profile photo from storage
  static Future<void> deleteOldProfilePhoto(String photoUrl) async {
    try {
      if (photoUrl.isEmpty) return;

      // Skip deletion for default avatar URLs
      if (photoUrl.contains('ui-avatars.com') ||
          photoUrl.contains('default') ||
          !photoUrl.contains('firebase')) {
        return;
      }

      // Extract file path from URL and delete
      final Reference ref = _storage.refFromURL(photoUrl);
      await ref.delete();
      print('Old profile photo deleted successfully');
    } catch (e) {
      print('Error deleting old profile photo: $e');
      // Don't throw error as this is not critical for user experience
      // The old file will remain in storage but won't affect functionality
    }
  }

  /// Update profile photo (handles deletion of old photo)
  static Future<String?> updateProfilePhoto(
    XFile imageFile,
    String? oldPhotoUrl,
  ) async {
    try {
      // First, upload the new photo
      final String? newPhotoUrl = await uploadProfilePhoto(imageFile);

      if (newPhotoUrl != null) {
        // Only delete old photo after successful upload
        if (oldPhotoUrl != null &&
            oldPhotoUrl.isNotEmpty &&
            !oldPhotoUrl.contains('ui-avatars.com')) {
          // Delete old photo in background (don't block the UI)
          deleteOldProfilePhoto(oldPhotoUrl).catchError((error) {
            print('Warning: Failed to delete old profile photo: $error');
            // Continue anyway - this is not critical
          });
        }
        return newPhotoUrl;
      } else {
        throw Exception('Failed to upload new profile photo');
      }
    } catch (e) {
      print('Error updating profile photo: $e');
      rethrow; // Re-throw to let the UI handle the error
    }
  }

  /// Get default avatar URL or generate initials-based avatar
  static String getDefaultAvatarUrl(String? displayName, String? phoneNumber) {
    // For now, return a placeholder. In a real app, you might use a service
    // like Gravatar or generate an avatar based on initials
    return 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(displayName ?? phoneNumber ?? 'User')}&background=1976D2&color=fff&size=200';
  }

  /// Check if URL is a valid image URL
  static bool isValidImageUrl(String? url) {
    if (url == null || url.isEmpty) return false;

    try {
      final Uri uri = Uri.parse(url);
      return uri.isAbsolute &&
          (url.contains('firebase') ||
              url.contains('ui-avatars') ||
              url.endsWith('.jpg') ||
              url.endsWith('.jpeg') ||
              url.endsWith('.png') ||
              url.endsWith('.webp'));
    } catch (e) {
      return false;
    }
  }
}
