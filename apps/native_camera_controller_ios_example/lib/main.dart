import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:native_camera_controller_ios/native_camera_controller_ios.dart';
import 'package:native_camera_controller_platform_interface/native_camera_controller_platform_interface.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(final BuildContext context) => MaterialApp(
    home: const StartPage(),
    onGenerateRoute: (final RouteSettings settings) {
      if (settings.name == '/camera') {
        return MaterialPageRoute<Object?>(
          maintainState: false,
          builder: (final BuildContext context) => const CameraPage(),
        );
      } else if (settings.name == '/qr') {
        final String? qrCode = settings.arguments as String?;
        return MaterialPageRoute<Object?>(
          maintainState: false,
          builder:
              (final BuildContext context) =>
              QRCodePage(qrCode: qrCode ?? 'No QR code scanned'),
        );
      } else {
        return MaterialPageRoute<Object?>(
          maintainState: false,
          builder: (final BuildContext context) => const StartPage(),
        );
      }
    },
  );
}

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(final BuildContext context) => CustomWillPopScope(
    onWillPop: false,
    action: () {},
    child: Scaffold(
      appBar:  AppBar(
        automaticallyImplyLeading: false,
        title: const Center(child: Text('Camera Controller iOS Example')),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await Navigator.pushNamed(context, '/camera');
          },
          child: const Text('Start Camera'),
        ),
      ),
    ),
  );
}

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  String _platformVersion = 'Unknown';
  bool _isFlashEnabled = false;
  double _zoomLevel = 0;
  double _minZoomLevel = 0;
  double _maxZoomLevel = 1;

  final NativeCameraControllerPlatform _nativeCameraControllerIosPlugin =
  NativeCameraControllerIOS();

  Uint8List? _currentStreamedImage;
  Uint8List? _currentCapturedImage;
  StreamSubscription<Uint8List>? _imageSubscription;
  StreamSubscription<String?>? _qrCodeSubscription;

  @override
  void initState() {
    super.initState();
    debugPrint('Initializing camera controller');
    unawaited(initPlatformState());
    unawaited(_initializeCamera());
  }

  @override
  void dispose() {
    unawaited(_imageSubscription?.cancel());
    unawaited(_qrCodeSubscription?.cancel());
    unawaited(_nativeCameraControllerIosPlugin.dispose());
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

    if (!mounted) {
      return;
    }

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  final CameraImageListenerWrapper _cameraImageListenerWrapper =
  CameraImageListenerWrapper();

  Future<void> _initializeCamera() async {
    await _nativeCameraControllerIosPlugin.initialize(FlashState.enabled, 0.5);
    final double minZoom =
    await _nativeCameraControllerIosPlugin.getMinimumZoomLevel();
    final double maxZoom =
    await _nativeCameraControllerIosPlugin.getMaximumZoomLevel();
    final double currentZoom =
    await _nativeCameraControllerIosPlugin.getCurrentZoomLevel();
    final bool flashStatus =
    await _nativeCameraControllerIosPlugin.getFlashStatus();

    CameraImageListenerWrapper.setUp(_cameraImageListenerWrapper);
    _imageSubscription = _cameraImageListenerWrapper.imageStream.listen((
        final Uint8List image,
        ) {
      setState(() {
        _currentStreamedImage = image;
      });
    });

    _qrCodeSubscription = _cameraImageListenerWrapper.qrCodeStream.listen((
        final String? qrCode,
        ) {
      if (qrCode != null) {
        onQrCodeAvailable(qrCode);
      }
    });

    setState(() {
      _isFlashEnabled = flashStatus;
      _minZoomLevel = minZoom;
      _maxZoomLevel = maxZoom;
      _zoomLevel = currentZoom;
    });
  }

  Future<void> _toggleFlash() async {
    final bool newFlashStatus = !_isFlashEnabled;
    await _nativeCameraControllerIosPlugin.setFlashStatus(
      isActive: newFlashStatus,
    );
    setState(() {
      _isFlashEnabled = newFlashStatus;
    });
  }

  Future<void> _setZoomLevel(final double value) async {
    await _nativeCameraControllerIosPlugin.setZoomLevel(zoomLevel: value);
    setState(() {
      _zoomLevel = value;
    });
  }

  @override
  Widget build(final BuildContext context) => CustomWillPopScope(
    onWillPop: true,
    action: () async {
      await Navigator.pushNamed(context, '/');
    },
    child: Scaffold(
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        child: Align(
          alignment: Alignment.bottomLeft,
          child: BackButton(
            onPressed: () async {
              await Navigator.pushNamed(context, '/');
            },
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Running on: $_platformVersion\n'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
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
                  icon: const Icon(
                    Icons.picture_in_picture_rounded,
                    color: Colors.green,
                    size: 30,
                  ),
                  onPressed: () async {
                    final Uint8List? image =
                    await _nativeCameraControllerIosPlugin.takePicture();
                    setState(() {
                      _currentCapturedImage = image;
                    });
                    await Future<Object?>.delayed(const Duration(seconds: 2));
                    if (mounted) {
                      setState(() {
                        _currentCapturedImage = null;
                      });
                    }
                  },
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
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
                  const SizedBox.shrink(),
                const SizedBox(width: 20),
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
                  const SizedBox.shrink(),
              ],
            ),
          ],
        ),
      ),
    ),
  );

  void onImageAvailable(final Uint8List image) {
    setState(() {
      _currentStreamedImage = image;
    });
  }

  bool _isNavigatingToQR = false;

  Future<void> onQrCodeAvailable(final String? qrCode) async {
    if (qrCode != null && !_isNavigatingToQR) {
      debugPrint('QR Code: $qrCode. Navigating to QR code view');
      _isNavigatingToQR = true;
      await Navigator.pushNamed(context, '/qr', arguments: qrCode).then((_) {
        _isNavigatingToQR = false;
      });
    }
  }
}

class QRCodePage extends StatelessWidget {
  final String qrCode;

  const QRCodePage({required this.qrCode, super.key});

  @override
  Widget build(final BuildContext context) => CustomWillPopScope(
    onWillPop: true,
    action: () async {
      await Navigator.pushNamed(context, '/camera');
    },
    child: Scaffold(
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        child: Align(
          alignment: Alignment.bottomLeft,
          child: BackButton(
            onPressed: () async {
              await Navigator.pushNamed(context, '/camera');
            },
          ),
        ),
      ),
      body: Center(child: Text('QR Code: $qrCode')),
    ),
  );
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
  Widget build(final BuildContext context) =>
      Platform.isIOS
          ? GestureDetector(
        onPanEnd: (final DragEndDetails details) {
          if ((details.velocity.pixelsPerSecond.dx > 0) && onWillPop) {
            action();
          }
        },
        child: PopScope(canPop: false, child: child),
      )
          : PopScope(
        canPop: false,
        onPopInvokedWithResult: (final bool didPop, final Object? result) {
          if (onWillPop) {
            action();
          }
        },
        child: child,
      );
}
