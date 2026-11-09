package com.example.reus_tarragona_bus

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // L'app avvisa il widget quando ha preparato nuovi orari.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "app.lumelabs.bustarragona/widget")
            .setMethodCallHandler { call, result ->
                if (call.method == "refresh") {
                    NextBusWidgetProvider.refreshAll(applicationContext)
                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }
    }
}
