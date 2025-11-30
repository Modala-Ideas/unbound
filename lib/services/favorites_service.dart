import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage favorite apps
class FavoritesService {
  static const String _favoritesKey = 'favorite_apps';
  static const int maxFavorites = 5;

  /// Get list of favorite app package names
  Future<List<String>> getFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = prefs.getStringList(_favoritesKey) ?? [];
      debugPrint('Loaded ${favorites.length} favorites');
      return favorites;
    } catch (e) {
      debugPrint('Error loading favorites: $e');
      return [];
    }
  }

  /// Add an app to favorites
  Future<bool> addFavorite(String packageName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = prefs.getStringList(_favoritesKey) ?? [];

      if (favorites.contains(packageName)) {
        debugPrint('App already in favorites: $packageName');
        return false;
      }

      if (favorites.length >= maxFavorites) {
        debugPrint('Favorites full (max $maxFavorites)');
        return false;
      }

      favorites.add(packageName);
      await prefs.setStringList(_favoritesKey, favorites);
      debugPrint('Added to favorites: $packageName');
      return true;
    } catch (e) {
      debugPrint('Error adding favorite: $e');
      return false;
    }
  }

  /// Remove an app from favorites
  Future<bool> removeFavorite(String packageName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = prefs.getStringList(_favoritesKey) ?? [];

      if (!favorites.contains(packageName)) {
        debugPrint('App not in favorites: $packageName');
        return false;
      }

      favorites.remove(packageName);
      await prefs.setStringList(_favoritesKey, favorites);
      debugPrint('Removed from favorites: $packageName');
      return true;
    } catch (e) {
      debugPrint('Error removing favorite: $e');
      return false;
    }
  }

  /// Check if an app is in favorites
  Future<bool> isFavorite(String packageName) async {
    try {
      final favorites = await getFavorites();
      return favorites.contains(packageName);
    } catch (e) {
      debugPrint('Error checking favorite: $e');
      return false;
    }
  }

  /// Clear all favorites
  Future<bool> clearFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_favoritesKey);
      debugPrint('Cleared all favorites');
      return true;
    } catch (e) {
      debugPrint('Error clearing favorites: $e');
      return false;
    }
  }
}
