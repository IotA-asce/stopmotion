package com.iotaasce.stopmotion

import android.os.StatFs
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "stop_motion/storage")
            .setMethodCallHandler { call, result ->
                if (call.method == "availableStorageBytes") {
                    val path = call.argument<String>("path") ?: filesDir.absolutePath
                    result.success(StatFs(path).availableBytes)
                } else {
                    result.notImplemented()
                }
            }
    }
}
