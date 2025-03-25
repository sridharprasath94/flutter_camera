import 'package:flutter_test/flutter_test.dart';
import 'package:native_camera_controller_android/native_camera_controller_android.dart';
import 'package:native_camera_controller_android/native_camera_controller_android_platform_interface.dart';
import 'package:native_camera_controller_android/native_camera_controller_android_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockNativeCameraControllerAndroidPlatform
    with MockPlatformInterfaceMixin
    implements NativeCameraControllerAndroidPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final NativeCameraControllerAndroidPlatform initialPlatform = NativeCameraControllerAndroidPlatform.instance;

  test('$MethodChannelNativeCameraControllerAndroid is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelNativeCameraControllerAndroid>());
  });

  test('getPlatformVersion', () async {
    NativeCameraControllerAndroid nativeCameraControllerAndroidPlugin = NativeCameraControllerAndroid();
    MockNativeCameraControllerAndroidPlatform fakePlatform = MockNativeCameraControllerAndroidPlatform();
    NativeCameraControllerAndroidPlatform.instance = fakePlatform;

    expect(await nativeCameraControllerAndroidPlugin.getPlatformVersion(), '42');
  });
}
