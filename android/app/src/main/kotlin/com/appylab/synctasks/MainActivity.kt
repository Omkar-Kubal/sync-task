package com.appylab.synctasks

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.provider.MediaStore
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private var pendingPhotoResult: MethodChannel.Result? = null
    private var pendingPhotoFile: File? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            RECEIPT_PHOTO_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "capturePhoto" -> captureReceiptPhoto(result)
                else -> result.notImplemented()
            }
        }
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != RECEIPT_PHOTO_REQUEST_CODE) {
            return
        }

        val result = pendingPhotoResult ?: return
        val file = pendingPhotoFile
        pendingPhotoResult = null
        pendingPhotoFile = null

        if (resultCode == Activity.RESULT_OK && file != null && file.exists()) {
            result.success(file.absolutePath)
        } else {
            file?.delete()
            result.success(null)
        }
    }

    private fun captureReceiptPhoto(result: MethodChannel.Result) {
        if (pendingPhotoResult != null) {
            result.error("camera_busy", "Camera capture is already in progress.", null)
            return
        }

        val intent = Intent(MediaStore.ACTION_IMAGE_CAPTURE)
        if (intent.resolveActivity(packageManager) == null) {
            result.error("camera_unavailable", "No camera app is available.", null)
            return
        }

        val photoDirectory = File(filesDir, "receipt_photos").apply { mkdirs() }
        val photoFile = File.createTempFile(
            "receipt_${System.currentTimeMillis()}_",
            ".jpg",
            photoDirectory,
        )
        val photoUri = FileProvider.getUriForFile(
            this,
            "${applicationContext.packageName}.receipt_photo_provider",
            photoFile,
        )

        intent.putExtra(MediaStore.EXTRA_OUTPUT, photoUri)
        intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        intent.addFlags(Intent.FLAG_GRANT_WRITE_URI_PERMISSION)
        grantCameraUriPermissions(intent, photoUri)

        pendingPhotoResult = result
        pendingPhotoFile = photoFile
        try {
            startActivityForResult(intent, RECEIPT_PHOTO_REQUEST_CODE)
        } catch (error: Exception) {
            pendingPhotoResult = null
            pendingPhotoFile = null
            photoFile.delete()
            result.error("camera_unavailable", "Could not open the camera.", null)
        }
    }

    private fun grantCameraUriPermissions(intent: Intent, uri: Uri) {
        val activities = packageManager.queryIntentActivities(intent, 0)
        for (activity in activities) {
            grantUriPermission(
                activity.activityInfo.packageName,
                uri,
                Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION,
            )
        }
    }

    companion object {
        private const val RECEIPT_PHOTO_CHANNEL = "com.appylab.synctasks/receipts/photo"
        private const val RECEIPT_PHOTO_REQUEST_CODE = 4207
    }
}

