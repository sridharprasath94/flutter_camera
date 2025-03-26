package com.flashandroid.native_camera_controller_android;

import static com.flashandroid.native_camera_controller_android.CameraApiInterface.CameraType.CAMERA_BARCODE_SCAN;
import static com.flashandroid.native_camera_controller_android.CameraApiInterface.CameraType.CAMERA_PREVIEW;
import static com.flashandroid.sdk.ui.CameraParameters.CameraRatioMode.RATIO_1X1;

import android.app.Activity;
import android.content.Context;
import android.graphics.Bitmap;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.lifecycle.LifecycleOwner;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.flashandroid.sdk.misc.exceptions.ExceptionType;
import com.flashandroid.sdk.ui.CameraCallback;
import com.flashandroid.sdk.ui.CameraConstants;
import com.flashandroid.sdk.ui.CameraParameters;
import com.flashandroid.sdk.ui.CameraView;

import java.lang.ref.WeakReference;

public class CameraScanModel extends ViewModel {
    public MutableLiveData<Exception> getExceptionObserver() {
        return exceptionObserver;
    }

    public MutableLiveData<Bitmap> getStreamBitmapObserver() {
        return bitmapStreamObserver;
    }

    public MutableLiveData<String> getBarcodeResultObserver() {
        return barcodeResultObserver;
    }

    public CameraConstants.CameraMode getCameraMode () {
        return cameraMode;
    }

    private final WeakReference<Context> contextRef;
    private final boolean enableFlash;
    private final static String TAG = "NATIVE_CAMERA_CONTROLLER_ANDROID_CAMERA";
    private final MutableLiveData<Exception> exceptionObserver = new MutableLiveData<>();
    private final MutableLiveData<Bitmap> bitmapStreamObserver = new MutableLiveData<>();

    private final MutableLiveData<String> barcodeResultObserver = new MutableLiveData<>();
    private final CameraParameters.CameraRatioMode cameraRatioMode;
    private final CameraConstants.CameraMode cameraMode;

    public CameraScanModel(Context context, @NonNull CameraApiInterface.CameraType cameraType, @NonNull CameraApiInterface.CameraRatio cameraRatio, @NonNull CameraApiInterface.FlashState flashState) {
        this.contextRef = new WeakReference<>(context);
        this.cameraRatioMode = cameraRatio == CameraApiInterface.CameraRatio.RATIO1X1 ? RATIO_1X1 : CameraParameters.CameraRatioMode.RATIO_3X4;
        this.cameraMode = (cameraType == CAMERA_BARCODE_SCAN) ? CameraConstants.CameraMode.BARCODE_SCAN :
                (cameraType == CAMERA_PREVIEW) ? CameraConstants.CameraMode.CAMERA_PREVIEW :
                        CameraConstants.CameraMode.CAMERA_CAPTURE;
        this.enableFlash = flashState == CameraApiInterface.FlashState.ENABLED;
    }

    protected void initCamera(Activity activity, CameraView cameraView) {
        CameraParameters cameraParameters = new CameraParameters.Builder()
                .selectRatio(this.cameraRatioMode)
                .updateCameraMode(this.cameraMode)
                .enableDefaultLayout(false)
                .selectPrimaryCamera(false)
                .build();
        cameraView.initCameraCapture(cameraParameters, (Activity) this.contextRef.get(), new CameraCallback() {
            @Override
            public void onImageObtained(Bitmap bitmap, String barcodeResult) {
                if (bitmap != null) {
                    activity.runOnUiThread(() -> bitmapStreamObserver.postValue(bitmap));
                }
                activity.runOnUiThread(() -> barcodeResultObserver.postValue(barcodeResult));
            }

            @Override
            public void onError(ExceptionType type, Exception e) {
                activity.runOnUiThread(() -> exceptionObserver.postValue(e));
            }
        });
        cameraView.changeFlashState(enableFlash);
        Log.d(TAG, "Camera initialized with flash state: " + enableFlash);
    }

    protected void cancelObservers(Activity activity) {
        this.exceptionObserver.removeObservers((LifecycleOwner) activity);
        this.bitmapStreamObserver.removeObservers((LifecycleOwner) activity);
        this.barcodeResultObserver.removeObservers((LifecycleOwner) activity);
        Log.d(TAG, "Cancelling the observers");
    }
}
