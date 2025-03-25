
import 'native_camera_controller_android_platform_interface.dart';

class NativeCameraControllerAndroid {
  Future<String?> getPlatformVersion() {
    return NativeCameraControllerAndroidPlatform.instance.getPlatformVersion();
  }
}
