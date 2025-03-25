import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'native_camera_controller_android_platform_interface.dart';

/// An implementation of [NativeCameraControllerAndroidPlatform] that uses method channels.
class MethodChannelNativeCameraControllerAndroid extends NativeCameraControllerAndroidPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('native_camera_controller_android');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
