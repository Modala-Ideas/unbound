import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage wallpaper settings
class WallpaperService {
  final ImagePicker _picker = ImagePicker();
  static const platform = MethodChannel('com.modalaideas.unbound/launcher');
  static const String _wallpaperPathKey = 'wallpaper_path';

  /// Set wallpaper from gallery
  Future<bool> setWallpaperFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return false;

      return await _setWallpaper(image.path);
    } catch (e) {
      debugPrint('Error setting wallpaper from gallery: $e');
      return false;
    }
  }

  /// Set wallpaper from camera
  Future<bool> setWallpaperFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image == null) return false;

      return await _setWallpaper(image.path);
    } catch (e) {
      debugPrint('Error setting wallpaper from camera: $e');
      return false;
    }
  }

  /// Internal method to set wallpaper
  Future<bool> _setWallpaper(String imagePath) async {
    try {
      debugPrint('Setting wallpaper from path: $imagePath');

      // Save wallpaper path to preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_wallpaperPathKey, imagePath);

      // Call native method to set wallpaper
      try {
        final result = await platform.invokeMethod('setWallpaper', {
          'path': imagePath,
        });
        debugPrint('Wallpaper set result: $result');
        return result == true;
      } on PlatformException catch (e) {
        debugPrint(
          'PlatformException setting wallpaper: ${e.code} - ${e.message}',
        );
        return false;
      }
    } catch (e) {
      debugPrint('Error setting wallpaper: $e');
      return false;
    }
  }

  /// Clear wallpaper (reset to system default)
  Future<bool> clearWallpaper() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_wallpaperPathKey);

      // Call native method to clear wallpaper
      try {
        final result = await platform.invokeMethod('clearWallpaper');
        debugPrint('Wallpaper cleared: $result');
        return result == true;
      } on PlatformException catch (e) {
        debugPrint(
          'PlatformException clearing wallpaper: ${e.code} - ${e.message}',
        );
        return false;
      }
    } catch (e) {
      debugPrint('Error clearing wallpaper: $e');
      return false;
    }
  }

  /// Get current wallpaper path
  Future<String?> getCurrentWallpaperPath() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_wallpaperPathKey);
    } catch (e) {
      debugPrint('Error getting wallpaper path: $e');
      return null;
    }
  }
}
