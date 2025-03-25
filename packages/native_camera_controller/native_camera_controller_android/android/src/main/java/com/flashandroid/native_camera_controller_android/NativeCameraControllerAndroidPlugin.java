package com.flashandroid.native_camera_controller_android;

import android.Manifest;
import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import androidx.lifecycle.LifecycleOwner;

import com.flashandroid.native_camera_controller_android.databinding.CameraViewBinding;
import com.flashandroid.sdk.ui.CameraView;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

/**
 * NativeCameraControllerAndroidPlugin
 */
public class NativeCameraControllerAndroidPlugin implements FlutterPlugin, ActivityAware, MethodCallHandler, PluginRegistry.RequestPermissionsResultListener {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel channel;
    private final static String plugin_name = "native_camera_controller_android";
    private final static String TAG = "NATIVE_CAMERA_CONTROLLER_ANDROID_CAMERA";
    private final static String android_view_id = "@views/native-camera-view";
    private CameraView cameraView;
    public FlutterPluginBinding flutterPluginBinding;
    public Activity activity;
    public ActivityPluginBinding activityPluginBinding;
    private CameraViewBinding cameraViewBinding;

    private CameraScanModel cameraScanModel;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        Log.d(TAG, "Attached to engine");
        this.flutterPluginBinding = flutterPluginBinding;
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), plugin_name);
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (call.method.equals("getPlatformVersion")) {
            result.success("Android " + android.os.Build.VERSION.RELEASE);
        } else {
            result.notImplemented();
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        Log.d(TAG, "Detaching engine");
        this.flutterPluginBinding = binding;
        channel.setMethodCallHandler(null);
    }


    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        Log.d(TAG, "Attached to activity");
        activityPluginBinding = binding;
        activity = binding.getActivity();
        cameraViewBinding = CameraViewBinding.inflate(activity.getLayoutInflater());
        activityPluginBinding.addRequestPermissionsResultListener(NativeCameraControllerAndroidPlugin.this);


        flutterPluginBinding.getPlatformViewRegistry().registerViewFactory(
                android_view_id, new PlatformViewFactory(StandardMessageCodec.INSTANCE) {
                    @NonNull
                    @Override
                    public PlatformView create(Context context, int viewId, @Nullable Object args) {
                        Log.d(TAG, "Building android native camera view");
                        return new PlatformView() {
                            @NonNull
                            @Override
                            public View getView() {
                                return cameraViewBinding.getRoot();
                            }

                            @Override
                            public void dispose() {
                                Log.d(TAG, "Disposing camera view");
                                disposeView();
                            }
                        };
                    }
                }
        );

        setUpCameraApi();

        binding.getActivity().getApplication().registerActivityLifecycleCallbacks(new Application.ActivityLifecycleCallbacks() {
            @Override
            public void onActivityCreated(@NonNull Activity activity, @Nullable Bundle savedInstanceState) {
            }

            @Override
            public void onActivityStarted(@NonNull Activity activity) {
                Log.d(TAG + "_ACTIVITY_START", "Start activity");
                if (ContextCompat.checkSelfPermission(activity, Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED) {
                    ActivityCompat.requestPermissions(activity, new String[]{Manifest.permission.CAMERA}, 50);
                }
            }

            @Override
            public void onActivityResumed(@NonNull Activity activity) {
                Log.d(TAG + "_ACTIVITY_RESUME", "Resume activity");
                if (cameraView != null) {
                    cameraView.onResume();
                }
            }

            @Override
            public void onActivityPaused(@NonNull Activity activity) {
                Log.d(TAG + "_ACTIVITY_PAUSE", "Pause activity");
                if (cameraView != null) {
                    cameraView.onPause();
                }
            }

            @Override
            public void onActivityStopped(@NonNull Activity activity) {
                Log.d(TAG + "_ACTIVITY_STOP", "Stop activity");
                if (cameraView != null) {
                    cameraView.onPause();
                }

            }

            @Override
            public void onActivitySaveInstanceState(@NonNull Activity activity, @NonNull Bundle outState) {
            }

            @Override
            public void onActivityDestroyed(@NonNull Activity activity) {
                Log.d(TAG + "_ACTIVITY_DESTROY", "Destroy activity");
                if (cameraView != null) {
                    cameraView.onPause();
                }
            }
        });
    }

    private void disposeView() {
        Log.d(TAG, "Disposing the view");
        cameraViewBinding.cameraView.onPause();

        if (cameraScanModel != null) {
            cameraScanModel.cancelObservers(activity);
            cameraScanModel = null;
        }
        if (cameraViewBinding.getRoot().getParent() != null) {
            ((ViewGroup) cameraViewBinding.getRoot().getParent()).removeView(cameraViewBinding.getRoot());
        }
    }

    @Override
    public boolean onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        ContextCompat.checkSelfPermission(activity, Manifest.permission.CAMERA);
        return true;
    }

    private void setUpCameraApi() {
        Log.d(TAG, "Setting up CameraApi");
        CameraApiInterface.CameraApi.setUp(flutterPluginBinding.getBinaryMessenger(), new CameraApiInterface.CameraApi() {
            @Override
            public void dispose() {
                cameraView.onPause();
            }

            @Override
            public void initialize(@NonNull CameraApiInterface.FlashState flashState, @NonNull Double flashTorchLevel, @NonNull CameraApiInterface.VoidResult result) {
                cameraScanModel = new CameraScanModel(activity, flashState, flashTorchLevel);
                if (ContextCompat.checkSelfPermission(activity, Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED) {
                    ActivityCompat.requestPermissions(activity, new String[]{Manifest.permission.CAMERA}, 50);
                }
                activity.runOnUiThread(() -> setupCamera());
                result.success();
            }

            @Override
            public void takePicture(@NonNull CameraApiInterface.Result<byte[]> result) {

            }

            @Override
            public void setZoomLevel(@NonNull Double zoomLevel) {
                cameraView.changeZoomLevel(zoomLevel.intValue());
            }

            @NonNull
            @Override
            public Double getCurrentZoomLevel() {
                return (double) cameraView.getCurrentZoom();
            }

            @NonNull
            @Override
            public Double getMinimumZoomLevel() {
                return (double) cameraView.getMinZoom();
            }

            @NonNull
            @Override
            public Double getMaximumZoomLevel() {
                return (double) cameraView.getMaxZoom();
            }

            @Override
            public void setFlashStatus(@NonNull Boolean isActive) {
                cameraView.changeFlashState(isActive);
            }

            @NonNull
            @Override
            public Boolean getFlashStatus() {
                return cameraView.isFlashEnabled();
            }

            @NonNull
            @Override
            public String getPlatformVersion() {
                return "Android " + android.os.Build.VERSION.RELEASE;
            }
        });
    }

    private void setupCamera() {
        cameraScanModel.getStreamBitmapObserver().observe((LifecycleOwner) activity, bitmap -> {
            Log.d(TAG, "Bitmap obtained");
        });
        cameraScanModel.getBarcodeResultObserver().observe((LifecycleOwner) activity, barcodeResult -> {
            Log.d(TAG, "Barcode result obtained");
        });
        cameraScanModel.getExceptionObserver().observe((LifecycleOwner) activity, exception -> {
            Log.d(TAG, "Exception obtained");
        });
        cameraView = cameraViewBinding.cameraView;
        cameraScanModel.initCamera(activity, cameraView);
    }
    @Override
    public void onDetachedFromActivityForConfigChanges() {
        Log.d(TAG, "Detaching activity config changes");
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        Log.d(TAG, "Reattaching activity");
    }

    @Override
    public void onDetachedFromActivity() {
        Log.d(TAG, "Detaching activity");
        disposeView();
        activity = null;
        activityPluginBinding = null;
    }
}
