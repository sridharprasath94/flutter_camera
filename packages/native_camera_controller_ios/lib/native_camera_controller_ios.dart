import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:native_camera_controller_platform_interface/native_camera_controller_platform_interface.dart';

/// The iOS implementation of [NativeCameraControllerPlatform].
class NativeCameraControllerIOS extends NativeCameraControllerPlatform {
  /// Registers this class as the default
  /// instance of [NativeCameraControllerPlatform]
  @visibleForTesting
  static void registerWith() {
    NativeCameraControllerPlatform.instance = NativeCameraControllerIOS();
  }

  @visibleForTesting
  /// The method channel used to interact with the native platform.
  final MethodChannel methodChannel = const MethodChannel('native_camera_controller_ios');

  @override
  Widget getCameraView() => const UiKitView(
    viewType: '@views/native-camera-view',
    layoutDirection: TextDirection.ltr,
    creationParams: <String, dynamic>{},
    gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
      Factory<OneSequenceGestureRecognizer>(EagerGestureRecognizer.new),
    },
    creationParamsCodec: StandardMessageCodec(),
  );

  @override
  Future<String?> getPlatformVersion() async {
    final String? version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }
}
