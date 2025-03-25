import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:native_camera_controller_android/native_camera_controller_android.dart';
import 'package:native_camera_controller_platform_interface/native_camera_controller_platform_interface.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StartPage(),
      onGenerateRoute: (settings) {
        if (settings.name == '/camera') {
          return MaterialPageRoute(
            maintainState: false,
            builder: (context) => CameraPage(),
          );
        } else if (settings.name == '/qr') {
          final String? qrCode = settings.arguments as String?;
          return MaterialPageRoute(
            maintainState: false,
            builder:
                (context) => QRCodePage(qrCode: qrCode ?? 'No QR code scanned'),
          );
        } else {
          return MaterialPageRoute(
            maintainState: false,
            builder: (context) => StartPage(),
          );
        }
      },
    );
  }
}

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomWillPopScope(
      onWillPop: false,
      action: () {},
      child: Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/camera');
            },
            child: const Text('Start Camera'),
          ),
        ),
      ),
    );
  }
}

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage>
    implements CameraImageListener {
  String _platformVersion = 'Unknown';
  bool _isFlashEnabled = false;
  double _zoomLevel = 0.0;
  double _minZoomLevel = 0.0;
  double _maxZoomLevel = 1.0;

  final NativeCameraControllerPlatform _nativeCameraControllerAndroidPlugin =
      NativeCameraControllerAndroid();

  Uint8List? _currentStreamedImage;
  Uint8List? _currentCapturedImage;

  @override
  void initState() {
    super.initState();
    debugPrint('Initializing camera controller');
    initPlatformState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _nativeCameraControllerAndroidPlugin.dispose();
    super.dispose();
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    try {
      platformVersion =
          await _nativeCameraControllerAndroidPlugin.getPlatformVersion() ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  Future<void> _initializeCamera() async {
    await _nativeCameraControllerAndroidPlugin.initialize(
      FlashState.disabled,
      0.5,
    );
    bool flashStatus =
        await _nativeCameraControllerAndroidPlugin.getFlashStatus();
    double minZoom =
        await _nativeCameraControllerAndroidPlugin.getMinimumZoomLevel();
    double maxZoom =
        await _nativeCameraControllerAndroidPlugin.getMaximumZoomLevel();
    double currentZoom =
        await _nativeCameraControllerAndroidPlugin.getCurrentZoomLevel();

    CameraImageListener.setUp(this);

    setState(() {
      _isFlashEnabled = flashStatus;
      _minZoomLevel = minZoom;
      _maxZoomLevel = maxZoom;
      _zoomLevel = currentZoom;
    });
  }

  void _toggleFlash() async {
    bool newFlashStatus = !_isFlashEnabled;
    await _nativeCameraControllerAndroidPlugin.setFlashStatus(
      isActive: newFlashStatus,
    );
    setState(() {
      _isFlashEnabled = newFlashStatus;
    });
  }

  void _setZoomLevel(double value) async {
    await _nativeCameraControllerAndroidPlugin.setZoomLevel(zoomLevel: value);
    setState(() {
      _zoomLevel = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomWillPopScope(
      onWillPop: false,
      action: () {
        Navigator.pushNamed(context, '/');
      },
      child: Scaffold(
        bottomNavigationBar: BottomAppBar(
          color: Colors.transparent,
          child: Align(
            alignment: Alignment.bottomLeft,
            child: BackButton(
              onPressed: () {
                Navigator.pushNamed(context, '/');
              },
            ),
          ),
        ),
        body: Column(
          children: [
            Text('Running on: $_platformVersion\n'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    _isFlashEnabled ? Icons.flash_on : Icons.flash_off,
                    color: _isFlashEnabled ? Colors.green : Colors.grey,
                    size: 30,
                  ),
                  onPressed: _toggleFlash,
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon: Icon(
                    Icons.picture_in_picture_rounded,
                    color: Colors.green,
                    size: 30,
                  ),
                  onPressed: (() async {
                    Uint8List? image =
                        await _nativeCameraControllerAndroidPlugin
                            .takePicture();
                    setState(() {
                      _currentCapturedImage = image;
                    });
                    await Future.delayed(const Duration(seconds: 2));
                    setState(() {
                      _currentCapturedImage = null;
                    });
                  }),
                ),
                const SizedBox(width: 20),
                const Text('Zoom:'),
                Slider(
                  value: _zoomLevel,
                  min: _minZoomLevel,
                  max: _maxZoomLevel,
                  onChanged: _setZoomLevel,
                ),
              ],
            ),
            Center(
              child: SizedBox(
                width: 250,
                height: 250,
                child: _nativeCameraControllerAndroidPlugin.getCameraView(),
              ),
            ),
            const SizedBox(height: 8),
            if (_currentStreamedImage != null)
              SizedBox(
                width: 150,
                height: 150,
                child: Image.memory(
                  _currentStreamedImage!,
                  gaplessPlayback: true,
                ),
              )
            else
              SizedBox.shrink(),
            const SizedBox(height: 8),
            if (_currentCapturedImage != null)
              SizedBox(
                width: 150,
                height: 150,
                child: Image.memory(
                  _currentCapturedImage!,
                  gaplessPlayback: true,
                ),
              )
            else
              SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  @override
  void onImageAvailable(Uint8List image) {
    setState(() {
      _currentStreamedImage = image;
    });
  }

  bool _isNavigatingToQR = false;

  @override
  void onQrCodeAvailable(String? qrCode) {
    if (qrCode != null && !_isNavigatingToQR) {
      debugPrint('QR Code: $qrCode. Navigating to QR code view');
      _isNavigatingToQR = true;
      Navigator.pushNamed(context, '/qr', arguments: qrCode).then((_) {
        _isNavigatingToQR = false;
      });
    }
  }
}

class QRCodePage extends StatelessWidget {
  final String qrCode;

  const QRCodePage({required this.qrCode, super.key});

  @override
  Widget build(BuildContext context) {
    return CustomWillPopScope(
      onWillPop: true,
      action: () {
        Navigator.pushNamed(context, '/camera');
      },
      child: Scaffold(
        bottomNavigationBar: BottomAppBar(
          color: Colors.transparent,
          child: Align(
            alignment: Alignment.bottomLeft,
            child: BackButton(
              onPressed: () {
                Navigator.pushNamed(context, '/camera');
              },
            ),
          ),
        ),
        body: Center(child: Text('QR Code: $qrCode')),
      ),
    );
  }
}

class CustomWillPopScope extends StatelessWidget {
  const CustomWillPopScope({
    required this.child,
    this.onWillPop = false,
    super.key,
    required this.action,
  });

  final Widget child;
  final bool onWillPop;
  final VoidCallback action;

  @override
  Widget build(BuildContext context) =>
      Platform.isIOS
          ? GestureDetector(
            onPanEnd: (DragEndDetails details) {
              if ((details.velocity.pixelsPerSecond.dx > 0) && onWillPop) {
                action();
              }
            },
            child: PopScope(canPop: false, child: child),
          )
          : PopScope(
            canPop: false,
            onPopInvokedWithResult: (bool didPop, Object? result) {
              if (onWillPop) {
                action();
              }
            },
            child: child,
          );
}
