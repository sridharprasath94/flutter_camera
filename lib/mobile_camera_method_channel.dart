import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'mobile_camera_platform_interface.dart';

/// An implementation of [MobileCameraPlatform] that uses method channels.
class MethodChannelMobileCamera extends MobileCameraPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('mobile_camera');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
