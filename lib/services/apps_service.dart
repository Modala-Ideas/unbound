import 'package:device_apps/device_apps.dart';
import 'package:flutter/foundation.dart';

/// Service to fetch and manage installed apps
class AppsService {
  /// Get all installed apps (with launch intent)
  Future<List<Application>> getAllApps() async {
    try {
      List<Application> apps = await DeviceApps.getInstalledApplications(
        includeAppIcons: true,
        includeSystemApps: false,
        onlyAppsWithLaunchIntent: true,
      );
      
      // Sort alphabetically
      apps.sort((a, b) => a.appName.compareTo(b.appName));
      return apps;
    } catch (e) {
      debugPrint('Error fetching apps: $e');
      return [];
    }
  }

  /// Launch an app by package name
  Future<bool> launchApp(String packageName) async {
    try {
      bool launched = await DeviceApps.openApp(packageName);
      return launched;
    } catch (e) {
      debugPrint('Error launching app $packageName: $e');
      return false;
    }
  }

  /// Get app info for a specific package
  Future<Application?> getAppInfo(String packageName) async {
    try {
      Application? app = await DeviceApps.getApp(packageName, true);
      return app;
    } catch (e) {
      debugPrint('Error getting app info for $packageName: $e');
      return null;
    }
  }
}
