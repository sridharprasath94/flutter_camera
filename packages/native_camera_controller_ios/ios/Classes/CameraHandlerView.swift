import SwiftUI
import SwiftIOSCamera


class CameraSession: ObservableObject {
    @Published var currentCapturedImage: UIImage? = nil
    @Published var obtainedBarcodeResult: String? = nil
    @Published var currentFlash: Bool = false
    static let shared = CameraSession()
    private init() {}
    
    lazy var cameraHandler: CameraSessionHandler = {
        fatalError("CameraSessionHandler must be explicitly initialized using `initialize` method")
    }()
    
    lazy var cameraMode : CameraMode = {
        fatalError("CameraMode must be explicitly initialized using `initialize` method")
    }()
    
    lazy var previewMode : PreviewMode = {
        fatalError("PreviewMode must be explicitly initialized using `initialize` method")
    }()
    
    func initialize(cameraMode : CameraMode, previewMode: PreviewMode, flashState: FlashState, flashTorchLevel: Double) {
        self.cameraHandler = CameraSessionHandler(enableFlash: flashState == .enabled)
        self.cameraMode = cameraMode
        self.previewMode = previewMode
        _ = self.cameraHandler.updateFlashTorchLevel(torchLevel: Float(flashTorchLevel))
        cameraHandler.changeFlashState(toggleState: flashState == .enabled)
    }
}


struct CameraHandlerView: View {
    @Environment(\.presentationMode) private var presentationMode
    @StateObject var cameraHandler : CameraSessionHandler
    @State var cameraMode: CameraMode
    @State var previewMode: PreviewMode
    @ObservedObject var cameraViewModel = CameraSession.shared
    @State private var initialFlash: Bool = false
    @State var currentCameraState : CameraState = .CAMERA_RESUME
    enum CameraState {
        case CAMERA_RESUME
        case CAMERA_STOP}
    
    init(cameraMode: CameraMode, previewMode: PreviewMode, cameraHandler: CameraSessionHandler) {
        self._cameraMode = State.init(initialValue: cameraMode)
        self._previewMode = State.init(initialValue: previewMode)
        self._cameraHandler = StateObject.init(wrappedValue: cameraHandler)
        print("Camera view")
    }
    var body: some View {
        GeometryReader { geometry in
            let _ = print("Geometry width \(geometry.size.width) and height \((geometry.size.height))")
            ZStack{
                cameraControllerView(viewWidth: geometry.size.width)
            }.frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
                .onDisappear {
                    self.stopCamera()
                }
        }
    }
    
    fileprivate func cameraControllerView(viewWidth: CGFloat) -> some View {
        return HStack {
//            let _ = print("Geometry width \(viewWidth) and height \((viewWidth /  previewMode.ratioValue))")
            CameraView(cameraSessionHandler: cameraHandler, cameraMode: cameraMode,  previewMode: (previewMode == .ratio1X1()) ? .ratio1X1(initialWidth: viewWidth) : .ratio3X4(initialWidth: viewWidth)).initCameraCallback(cameraCaptureCallback: .init(onCameraImageObtained: { uiImage in
                DispatchQueue.main.async {
                    cameraViewModel.currentCapturedImage = uiImage
                }
            }, onBarcodeObtained: { barcodeResult in
                DispatchQueue.main.async {
                    cameraViewModel.obtainedBarcodeResult = barcodeResult
                }
            }, onError: { exceptionType, error in
                print(error)
            }))
        }.frame(width: viewWidth,
                height:  (viewWidth /  previewMode.ratioValue) ,
                alignment: .center)
    }
    
    func stopCamera() {
        if(self.currentCameraState == .CAMERA_STOP){
            return
        }
        self.currentCameraState = .CAMERA_STOP
        self.cameraHandler.onStop()
    }
}

struct CameraHandlerView_Previews: PreviewProvider {
    static var previews: some View {
        CameraHandlerView(cameraMode: .cameraCapture, previewMode: .ratio1X1(),cameraHandler: CameraSessionHandler())
    }
}
