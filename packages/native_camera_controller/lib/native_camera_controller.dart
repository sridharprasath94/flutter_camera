import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:native_camera_controller_android/native_camera_controller_android.dart';
import 'package:native_camera_controller_ios/native_camera_controller_ios.dart';
import 'package:native_camera_controller_platform_interface/native_camera_controller_platform_interface.dart';

/// The status of the flash.
enum FlashStatus {
  /// The flash is on.
  on,

  /// The flash is off.
  off,
}

/// Camera parameters like zoom level, min zoom level, max zoom level,
/// and flash status.
class CameraParameters {
  /// Camera parameters like zoom level, min zoom level, max zoom level,
  /// and flash status.
  CameraParameters({
    required this.currentZoomLevel,
    required this.minZoomLevel,
    required this.maxZoomLevel,
    required this.flashStatus,
  });

  /// The current zoom level.
  final double currentZoomLevel;

  /// The minimum zoom level.
  final double minZoomLevel;

  /// The maximum zoom level.
  final double maxZoomLevel;

  /// The flash status.
  final FlashStatus flashStatus;
}

NativeCameraControllerPlatform get _platform =>
    Platform.isAndroid
        ? NativeCameraControllerAndroid()
        : NativeCameraControllerIOS();

/// A controller for the mobile camera.
class NativeCameraController {
  bool _isDisposed = false;
  final CameraImageListenerWrapper _cameraImageListenerWrapper =
      CameraImageListenerWrapper();
  StreamSubscription<Uint8List>? _imageSubscription;
  StreamSubscription<String?>? _qrCodeSubscription;

  /// The [Stream] of the camera image
  Stream<Uint8List> get imageStream => _cameraImageListenerWrapper.imageStream;

  /// The [Stream] of the QR code
  Stream<String?> get qrCodeStream => _cameraImageListenerWrapper.qrCodeStream;

  /// Returns the name of the current platform.
  Future<String?> getPlatformVersion() => _platform.getPlatformVersion();

  /// Returns the camera view.
  Widget getCameraView() => _platform.getCameraView();

  /// Takes a picture.
  Future<Uint8List?> takePicture() => _platform.takePicture();

  /// Dispose of the camera controller.
  Future<void> dispose() async {
    if (_isDisposed) {
      return;
    }
    _isDisposed = true;
    await _imageSubscription?.cancel();
    await _qrCodeSubscription?.cancel();
    await _cameraImageListenerWrapper.dispose();
    await _platform.dispose();
  }

  /// Initialize the camera controller.
  Future<CameraParameters> initialize(
    final FlashStatus flashStatus, {
    final double flashLevel = 1,
    final bool listenForImages = false,
  }) async {
    try {
      await _platform.initialize(
        flashStatus == FlashStatus.on
            ? FlashState.enabled
            : FlashState.disabled,
        flashLevel,
      );
      if(listenForImages) {
        _setUpListener();
      }
      return CameraParameters(
        currentZoomLevel: await _platform.getCurrentZoomLevel(),
        minZoomLevel: await _platform.getMinimumZoomLevel(),
        maxZoomLevel: await _platform.getMaximumZoomLevel(),
        flashStatus:
            (await _platform.getFlashStatus())
                ? FlashStatus.on
                : FlashStatus.off,
      );
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      rethrow;
    }
  }

  /// Set the flash status.
  Future<void> setFlashStatus({required final bool isActive}) =>
      _platform.setFlashStatus(isActive: isActive);

  /// Get the flash status.
  Future<bool> getFlashStatus() => _platform.getFlashStatus();

  /// Set the zoom level.
  Future<void> setZoomLevel({required final double zoomLevel}) =>
      _platform.setZoomLevel(zoomLevel: zoomLevel);

  /// Get the zoom level.
  Future<double> getCurrentZoomLevel() => _platform.getCurrentZoomLevel();

  /// Get the maximum zoom level.
  Future<double> getMaxZoomLevel() => _platform.getMaximumZoomLevel();

  /// Get the minimum zoom level.
  Future<double> getMinZoomLevel() => _platform.getMinimumZoomLevel();

  /// Sets up the listener for the camera image and QR code.
  void _setUpListener() {
    CameraImageListenerWrapper.setUp(_cameraImageListenerWrapper);
    _imageSubscription = _cameraImageListenerWrapper.imageStream.listen((
      final Uint8List image,
    ) {
      debugPrint('Image received: ${image.length}');
    });

    _qrCodeSubscription = _cameraImageListenerWrapper.qrCodeStream.listen((
      final String? qrCode,
    ) {
      debugPrint('QR Code received: $qrCode');
    });
  }
}
