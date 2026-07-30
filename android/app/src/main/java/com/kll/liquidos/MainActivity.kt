package com.kll.liquidos

import android.app.WallpaperManager
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.net.wifi.WifiManager
import android.bluetooth.BluetoothAdapter
import android.os.BatteryManager
import android.os.Environment
import android.os.StatFs
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.kll.liquidos/launcher"
    private val fileSystemBridge by lazy { FileSystemBridge(applicationContext) }
    private val mediaBridge by lazy { MediaBridge(applicationContext) }
    private val systemControlsBridge by lazy { SystemControlsBridge(applicationContext) }
    private val CODING_APPS = setOf(
        "com.termux",
        "io.github.acode",
        "com.spck.editor",
        "com.github.mobile",
        "com.mixplorer",
        "com.cxxdroid",
        "ru.nsu.bobrovnikov.cxxdroid",
        "com.kll.liquidos"
    )

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isDefaultLauncher" -> result.success(isDefaultLauncher())
                    "openHomeSettings" -> {
                        openHomeSettings()
                        result.success(true)
                    }
                    "launchApp" -> {
                        val packageName = call.argument<String>("packageName")
                        if (packageName != null) {
                            result.success(launchApp(packageName))
                        } else {
                            result.success(false)
                        }
                    }
                    "getInstalledApps" -> {
                        result.success(getInstalledApps())
                    }
                    "getAppIconBytes" -> {
                        val pkg = call.argument<String>("packageName") ?: ""
                        result.success(getAppIconBytes(pkg))
                    }
                    "getSystemMetrics" -> {
                        result.success(getSystemMetrics())
                    }
                    "openSettingsSection" -> {
                        val section = call.argument<String>("section")
                        if (section != null) {
                            openSettingsSection(section)
                        }
                        result.success(true)
                    }

                    // --- File System ---
                    "hasFullStorageAccess" -> result.success(fileSystemBridge.hasFullStorageAccess())
                    "requestFullStorageAccess" -> {
                        fileSystemBridge.requestFullStorageAccess()
                        result.success(true)
                    }
                    "listDirectory" -> {
                        val path = call.argument<String>("path") ?: ""
                        result.success(fileSystemBridge.listDirectory(path))
                    }
                    "getRootPath" -> result.success(fileSystemBridge.getRootPath())
                    "createFolder" -> {
                        val parent = call.argument<String>("parentPath") ?: ""
                        val name = call.argument<String>("name") ?: "New Folder"
                        result.success(fileSystemBridge.createFolder(parent, name))
                    }
                    "renameFile" -> {
                        val path = call.argument<String>("path") ?: ""
                        val newName = call.argument<String>("newName") ?: ""
                        result.success(fileSystemBridge.rename(path, newName))
                    }
                    "copyFile" -> {
                        val src = call.argument<String>("sourcePath") ?: ""
                        val dest = call.argument<String>("destDirPath") ?: ""
                        result.success(fileSystemBridge.copy(src, dest))
                    }
                    "moveFile" -> {
                        val src = call.argument<String>("sourcePath") ?: ""
                        val dest = call.argument<String>("destDirPath") ?: ""
                        result.success(fileSystemBridge.move(src, dest))
                    }
                    "moveToTrash" -> {
                        val path = call.argument<String>("path") ?: ""
                        result.success(fileSystemBridge.moveToTrash(path))
                    }
                    "listTrash" -> result.success(fileSystemBridge.listTrash())
                    "restoreFromTrash" -> {
                        val path = call.argument<String>("path") ?: ""
                        result.success(fileSystemBridge.restoreFromTrash(path))
                    }
                    "permanentlyDelete" -> {
                        val path = call.argument<String>("path") ?: ""
                        result.success(fileSystemBridge.permanentlyDelete(path))
                    }
                    "emptyTrash" -> result.success(fileSystemBridge.emptyTrash())
                    "openFile" -> {
                        val path = call.argument<String>("path") ?: ""
                        result.success(fileSystemBridge.openFile(path))
                    }

                    // --- Media / Gallery / Wallpaper ---
                    "getAllImages" -> result.success(mediaBridge.getAllImages())
                    "setWallpaper" -> {
                        val uriOrPath = call.argument<String>("uriOrPath") ?: ""
                        result.success(mediaBridge.setWallpaper(uriOrPath))
                    }
                    "readImageBytes" -> {
                        val uriOrPath = call.argument<String>("uriOrPath") ?: ""
                        val maxDimension = call.argument<Int>("maxDimension") ?: 512
                        result.success(mediaBridge.readImageBytes(uriOrPath, maxDimension))
                    }

                    // --- System Controls ---
                    "canWriteSettings" -> result.success(systemControlsBridge.canWriteSettings())
                    "requestWriteSettingsPermission" -> {
                        systemControlsBridge.requestWriteSettingsPermission()
                        result.success(true)
                    }
                    "setBrightness" -> {
                        val value = call.argument<Double>("value") ?: 0.7
                        result.success(systemControlsBridge.setBrightness(value))
                    }
                    "getBrightness" -> result.success(systemControlsBridge.getBrightness())
                    "setFlashlight" -> {
                        val on = call.argument<Boolean>("on") ?: false
                        result.success(systemControlsBridge.setFlashlight(on))
                    }

                    // --- Notifications ---
                    "isNotificationAccessGranted" -> {
                        result.success(NotificationListener.isListenerConnected(applicationContext))
                    }
                    "requestNotificationAccess" -> {
                        try {
                            val intent = Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS)
                            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                            startActivity(intent)
                        } catch (e: Exception) {
                            // ignore
                        }
                        result.success(true)
                    }
                    "getNotifications" -> {
                        result.success(NotificationListener.getCachedNotifications())
                    }
                    "dismissNotification" -> {
                        val key = call.argument<String>("key") ?: ""
                        NotificationListener.requestDismiss(key)
                        result.success(true)
                    }

                    else -> result.notImplemented()
                }
            }
    }

    private fun isDefaultLauncher(): Boolean {
        val intent = Intent(Intent.ACTION_MAIN).apply {
            addCategory(Intent.CATEGORY_HOME)
        }
        val resolveInfo = packageManager.resolveActivity(intent, PackageManager.MATCH_DEFAULT_ONLY)
        return resolveInfo?.activityInfo?.packageName == packageName
    }

    private fun openHomeSettings() {
        try {
            val intent = Intent(Settings.ACTION_HOME_SETTINGS)
            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            startActivity(intent)
        } catch (e: Exception) {
            // Fallback: open app details
            try {
                val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
                intent.data = android.net.Uri.fromParts("package", packageName, null)
                intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                startActivity(intent)
            } catch (e2: Exception) {
                // Last resort: open general settings
                val intent = Intent(Settings.ACTION_SETTINGS)
                intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                startActivity(intent)
            }
        }
    }

    private fun launchApp(packageName: String): Boolean {
        return try {
            val intent = packageManager.getLaunchIntentForPackage(packageName)
            if (intent != null) {
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_REORDER_TO_FRONT)
                startActivity(intent)
                true
            } else {
                false
            }
        } catch (e: Exception) {
            false
        }
    }

    private fun getInstalledApps(): List<Map<String, Any>> {
        val pm = packageManager
        val apps = mutableListOf<Map<String, Any>>()
        val intent = Intent(Intent.ACTION_MAIN, null).apply {
            addCategory(Intent.CATEGORY_LAUNCHER)
        }

        val resolveInfos = pm.queryIntentActivities(intent, PackageManager.MATCH_DEFAULT_ONLY)
        for (info in resolveInfos) {
            val pkgName = info.activityInfo.packageName
            // Skip self
            if (pkgName == packageName) continue

            val appName = try {
                info.loadLabel(pm).toString()
            } catch (e: Exception) {
                pkgName
            }

            val category = categorizeApp(pkgName, appName)
            val isCoding = CODING_APPS.contains(pkgName)

            apps.add(mapOf(
                "packageName" to pkgName,
                "appName" to appName,
                "category" to category,
                "isCodingApp" to isCoding
            ))
        }

        return apps.sortedBy { it["appName"] as String }
    }

    /**
     * Extracts a real app's launcher icon as PNG bytes. Flutter has no way to
     * render a native Drawable directly, so we rasterize it here and hand back
     * bytes for Image.memory on the Dart side — same pattern as gallery thumbnails.
     */
    private fun getAppIconBytes(packageName: String): ByteArray? {
        return try {
            val drawable = packageManager.getApplicationIcon(packageName)
            val size = 128
            val bitmap = android.graphics.Bitmap.createBitmap(
                size, size, android.graphics.Bitmap.Config.ARGB_8888
            )
            val canvas = android.graphics.Canvas(bitmap)
            drawable.setBounds(0, 0, size, size)
            drawable.draw(canvas)

            val stream = java.io.ByteArrayOutputStream()
            bitmap.compress(android.graphics.Bitmap.CompressFormat.PNG, 100, stream)
            stream.toByteArray()
        } catch (e: Exception) {
            null
        }
    }

    private fun categorizeApp(packageName: String, appName: String): String {
        val pkgLower = packageName.lowercase()
        val nameLower = appName.lowercase()

        return when {
            pkgLower.contains("termux") || pkgLower.contains("terminal") -> "Terminal"
            pkgLower.contains("editor") || pkgLower.contains("code") -> "Code Editor"
            pkgLower.contains("github") || pkgLower.contains("git") -> "Git Client"
            pkgLower.contains("chrome") || pkgLower.contains("firefox") || pkgLower.contains("browser") -> "Web Browser"
            pkgLower.contains("filemanager") || pkgLower.contains("mixplorer") || pkgLower.contains("explorer") -> "Utilities"
            pkgLower.contains("camera") -> "Camera"
            pkgLower.contains("gallery") || pkgLower.contains("photo") -> "Photos"
            pkgLower.contains("music") || pkgLower.contains("player") -> "Media"
            pkgLower.contains("video") -> "Media"
            pkgLower.contains("mail") || pkgLower.contains("email") -> "Communication"
            pkgLower.contains("chat") || pkgLower.contains("message") || pkgLower.contains("whatsapp") -> "Communication"
            pkgLower.contains("calendar") -> "Productivity"
            pkgLower.contains("clock") || pkgLower.contains("alarm") -> "Utilities"
            pkgLower.contains("setting") -> "System"
            pkgLower.contains("play") || pkgLower.contains("store") -> "System"
            nameLower.contains("calculator") -> "Utilities"
            nameLower.contains("notes") || nameLower.contains("memo") -> "Productivity"
            nameLower.contains("weather") -> "Utilities"
            else -> "General"
        }
    }

    private fun getSystemMetrics(): Map<String, Any> {
        val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
        val batteryLevel = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
        val isCharging = batteryManager.isCharging

        val wifiManager = applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
        val wifiEnabled = wifiManager.isWifiEnabled

        val bluetoothAdapter = BluetoothAdapter.getDefaultAdapter()
        val bluetoothEnabled = bluetoothAdapter?.isEnabled ?: false

        // RAM usage
        val runtime = Runtime.getRuntime()
        val usedMemory = runtime.totalMemory() - runtime.freeMemory()
        val maxMemory = runtime.maxMemory()
        val ramPercent = (usedMemory.toDouble() / maxMemory.toDouble() * 100.0)

        // Storage usage
        val stat = StatFs(Environment.getDataDirectory().path)
        val totalStorage = stat.totalBytes.toDouble()
        val availableStorage = stat.availableBytes.toDouble()
        val usedStoragePercent = ((totalStorage - availableStorage) / totalStorage * 100.0)

        return mapOf(
            "batteryLevel" to batteryLevel,
            "isCharging" to isCharging,
            "wifiEnabled" to wifiEnabled,
            "bluetoothEnabled" to bluetoothEnabled,
            "ramUsagePercent" to ramPercent,
            "storageUsagePercent" to usedStoragePercent
        )
    }

    private fun openSettingsSection(section: String) {
        try {
            val intent = when (section) {
                "wifi" -> Intent(Settings.ACTION_WIFI_SETTINGS)
                "bluetooth" -> Intent(Settings.ACTION_BLUETOOTH_SETTINGS)
                "display" -> Intent(Settings.ACTION_DISPLAY_SETTINGS)
                "sound" -> Intent(Settings.ACTION_SOUND_SETTINGS)
                "battery" -> Intent(Settings.ACTION_BATTERY_SAVER_SETTINGS)
                "storage" -> Intent(Settings.ACTION_INTERNAL_STORAGE_SETTINGS)
                else -> Intent(Settings.ACTION_SETTINGS)
            }
            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            startActivity(intent)
        } catch (e: Exception) {
            val intent = Intent(Settings.ACTION_SETTINGS)
            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            startActivity(intent)
        }
    }
}
