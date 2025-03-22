import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_camera/mobile_camera.dart';
import 'package:mobile_camera/mobile_camera_platform_interface.dart';
import 'package:mobile_camera/mobile_camera_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockMobileCameraPlatform
    with MockPlatformInterfaceMixin
    implements MobileCameraPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final MobileCameraPlatform initialPlatform = MobileCameraPlatform.instance;

  test('$MethodChannelMobileCamera is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelMobileCamera>());
  });

  test('getPlatformVersion', () async {
    MobileCamera mobileCameraPlugin = MobileCamera();
    MockMobileCameraPlatform fakePlatform = MockMobileCameraPlatform();
    MobileCameraPlatform.instance = fakePlatform;

    expect(await mobileCameraPlugin.getPlatformVersion(), '42');
  });
}
