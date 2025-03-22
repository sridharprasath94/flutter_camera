import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    javaOut:
    '../native_camera_controller_android/android/src/main/java/com/flashandroid/camera/CameraApi.java',
    javaOptions: JavaOptions(
      package: 'com.flashandroid.camera',
      useGeneratedAnnotation: false,
    ),
    dartOut: 'lib/src/channel/camera_api.pigeon.dart',
    swiftOut: '../native_camera_controller_ios/ios/Classes/CameraApi.swift',
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

  double getZoomLevel();

  void setFlashStatus({required bool isActive});

  bool getFlashStatus();
}

@FlutterApi()
abstract class CameraImageListener {
  void onImageAvailable(Uint8List image);

  void onQrCodeAvailable(String qrCode);
}
