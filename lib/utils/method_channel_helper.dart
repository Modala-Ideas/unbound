import 'package:flutter/services.dart';

/// Helper class for platform-specific method channel calls
class MethodChannelHelper {
  static const MethodChannel _channel = MethodChannel('com.modalaideas.unbound/launcher');

  /// Expand the system notifications panel
  static Future<bool> expandNotificationsPanel() async {
    try {
      final bool? result = await _channel.invokeMethod('expandNotificationsPanel');
      return result ?? false;
    } on PlatformException catch (e) {
      print("Failed to expand notifications panel: '${e.message}'");
      return false;
    }
  }
}
