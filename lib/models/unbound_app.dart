import 'dart:typed_data';
import 'package:flutter_device_apps/flutter_device_apps.dart';

class UnboundApp {
  final String appName;
  final String packageName;
  final Uint8List? iconBytes;
  final bool isWork;
  final AppInfo? originalAppInfo;

  UnboundApp({
    required this.appName,
    required this.packageName,
    this.iconBytes,
    this.isWork = false,
    this.originalAppInfo,
  });

  factory UnboundApp.fromAppInfo(AppInfo info) {
    // For now, skip icon extraction to avoid NoSuchMethodError
    // We'll display fallback icons until we find the correct approach
    return UnboundApp(
      appName: info.appName ?? 'Unknown',
      packageName: info.packageName ?? '',
      iconBytes: null, // TODO: Extract icons properly
      isWork: false,
      originalAppInfo: info,
    );
  }

  factory UnboundApp.fromMap(Map<dynamic, dynamic> map) {
    return UnboundApp(
      appName: map['appName'] as String? ?? 'Unknown',
      packageName: map['packageName'] as String? ?? '',
      iconBytes: map['icon'] as Uint8List?,
      isWork: map['isWork'] as bool? ?? false,
    );
  }
}
