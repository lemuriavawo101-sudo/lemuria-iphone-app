package com.example.lemuria_telecaller_app

import android.content.Intent
import android.net.Uri
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.lemuria.telecaller/call"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "directCall") {
                val phoneNumber = call.argument<String>("phoneNumber") ?: ""
                val cleanNumber = phoneNumber.replace(Regex("[^0-9+]"), "")
                
                if (ContextCompat.checkSelfPermission(this, android.Manifest.permission.CALL_PHONE) != PackageManager.PERMISSION_GRANTED) {
                    ActivityCompat.requestPermissions(this, arrayOf(android.Manifest.permission.CALL_PHONE), 101)
                    // Fallback to DIAL if permission not yet granted by user
                    val dialIntent = Intent(Intent.ACTION_DIAL, Uri.parse("tel:$cleanNumber"))
                    startActivity(dialIntent)
                    result.success(false)
                } else {
                    // DIRECT 1-TAP CALL (No second button press needed!)
                    val callIntent = Intent(Intent.ACTION_CALL, Uri.parse("tel:$cleanNumber"))
                    startActivity(callIntent)
                    result.success(true)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
