import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:native_camera_controller_platform_interface/native_camera_controller_platform_interface.dart';

/// The status of the flash.
enum FlashStatus {
  /// The flash is on.
  on,

  /// The flash is off.
  off,
}

NativeCameraControllerPlatform get _platform =>
    NativeCameraControllerPlatform.instance;

/// A controller for the mobile camera.
class MobileCameraController {
  /// Returns the name of the current platform.
  Future<String> getPlatformName() => getPlatformName();

  /// Returns the camera view.
  Widget getCameraView() => _platform.getCameraView();

  /// Takes a picture.
  Future<Uint8List?> takePicture() => _platform.takePicture();

  /// Dispose of the camera controller.
  Future<void> dispose() => _platform.dispose();

  /// Initialize the camera controller.
  Future<void> initialize(FlashStatus flashStatus, {double flashLevel = 1}) =>
      _platform.initialize(
        flashStatus == FlashStatus.on
            ? FlashState.enabled
            : FlashState.disabled,
        flashLevel,
      );

  /// Set the flash status.
  Future<void> setFlashStatus({required bool isActive}) =>
      _platform.setFlashStatus(isActive: isActive);

  /// Get the flash status.
  Future<bool> getFlashStatus() => _platform.getFlashStatus();

  /// Set the zoom level.
  Future<void> setZoomLevel({required double zoomLevel}) =>
      _platform.setZoomLevel(zoomLevel: zoomLevel);

  /// Get the zoom level.
  Future<double> getCurrentZoomLevel() => _platform.getCurrentZoomLevel();

  /// Get the maximum zoom level.
  Future<double> getMaxZoomLevel() => _platform.getMaximumZoomLevel();

  /// Get the minimum zoom level.
  Future<double> getMinZoomLevel() => _platform.getMinimumZoomLevel();

  /// Set the image listener.
  void setUpImageListener(CameraImageListener listener) {
    CameraImageListener.setUp(listener);
  }
}
