import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:native_camera_controller_ios/native_camera_controller_ios.dart';
import 'package:native_camera_controller_platform_interface/native_camera_controller_platform_interface.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  bool _isFlashEnabled = false;
  double _zoomLevel = 0.0;
  double _minZoomLevel = 0.0;
  double _maxZoomLevel = 1.0;

  final _nativeCameraControllerIosPlugin = NativeCameraControllerIOS();

  @override
  void initState() {
    super.initState();
    initPlatformState();
    _initializeCamera();
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
    await _nativeCameraControllerIosPlugin.initialize(FlashState.enabled, 0.5);
    bool flashStatus = await _nativeCameraControllerIosPlugin.getFlashStatus();
    double minZoom = await _nativeCameraControllerIosPlugin.getMinimumZoomLevel();
    double maxZoom = await _nativeCameraControllerIosPlugin.getMaximumZoomLevel();
    double currentZoom = await _nativeCameraControllerIosPlugin.getCurrentZoomLevel();

    setState(() {
      _isFlashEnabled = flashStatus;
      _minZoomLevel = minZoom;
      _maxZoomLevel = maxZoom;
      _zoomLevel = currentZoom;
    });
  }

  void _toggleFlash() async {
    bool newFlashStatus = !_isFlashEnabled;
    await _nativeCameraControllerIosPlugin.setFlashStatus(isActive: newFlashStatus);
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
                    color: _isFlashEnabled ? Colors.yellow : Colors.grey,
                    size: 30,
                  ),
                  onPressed: _toggleFlash,
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
                width: 300,
                height: 300,
                child: _nativeCameraControllerIosPlugin.getCameraView(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}