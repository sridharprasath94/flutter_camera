import 'package:flutter/widgets.dart';
import 'package:native_camera_controller_platform_interface/src/platform/native_camera_controller_platform_interface.dart';

/// An implementation of [NativeCameraControllerPlatform] that uses
/// method channels.
class MethodChannelNativeCameraController
    extends NativeCameraControllerPlatform {
  @override
  Widget getCameraView() {
    throw UnimplementedError();
  }

  @override
  Future<String?> getPlatformVersion() {
    throw UnimplementedError();
  }
}
