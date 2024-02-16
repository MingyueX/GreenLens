package com.cleeg.greenlens

import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.chaquo.python.PyException
import com.google.ar.core.ArCoreApk
import android.os.Handler

class MainActivity : FlutterActivity() {
    private var mUserRequestedInstall = true

    companion object {
        private const val CHANNEL = "com.example.tree/torch_model"
        private const val ARCORE_CHANNEL = "com.example.tree/arcore"
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "initialize_model" -> {
                    PyTorchMobile.getInstance(applicationContext)
                    result.success(null)
                }
                "process_image" -> {
                    try {
                        val processor = ImageProcessor(this@MainActivity)
                        val rgbMat = call.argument<ByteArray>("rgbMat")!!
                        val depthArr = call.argument<List<Double>>("depthArr")!!
                        val depthWidth = call.argument<Int>("depthWidth")!!
                        val depthHeight = call.argument<Int>("depthHeight")!!
                        val res = processor.processImage(rgbMat, depthArr, depthWidth, depthHeight)
                        result.success(res)
                    } catch (e: PyException) {
                        val (errorType, errorMessage) = e.message?.split(":", limit = 2) ?: listOf("UnknownError", e.message ?: "Unknown Message")
                        Log.d("MainActivity", "Error: $errorType, $errorMessage")
                        result.error(errorType.trim(), errorMessage?.trim(), e.stackTrace.joinToString("\n"))
                    }
                }

                else -> result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, ARCORE_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "arcore_check" -> {
                    arcoreCheck(result)
                }
                "arcore_installation" -> {
                    arcoreInstall(result)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun arcoreCheck(result: MethodChannel.Result) {
        val availability = ArCoreApk.getInstance().checkAvailability(this@MainActivity)
        if (availability.isTransient) {
            // Re-query at 5Hz while compatibility is checked in the background.
            Handler().postDelayed({
                arcoreCheck(result)
            }, 200)
        } else if (availability == ArCoreApk.Availability.SUPPORTED_INSTALLED) {
            result.success(true)
        } else if (availability.isSupported) {
            result.success(false)
        } else {
            result.error("ARCoreNotSupported", "ARCore is not supported on this device.", null)
        }
    }

    private fun arcoreInstall(result: MethodChannel.Result) {
        val availability = ArCoreApk.getInstance().checkAvailability(this@MainActivity)
        if (availability.isTransient) {
            // Re-query at 5Hz while compatibility is checked in the background.
            Handler().postDelayed({
                arcoreInstall(result)
            }, 200)
        } else if (availability == ArCoreApk.Availability.SUPPORTED_INSTALLED) {
            result.success(true)
        } else if (availability.isSupported) {
            mUserRequestedInstall = true
            try {
                when (ArCoreApk.getInstance().requestInstall(this, mUserRequestedInstall)) {
                    ArCoreApk.InstallStatus.INSTALLED -> {
                        result.success(true)
                    }
                    ArCoreApk.InstallStatus.INSTALL_REQUESTED -> {
                        mUserRequestedInstall = false
                        result.success(false)
                    }
                }
            } catch (e: Exception) {
                result.error("INSTALL_ERROR", e.message, null)
            }
        } else {
            result.success(false)
        }
    }
}