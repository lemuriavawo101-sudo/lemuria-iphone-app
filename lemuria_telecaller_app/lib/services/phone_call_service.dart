import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class PhoneCallService {
  static const MethodChannel _channel = MethodChannel('com.lemuria.telecaller/call');

  /// Places a real SIM phone call directly
  static Future<bool> makeDirectCall(String phoneNumber) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleanPhone.isEmpty) return false;

    // 1. Android Native Direct Call (ACTION_CALL)
    if (!kIsWeb && Platform.isAndroid) {
      try {
        final status = await Permission.phone.request();
        if (status.isGranted) {
          final bool? success = await _channel.invokeMethod<bool>('directCall', {
            'phoneNumber': cleanPhone,
          });
          if (success == true) return true;
        }
      } catch (e) {
        debugPrint('Android direct call channel error: $e');
      }
    }

    // 2. iPhone (iOS) & Web Telephony Trigger
    try {
      final uri = Uri(scheme: 'tel', path: cleanPhone);
      return await launchUrl(
        uri,
        mode: LaunchMode.platformDefault,
      );
    } catch (e) {
      debugPrint('LaunchUrl tel: failed: $e');
    }
    return false;
  }
}
