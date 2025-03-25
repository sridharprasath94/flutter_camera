import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'native_camera_controller_android_method_channel.dart';

abstract class NativeCameraControllerAndroidPlatform extends PlatformInterface {
  /// Constructs a NativeCameraControllerAndroidPlatform.
  NativeCameraControllerAndroidPlatform() : super(token: _token);

  static final Object _token = Object();

  static NativeCameraControllerAndroidPlatform _instance = MethodChannelNativeCameraControllerAndroid();

  /// The default instance of [NativeCameraControllerAndroidPlatform] to use.
  ///
  /// Defaults to [MethodChannelNativeCameraControllerAndroid].
  static NativeCameraControllerAndroidPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [NativeCameraControllerAndroidPlatform] when
  /// they register themselves.
  static set instance(NativeCameraControllerAndroidPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
