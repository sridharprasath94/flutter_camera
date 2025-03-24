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



class CameraApiImplementation: CameraApi {
    var cancellables = Set<AnyCancellable>()
    func getCurrentZoomLevel() throws -> Double {
        return Double(cameraHandler?.getCurrentZoom() ?? 3.0)
    }
    
    func getMinimumZoomLevel() throws -> Double {
        return Double(cameraHandler?.getMinZoom() ?? 1.0)
    }
    
    func getMaximumZoomLevel() throws -> Double {
        return Double(cameraHandler?.getMaxZoom() ?? 10.0)
    }
    
    var registrar :  FlutterPluginRegistrar
    
    init(registrar: FlutterPluginRegistrar){
        self.registrar = registrar
    }
    
    
    func getPlatformVersion() throws -> String {
        return "iOS " + UIDevice.current.systemVersion
    }
    var cameraHandlerView : CameraHandlerView?
    var cameraHandler: CameraSessionHandler?
    var cameraImageListener: CameraImageListener?
    
    func dispose() throws {
        cameraHandler?.stopCamera()
    }
    
    func initialize(flashState: FlashState, flashTorchLevel: Double) throws {
        let handler = CameraSessionHandler(enableFlash: flashState == FlashState.enabled).updateFlashTorchLevel(torchLevel: Float(flashTorchLevel))
        let view = CameraHandlerView(barcodeMode: true, cameraHandler: handler)
        let cameraListener = CameraImageListener(binaryMessenger: self.registrar.messenger())
        cameraHandler = handler
        cameraHandlerView = view
        cameraImageListener = cameraListener
        let factory = FLNativeViewFactory(messenger: registrar.messenger(), cameraHandlerView: view)
        registrar.register(factory, withId: "@views/native-camera-view")
        listenToImages()
    }
    
    func takePicture(completion: @escaping (Result<FlutterStandardTypedData, Error>) -> Void) {
        if let cameraImage = cameraHandlerView?.viewModel.currentCapturedImage, let imageData = cameraImage.pngData() {
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
        guard let listener = cameraImageListener, let view = cameraHandlerView else {
            print("Listener or view is not initialized")
            return
        }
        
        DispatchQueue.main.async {
            view.viewModel.$currentCapturedImage
                .receive(on: RunLoop.main)
                .sink { [] uiImage in
                    guard let uiImage = uiImage else { return }
                    if let imageData = uiImage.pngData() {
                        let flutterData = FlutterStandardTypedData(bytes: imageData)
                        listener.onImageAvailable(image: flutterData, completion: {_ in })
                    }
                }.store(in: &self.cancellables)

            view.viewModel.$obtainedBarcodeResult
                .receive(on: RunLoop.main)
                .sink { barcode in
                    listener.onQrCodeAvailable(qrCode: barcode,completion: {_ in })
                }.store(in: &self.cancellables)
        }

    }
    
    func setZoomLevel(zoomLevel: Double) {
        if let handler = cameraHandler {
            return handler.changeZoomLevel(zoom: zoomLevel)
        }
    }
    
    func setFlashStatus(isActive: Bool) {
        if let handler = cameraHandler {
            return handler.changeFlashState(toggleState: isActive)
        }
    }
    
    func getFlashStatus() -> Bool {
        if let handler = cameraHandler{
            return handler.isFlashEnabled()
        }
        return false
    }
    

    @available(iOS 14.0, *)
    class FLNativeViewFactory: NSObject, FlutterPlatformViewFactory {
        private var messenger: FlutterBinaryMessenger
        private var cameraHandlerView: CameraHandlerView
        
        init(messenger: FlutterBinaryMessenger, cameraHandlerView: CameraHandlerView) {
            self.messenger = messenger
            self.cameraHandlerView  = cameraHandlerView
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
                binaryMessenger: messenger,
                cameraHandlerView: cameraHandlerView)
        }
    }
    
    @available(iOS 14.0, *)
    class FLNativeView: UIView, FlutterPlatformView {
        private var _view: UIView
        @ObservedObject private var vm = ViewModel.shared
        
        init(
            frame: CGRect,
            viewIdentifier viewId: Int64,
            arguments args: Any?,
            binaryMessenger messenger: FlutterBinaryMessenger?,
            cameraHandlerView: CameraHandlerView
        ) {
            _view = UIView()
            super.init(frame: frame)
            let hostingController = UIHostingController(rootView: cameraHandlerView)
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
}
