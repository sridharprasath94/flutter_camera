import Flutter
import Combine
import SwiftUI
import UIKit
import SwiftIOSCamera

public class NativeCameraControllerIosPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "native_camera_controller_ios", binaryMessenger: registrar.messenger())
        let instance = NativeCameraControllerIosPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        CameraApiSetup.setUp(binaryMessenger: registrar.messenger(), api: CameraApiImplementation(registrar: registrar))
        let factory = FLNativeViewFactory(messenger: registrar.messenger())
        registrar.register(factory, withId: "@views/native-camera-view")
        print("Native Camera Controller IOS plugin registered")
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

@available(iOS 14.0, *)
class FLNativeViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger
    
    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }
    
    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return FLNativeView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            binaryMessenger: messenger)
    }
}

@available(iOS 14.0, *)
class FLNativeView: UIView, FlutterPlatformView {
    private var _view: UIView
    @ObservedObject var currentSession = CameraSession.shared

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?
    ) {
        _view = UIView()
        super.init(frame: frame)
        print("Building View")
        let hostingController = UIHostingController(rootView: CameraHandlerView(barcodeMode: true, cameraHandler: currentSession.cameraHandler))
        self._view.addConstrained(subview: hostingController.view)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func view() -> UIView {
        return _view
    }
}


class CameraApiImplementation: CameraApi {
    func initialize(cameraMode: CameraMode,cameraRatio: CameraRatio, flashState: FlashState, flashTorchLevel: Double, completion: @escaping (Result<Void, any Error>) -> Void) {
        print("Initialisng camera api")
        CameraSession.shared.initializeCameraHandler(flashState: flashState, flashTorchLevel: flashTorchLevel)
        let cameraListener = CameraImageListener(binaryMessenger: self.registrar.messenger())
        cameraImageListener = cameraListener
        listenToImages()
        completion(.success(()))
    }
    
    var cancellables = Set<AnyCancellable>()
    func getCurrentZoomLevel() throws -> Double {
        return Double(currentSession.cameraHandler.getCurrentZoom())
    }
    
    func getMinimumZoomLevel() throws -> Double {
        return Double(currentSession.cameraHandler.getMinZoom())
    }
    
    func getMaximumZoomLevel() throws -> Double {
        return Double(currentSession.cameraHandler.getMaxZoom())
    }
    
    var registrar :  FlutterPluginRegistrar
    
    init(registrar: FlutterPluginRegistrar){
        self.registrar = registrar
    }
    
    
    func getPlatformVersion() throws -> String {
        return "iOS " + UIDevice.current.systemVersion
    }
    
    var cameraImageListener: CameraImageListener?
    @ObservedObject var currentSession = CameraSession.shared
    
    func dispose() throws {
        currentSession.cameraHandler.stopCamera()
    }
    
    func takePicture(completion: @escaping (Result<FlutterStandardTypedData, Error>) -> Void) {
        if let cameraImage = self.currentSession.currentCapturedImage, let imageData = cameraImage.pngData() {
            let flutterData = FlutterStandardTypedData(bytes: imageData)
            completion(.success(flutterData))
        } else {
            let error = NSError(
                domain: "CameraErrorDomain", code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to capture image"])
            completion(.failure(error))
        }
    }
    
    func listenToImages() {
        guard let listener = cameraImageListener else {
            print("Listener or view is not initialized")
            return
        }
        
        DispatchQueue.main.async {
            self.currentSession.$currentCapturedImage
                .receive(on: RunLoop.main)
                .sink { [] uiImage in
                    guard let uiImage = uiImage else { return }
                    if let imageData = uiImage.pngData() {
                        let flutterData = FlutterStandardTypedData(bytes: imageData)
                        listener.onImageAvailable(image: flutterData, completion: {_ in })
                    }
                }.store(in: &self.cancellables)
            
            self.currentSession.$obtainedBarcodeResult
                .receive(on: RunLoop.main)
                .sink { barcode in
                    listener.onQrCodeAvailable(qrCode: barcode,completion: {_ in })
                }.store(in: &self.cancellables)
        }
        
    }
    
    func setZoomLevel(zoomLevel: Double) {
        return currentSession.cameraHandler.changeZoomLevel(zoom: zoomLevel)
    }
    
    func setFlashStatus(isActive: Bool) {
        return currentSession.cameraHandler.changeFlashState(toggleState: isActive)
    }
    
    func getFlashStatus() -> Bool {
        return currentSession.cameraHandler.isFlashEnabled()
    }
}


@available(iOS 13.0, *)
extension UIView {
    func addConstrained(subview: UIView) {
        addSubview(subview)
        subview.topAnchor.constraint(equalTo: topAnchor).isActive = true
        subview.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        subview.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        subview.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        subview.translatesAutoresizingMaskIntoConstraints = false
    }
}
