import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'mobile_camera_method_channel.dart';

abstract class MobileCameraPlatform extends PlatformInterface {
  /// Constructs a MobileCameraPlatform.
  MobileCameraPlatform() : super(token: _token);

  static final Object _token = Object();

  static MobileCameraPlatform _instance = MethodChannelMobileCamera();

  /// The default instance of [MobileCameraPlatform] to use.
  ///
  /// Defaults to [MethodChannelMobileCamera].
  static MobileCameraPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [MobileCameraPlatform] when
  /// they register themselves.
  static set instance(MobileCameraPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
