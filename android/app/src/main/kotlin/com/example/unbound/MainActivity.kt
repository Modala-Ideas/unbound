package com.modalaideas.unbound

import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.FlutterActivityLaunchConfigs.BackgroundMode
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.modalaideas.unbound/launcher"

    override fun getBackgroundMode(): BackgroundMode {
        return BackgroundMode.transparent
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "expandNotificationsPanel" -> {
                    try {
                        @Suppress("WrongConstant")
                        val statusBarService = getSystemService("statusbar")
                        val statusBarManager = Class.forName("android.app.StatusBarManager")
                        val method = statusBarManager.getMethod("expandNotificationsPanel")
                        method.invoke(statusBarService)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("UNAVAILABLE", "Could not expand notifications panel", e.message)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
