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
                "getWorkApps" -> {
                    Thread {
                        try {
                            val context = context
                            val launcherApps = context.getSystemService(Context.LAUNCHER_APPS_SERVICE) as android.content.pm.LauncherApps
                            val userManager = context.getSystemService(Context.USER_SERVICE) as android.os.UserManager
                            val profiles = userManager.userProfiles
                            val currentProfile = android.os.Process.myUserHandle()
                            
                            val workApps = mutableListOf<Map<String, Any>>()
                            
                            for (profile in profiles) {
                                if (profile == currentProfile) continue
                                
                                val activities = launcherApps.getActivityList(null, profile)
                                for (activity in activities) {
                                    val appMap = mutableMapOf<String, Any>()
                                    appMap["appName"] = activity.label.toString()
                                    appMap["packageName"] = activity.applicationInfo.packageName
                                    appMap["isWork"] = true
                                    
                                    // Icon
                                    try {
                                        val iconDrawable = activity.getBadgedIcon(0)
                                        val bitmap = drawableToBitmap(iconDrawable)
                                        val stream = java.io.ByteArrayOutputStream()
                                        bitmap.compress(android.graphics.Bitmap.CompressFormat.PNG, 100, stream)
                                        appMap["icon"] = stream.toByteArray()
                                    } catch (e: Exception) {
                                        // Ignore icon error
                                    }
                                    
                                    workApps.add(appMap)
                                }
                            }
                            
                            runOnUiThread {
                                result.success(workApps)
                            }
                        } catch (e: Exception) {
                            runOnUiThread {
                                result.error("ERROR", e.message, null)
                            }
                        }
                    }.start()
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun drawableToBitmap(drawable: android.graphics.drawable.Drawable): android.graphics.Bitmap {
        if (drawable is android.graphics.drawable.BitmapDrawable) {
            return drawable.bitmap
        }
        val width = if (drawable.intrinsicWidth > 0) drawable.intrinsicWidth else 1
        val height = if (drawable.intrinsicHeight > 0) drawable.intrinsicHeight else 1
        val bitmap = android.graphics.Bitmap.createBitmap(
            width,
            height,
            android.graphics.Bitmap.Config.ARGB_8888
        )
        val canvas = android.graphics.Canvas(bitmap)
        drawable.setBounds(0, 0, canvas.width, canvas.height)
        drawable.draw(canvas)
        return bitmap
    }
}
