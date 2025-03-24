import SwiftUI
import SwiftIOSCamera


class CameraViewModel: ObservableObject {
    @Published var currentCapturedImage: UIImage? = nil
    @Published var obtainedBarcodeResult: String? = nil
    @Published var cameraHandler: CameraSessionHandler? = nil
    // Singleton instance
    static let shared = CameraViewModel()

    private init() {} // Private initializer to prevent instantiation from outside
}


struct CameraHandlerView: View {
    @Environment(\.presentationMode) private var presentationMode
    @StateObject var cameraHandler : CameraSessionHandler
    @State var barcodeMode: Bool
    @ObservedObject var cameraViewModel = CameraViewModel.shared
    @State private var initialFlash: Bool = false
    @State var currentCameraState : CameraState = .CAMERA_RESUME
    enum CameraState {
        case CAMERA_RESUME
        case CAMERA_STOP}
    
    init(barcodeMode: Bool, cameraHandler: CameraSessionHandler) {
        self._barcodeMode = State.init(initialValue: barcodeMode)
        self._cameraHandler = StateObject.init(wrappedValue: cameraHandler)
        cameraViewModel.cameraHandler = cameraHandler
        print("Camera view")
    }
    var body: some View {
        GeometryReader { geometry in
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
            CameraView(cameraSessionHandler: cameraHandler, cameraMode: barcodeMode ? CameraMode.barcodeScan : CameraMode.cameraCapture,  previewMode: .ratio1X1(initialWidth: viewWidth)).initCameraCallback(cameraCaptureCallback: .init(onCameraImageObtained: { uiImage in
                DispatchQueue.main.async {
                    cameraViewModel.currentCapturedImage = uiImage
                }
            }, onBarcodeObtained: { barcodeResult in
                DispatchQueue.main.async {
                   cameraViewModel.obtainedBarcodeResult = barcodeResult
                 }
            }, onError: { exceptionType, error in
                print(error)
            })).onAppear(){
                if(barcodeMode){
                    return
                }
            }
        }.frame(width: viewWidth,
                height:  (viewWidth /  PreviewMode.ratio1X1().ratioValue) ,
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

protocol CameraViewDelegate: AnyObject {
    func onImageReceived(_ image: UIImage)
    func onBarcodeReceived(_ barcode: String?)
}

struct CameraHandlerView_Previews: PreviewProvider {
    static var previews: some View {
        CameraHandlerView(barcodeMode: false,cameraHandler: CameraSessionHandler())
    }
}
