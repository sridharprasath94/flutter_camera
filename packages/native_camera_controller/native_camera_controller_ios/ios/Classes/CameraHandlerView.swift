import SwiftUI
import SwiftIOSCamera

struct CameraHandlerView: View {
    @Environment(\.presentationMode) private var presentationMode
    @StateObject var cameraHandler : CameraSessionHandler
    @State var barcodeMode: Bool
    @State var currentCapturedImage: UIImage? = nil
    @State var obtainedBarcodeResult: String? = nil
    @State private var initialFlash: Bool = false
    @State var currentCameraState : CameraState = .CAMERA_RESUME
    enum CameraState {
        case CAMERA_RESUME
        case CAMERA_STOP}
    
    init(barcodeMode: Bool, cameraHandler: CameraSessionHandler) {
        self._barcodeMode = State.init(initialValue: barcodeMode)
        self._cameraHandler = StateObject.init(wrappedValue: cameraHandler)
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
                print("The ui image is \(String(describing: uiImage?.size))")
                DispatchQueue.main.async {
                    currentCapturedImage = uiImage
                }
            }, onBarcodeObtained: { barcodeResult in
                print(barcodeResult ?? "No barcode obtained")
                DispatchQueue.main.async {
                    if(barcodeResult != nil){
                        obtainedBarcodeResult = barcodeResult
                    }
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


struct CameraHandlerView_Previews: PreviewProvider {
    static var previews: some View {
        CameraHandlerView(barcodeMode: false,cameraHandler: CameraSessionHandler())
    }
}
