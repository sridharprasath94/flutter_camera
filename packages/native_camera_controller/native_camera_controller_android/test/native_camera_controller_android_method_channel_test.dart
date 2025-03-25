import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_camera_controller_android/native_camera_controller_android_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelNativeCameraControllerAndroid platform = MethodChannelNativeCameraControllerAndroid();
  const MethodChannel channel = MethodChannel('native_camera_controller_android');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
