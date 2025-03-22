
import 'mobile_camera_platform_interface.dart';

class MobileCamera {
  Future<String?> getPlatformVersion() {
    return MobileCameraPlatform.instance.getPlatformVersion();
  }
}
