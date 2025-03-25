import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_camera_controller_android/native_camera_controller_android.dart';
import 'package:native_camera_controller_platform_interface/native_camera_controller_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockNativeCameraControllerAndroidPlatform
    with MockPlatformInterfaceMixin
    implements NativeCameraControllerPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Widget getCameraView() {
    return const SizedBox.shrink();
  }

  @override
  Future<void> dispose() async {}

  @override
  Future<bool> getFlashStatus() async => true;

  @override
  Future<double> getCurrentZoomLevel() async => 2.0;

  @override
  Future<void> initialize(
      FlashState flashState,
      double flashTorchLevel,
      ) async {}

  @override
  Future<void> setFlashStatus({required bool isActive}) async {}

  @override
  Future<void> setZoomLevel({required double zoomLevel}) async {}

  @override
  Future<Uint8List?> takePicture() async => Uint8List(0);

  @override
  Future<double> getMaximumZoomLevel() async => 10.0;

  @override
  Future<double> getMinimumZoomLevel() async => 1.0;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('native_camera_controller_android');
  final platform = NativeCameraControllerAndroid();

  setUp(() {
    NativeCameraControllerPlatform.instance = NativeCameraControllerAndroid();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
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
  final initialPlatform = NativeCameraControllerPlatform.instance;

  test('$NativeCameraControllerAndroid is the default instance', () {
    expect(initialPlatform, isInstanceOf<NativeCameraControllerAndroid>());
  });
}