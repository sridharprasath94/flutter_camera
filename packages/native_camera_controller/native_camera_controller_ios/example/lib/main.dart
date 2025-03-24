import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:native_camera_controller_ios/native_camera_controller_ios.dart';
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
      routes: {
        '/camera': (context) => CameraPage(),
        '/qr': (context) => QRCodePage(),
      },
    );
  }
}


class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Start')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/camera');
          },
          child: const Text('Start Camera'),
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

class _CameraPageState extends State<CameraPage> implements CameraImageListener {
  String _platformVersion = 'Unknown';
  bool _isFlashEnabled = false;
  double _zoomLevel = 0.0;
  double _minZoomLevel = 0.0;
  double _maxZoomLevel = 1.0;

  final NativeCameraControllerPlatform _nativeCameraControllerIosPlugin =
      NativeCameraControllerIOS();

  Uint8List? _currentStreamedImage;
  Uint8List? _currentCapturedImage;
  String? _qrCode;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _nativeCameraControllerIosPlugin.dispose();
    super.dispose();
  }
  Future<void> initPlatformState() async {
    String platformVersion;
    try {
      platformVersion =
          await _nativeCameraControllerIosPlugin.getPlatformVersion() ??
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
    _nativeCameraControllerIosPlugin.initialize(FlashState.enabled, 0.5);
    bool flashStatus = await _nativeCameraControllerIosPlugin.getFlashStatus();
    double minZoom =
        await _nativeCameraControllerIosPlugin.getMinimumZoomLevel();
    double maxZoom =
        await _nativeCameraControllerIosPlugin.getMaximumZoomLevel();
    double currentZoom =
        await _nativeCameraControllerIosPlugin.getCurrentZoomLevel();

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
    await _nativeCameraControllerIosPlugin.setFlashStatus(
      isActive: newFlashStatus,
    );
    setState(() {
      _isFlashEnabled = newFlashStatus;
    });
  }

  void _setZoomLevel(double value) async {
    await _nativeCameraControllerIosPlugin.setZoomLevel(zoomLevel: value);
    setState(() {
      _zoomLevel = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Camera with Controls')),
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
                        await _nativeCameraControllerIosPlugin.takePicture();
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
                child: _nativeCameraControllerIosPlugin.getCameraView(),
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
            const SizedBox(height: 8),
            if (_qrCode != null)
              Text('QR Code: $_qrCode')
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

  @override
  void onQrCodeAvailable(String? qrCode) {
    setState(() {
      _qrCode = qrCode;
    });

    if(qrCode != null) {
      Navigator.pushNamed(
        context,
        '/qr',
        arguments: qrCode,
      );
    }
  }
}

class QRCodePage extends StatelessWidget {
  const QRCodePage({super.key});

  @override
  Widget build(BuildContext context) {
    final String? qrCode = ModalRoute.of(context)?.settings.arguments as String?;
    return Scaffold(
      appBar: AppBar(title: const Text('QR Code Scanned')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('QR Code: ${qrCode ?? 'No QR code scanned'}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/camera');
              },
              child: const Text('Back to Camera'),
            ),
          ],
        ),
      ),
    );
  }
}