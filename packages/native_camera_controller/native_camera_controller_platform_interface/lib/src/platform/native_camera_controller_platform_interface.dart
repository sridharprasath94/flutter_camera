import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:native_camera_controller_platform_interface/src/channel/camera_api.pigeon.dart';
import 'package:native_camera_controller_platform_interface/src/channel/method_channel_native_camera_controller.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// The interface that implementations of native_camera_controller
///  must implement.
///
/// Platform implementations should extend this class
/// rather than implement it as `NativeCameraController`.
/// Extending this class (using `extends`) ensures that the subclass will get
/// the default implementation, while platform implementations that `implements`
///  this interface will be broken by newly
///  added [NativeCameraControllerPlatform] methods.
abstract class NativeCameraControllerPlatform extends PlatformInterface {
  /// Constructs a NativeCameraControllerPlatform.
  NativeCameraControllerPlatform() : super(token: _token);

  static final Object _token = Object();

  static NativeCameraControllerPlatform _instance =
      MethodChannelNativeCameraController();

  /// The default instance of [NativeCameraControllerPlatform] to use.
  ///
  /// Defaults to [MethodChannelNativeCameraController].
  static NativeCameraControllerPlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [NativeCameraControllerPlatform] when
  ///  they register themselves.
  static set instance(NativeCameraControllerPlatform instance) {
    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }

  final _cameraApi = CameraApi();


  /// Return the current platform version.
  Future<String?> getPlatformVersion();

  /// Returns the platform specific widget
  Widget getCameraView();

  /// Dispose of the camera controller.
  Future<void> dispose() => _cameraApi.dispose();

  /// Initialize the camera controller.
  Future<bool> getFlashStatus() => _cameraApi.getFlashStatus();

  /// Get the current zoom level.
  Future<double> getCurrentZoomLevel() => _cameraApi.getCurrentZoomLevel();

  /// Get the minimum zoom level.
  Future<double> getMinimumZoomLevel() => _cameraApi.getMinimumZoomLevel();

  /// Get the maximum zoom level.
  Future<double> getMaximumZoomLevel() => _cameraApi.getMaximumZoomLevel();

  /// Set the flash status.
  Future<void> initialize(
    FlashState flashState,
    double flashTorchLevel,
  ) =>
      _cameraApi.initialize(
        flashState,
        flashTorchLevel,
      );

  /// Get the flash status.
  Future<void> setFlashStatus({required bool isActive}) =>
      _cameraApi.setFlashStatus(isActive: isActive);

  /// Set the zoom level.
  Future<void> setZoomLevel({required double zoomLevel}) =>
      _cameraApi.setZoomLevel(zoomLevel: zoomLevel);

  /// Get the zoom level.
  Future<Uint8List?> takePicture() => _cameraApi.takePicture();
}
