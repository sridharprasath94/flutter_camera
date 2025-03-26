package com.flashandroid.native_camera_controller_android;

import android.graphics.Bitmap;

import java.io.ByteArrayOutputStream;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import android.util.Log;

public class BitmapUtils {
    private static final ExecutorService executor = Executors.newSingleThreadExecutor();
    private final static String TAG = "NATIVE_CAMERA_CONTROLLER_ANDROID_CAMERA";

    public static void convertBitmapToByteArrayAsync(Bitmap bitmap, CameraApiInterface.Result<byte[]> result) {
        executor.execute(() -> {
            if (bitmap == null) {
                return;
            }

            long startTime = System.currentTimeMillis();

            ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
            bitmap.compress(Bitmap.CompressFormat.JPEG, 100, outputStream);
            byte[] byteArray = outputStream.toByteArray();

            long endTime = System.currentTimeMillis();
            long duration = endTime - startTime;

            Log.d(TAG, "Time taken for conversion: " + duration + " ms");

            result.success(byteArray);
        });
    }
}
