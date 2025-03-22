import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    kotlinOut:
        '../mobile_camera_controller_android/android/src/main/kotlin/com/dynamicelement/mobilecameracontroller/CameraApi.kt',
    dartOut: 'lib/src/channel/camera_api.pigeon.dart',
    swiftOut: '../mobile_camera_controller_ios/ios/Classes/CameraApi.swift',
  ),
)
@HostApi()
abstract class CameraApi {
  void dispose();

  @async
  void initialize();

  @async
  Uint8List takePicture();

  void setZoomLevel({required double zoomLevel});

  double getZoomLevel();

  void setFlashStatus({required bool isActive});

  bool getFlashStatus();
}
