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
    swiftOut: '../native_camera_controller_ios/ios/Classes/CameraApiInterface.swift',
  ),
)
enum FlashState {
  /// Flash state disabled
  disabled,

  /// Flash state enabled
  enabled
}

@HostApi()
abstract class CameraApi {

  void dispose();

  @async
  void initialize(FlashState flashState,
      double flashTorchLevel,);

  @async
  Uint8List takePicture();

  void setZoomLevel({required double zoomLevel});

  double getCurrentZoomLevel();

  double getMinimumZoomLevel();

  double getMaximumZoomLevel();

  void setFlashStatus({required bool isActive});

  bool getFlashStatus();

  String getPlatformVersion();
}

@FlutterApi()
abstract class CameraImageListener {
  void onImageAvailable(Uint8List image);

  void onQrCodeAvailable(String? qrCode);
}
