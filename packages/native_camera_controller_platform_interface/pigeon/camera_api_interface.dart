import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    javaOut:
        '../native_camera_controller_android/android/src/main/java/com/flashandroid/native_camera_controller_android/CameraApiInterface.java',
    javaOptions: JavaOptions(
      package: 'com.flashandroid.native_camera_controller_android',
      useGeneratedAnnotation: false,
    ),
    dartOut: 'lib/src/channel/camera_api_interface.pigeon.dart',
    swiftOut:
        '../native_camera_controller_ios/ios/Classes/CameraApiInterface.swift',
  ),
)
enum FlashState {
  /// Flash state disabled
  disabled,

  /// Flash state enabled
  enabled
}

enum CameraType {
  /// Camera mode for preview
  cameraPreview,

  /// Camera mode for capture
  cameraCapture,

  /// Camera mode for barcode scan
  cameraBarcodeScan,
}

enum CameraRatio {
  /// Ratio 3:4
  ratio3X4,

  /// Ratio 1:1
  ratio1X1,
}

@HostApi()
abstract class CameraApi {
  void dispose();

  @async
  void initialize(
    final CameraType cameraType,
    final CameraRatio cameraRatio,
    final FlashState flashState,
    final double flashTorchLevel,
  );

  @async
  Uint8List takePicture();

  void setZoomLevel({required final double zoomLevel});

  double getCurrentZoomLevel();

  double getMinimumZoomLevel();

  double getMaximumZoomLevel();

  void setFlashStatus({required final bool isActive});

  bool getFlashStatus();

  String getPlatformVersion();
}

@FlutterApi()
abstract class CameraImageListener {
  void onImageAvailable(final Uint8List image);
}

@FlutterApi()
abstract class QRCodeListener {
  void onQrCodeAvailable(final String? qrCode);
}
