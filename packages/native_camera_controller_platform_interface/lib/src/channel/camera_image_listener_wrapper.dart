import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:native_camera_controller_platform_interface/native_camera_controller_platform_interface.dart';

/// A wrapper for the [CameraImageListener] that provides [Stream]s
class CameraImageListenerWrapper implements CameraImageListener {
  final StreamController<Uint8List> _imageStreamController =
      StreamController<Uint8List>.broadcast();
  final StreamController<String?> _qrCodeStreamController =
      StreamController<String?>.broadcast();

  /// The [Stream] of the camera image
  Stream<Uint8List> get imageStream => _imageStreamController.stream;

  /// The [Stream] of the QR code
  Stream<String?> get qrCodeStream => _qrCodeStreamController.stream;

  @override
  void onImageAvailable(final Uint8List image) {
    _imageStreamController.add(image);
  }

  @override
  void onQrCodeAvailable(final String? qrCode) {
    _qrCodeStreamController.add(qrCode);
  }

  /// Disposes the [StreamController]s
  Future<void> dispose() async {
    await _imageStreamController.close();
    await _qrCodeStreamController.close();
    debugPrint('CameraImageListenerWrapper disposed');
  }

  /// Sets up the [CameraImageListenerWrapper] with the [CameraImageListener]
  static void setUp(final CameraImageListenerWrapper listener) {
    CameraImageListener.setUp(listener);
  }
}
