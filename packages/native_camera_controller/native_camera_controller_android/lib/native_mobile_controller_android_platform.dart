import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:native_camera_controller_platform_interface/native_camera_controller_platform_interface.dart';

class NativeCameraControllerAndroid extends NativeCameraControllerPlatform {
  /// Registers this class as the default instance
  /// of [MobileCameraControllerPlatform]
  static void registerWith() {
    NativeCameraControllerPlatform.instance = NativeCameraControllerAndroid();
  }

  @override
  Widget getCameraView() => AndroidView(
    viewType: '@views/native-camera-view',
    layoutDirection: TextDirection.ltr,
    creationParams: <String, dynamic>{},
    gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
      Factory<OneSequenceGestureRecognizer>(
        EagerGestureRecognizer.new,
      ),
    },
    creationParamsCodec: StandardMessageCodec(),
  );
}
