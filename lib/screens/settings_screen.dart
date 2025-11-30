import 'package:flutter/material.dart';
import 'package:unbound/services/wallpaper_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final WallpaperService _wallpaperService = WallpaperService();
  bool _isLoading = false;

  Future<void> _setWallpaperFromGallery() async {
    setState(() => _isLoading = true);
    final success = await _wallpaperService.setWallpaperFromGallery();
    if (mounted) {
      setState(() => _isLoading = false);
      _showMessage(
        success ? 'Wallpaper set successfully!' : 'Failed to set wallpaper',
      );
    }
  }

  Future<void> _setWallpaperFromCamera() async {
    setState(() => _isLoading = true);
    final success = await _wallpaperService.setWallpaperFromCamera();
    if (mounted) {
      setState(() => _isLoading = false);
      _showMessage(
        success ? 'Wallpaper set successfully!' : 'Failed to set wallpaper',
      );
    }
  }

  Future<void> _clearWallpaper() async {
    setState(() => _isLoading = true);
    final success = await _wallpaperService.clearWallpaper();
    if (mounted) {
      setState(() => _isLoading = false);
      _showMessage(
        success ? 'Wallpaper reset to default' : 'Failed to reset wallpaper',
      );
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.black)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.white.withOpacity(0.9),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Wallpaper Section
                const Text(
                  'Wallpaper',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                _buildSettingsTile(
                  icon: Icons.photo_library,
                  title: 'Set from Gallery',
                  subtitle: 'Choose an image from your gallery',
                  onTap: _setWallpaperFromGallery,
                ),

                const SizedBox(height: 12),

                _buildSettingsTile(
                  icon: Icons.camera_alt,
                  title: 'Take Photo',
                  subtitle: 'Capture a new photo for wallpaper',
                  onTap: _setWallpaperFromCamera,
                ),

                const SizedBox(height: 12),

                _buildSettingsTile(
                  icon: Icons.restore,
                  title: 'Reset to Default',
                  subtitle: 'Clear custom wallpaper',
                  onTap: _clearWallpaper,
                  iconColor: Colors.orange,
                ),
              ],
            ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color iconColor = Colors.white,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }
}
