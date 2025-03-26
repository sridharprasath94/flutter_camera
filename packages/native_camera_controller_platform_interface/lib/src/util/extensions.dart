import 'package:native_camera_controller_platform_interface/native_camera_controller_platform_interface.dart';

extension CameraRatioExtension on CameraRatio {
  double get ratioValue {
    switch (this) {
      case CameraRatio.ratio3X4:
        return 3 / 4;
      case CameraRatio.ratio1X1:
        return 1;
    }
  }
}
