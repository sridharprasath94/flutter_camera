import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_camera_controller_ios/native_camera_controller_ios.dart';
import 'package:native_camera_controller_platform_interface/native_camera_controller_platform_interface.dart';


void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('native_camera_controller_ios');
  final NativeCameraControllerIOS platform = NativeCameraControllerIOS();

  setUp(() {
    NativeCameraControllerPlatform.instance = NativeCameraControllerIOS();
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

  NativeCameraControllerIOS.registerWith();
  final NativeCameraControllerPlatform initialPlatform = NativeCameraControllerPlatform.instance;

  test('$NativeCameraControllerIOS is the default instance', () {
    expect(initialPlatform, isInstanceOf<NativeCameraControllerIOS>());
  });
}
