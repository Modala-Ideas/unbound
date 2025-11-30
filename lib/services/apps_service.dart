import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_device_apps/flutter_device_apps.dart';

/// Service to fetch and manage installed apps
class AppsService {
  static List<AppInfo>? _cachedApps;
  static List<AppInfo>? get cachedApps => _cachedApps;
  static const platform = MethodChannel('com.modalaideas.unbound/launcher');

  /// Get all installed apps (with launch intent)
  Future<List<AppInfo>> getAllApps({bool forceRefresh = false}) async {
    if (_cachedApps != null && !forceRefresh) {
      return _cachedApps!;
    }

    try {
      List<AppInfo> apps = await FlutterDeviceApps.listApps(
        includeIcons: true,
        includeSystem: true,
        onlyLaunchable: true,
      );

      // Sort alphabetically
      apps.sort((a, b) => (a.appName ?? '').compareTo(b.appName ?? ''));
      _cachedApps = apps;
      return apps;
    } catch (e) {
      debugPrint('Error fetching apps: $e');
      return [];
    }
  }

  /// Get work profile apps
  Future<List<Map<String, dynamic>>> getWorkApps() async {
    try {
      final List<dynamic>? workAppsRaw = await platform.invokeListMethod(
        'getWorkApps',
      );
      if (workAppsRaw != null) {
        return workAppsRaw
            .map((app) => Map<String, dynamic>.from(app as Map))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching work apps: $e');
      return [];
    }
  }

  /// Launch an app by package name
  Future<bool> launchApp(String packageName) async {
    try {
      bool launched = await FlutterDeviceApps.openApp(packageName);
      return launched;
    } catch (e) {
      debugPrint('Error launching app $packageName: $e');
      return false;
    }
  }

  /// Get app info for a specific package
  Future<AppInfo?> getAppInfo(String packageName) async {
    try {
      AppInfo? app = await FlutterDeviceApps.getApp(
        packageName,
        includeIcon: true,
      );
      return app;
    } catch (e) {
      debugPrint('Error getting app info for $packageName: $e');
      return null;
    }
  }
}
