import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_camera_controller_android/native_camera_controller_android.dart';
import 'package:native_camera_controller_platform_interface/native_camera_controller_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel(
    'native_camera_controller_android',
  );
  final NativeCameraControllerAndroid platform =
      NativeCameraControllerAndroid();

  setUp(() {
    NativeCameraControllerPlatform.instance = NativeCameraControllerAndroid();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (final MethodCall methodCall) async {
          if (methodCall.method == 'getPlatformVersion') {
            return '42';
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });

  test('getCameraView', () async {
    expect(platform.getCameraView(), isInstanceOf<Widget>());
  });

  NativeCameraControllerAndroid.registerWith();
  final NativeCameraControllerPlatform initialPlatform =
      NativeCameraControllerPlatform.instance;

  test('$NativeCameraControllerAndroid is the default instance', () {
    expect(initialPlatform, isInstanceOf<NativeCameraControllerAndroid>());
  });
}
