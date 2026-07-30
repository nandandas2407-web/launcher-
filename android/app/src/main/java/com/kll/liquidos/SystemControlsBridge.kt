package com.kll.liquidos

import android.content.Context
import android.content.Intent
import android.hardware.camera2.CameraManager
import android.net.Uri
import android.provider.Settings

/** Real brightness and flashlight control, backing the Control Center sliders/toggles. */
class SystemControlsBridge(private val context: Context) {

    private var torchOn = false
    private var cameraId: String? = null

    private fun cameraManager(): CameraManager =
        context.getSystemService(Context.CAMERA_SERVICE) as CameraManager

    private fun resolveCameraId(): String? {
        if (cameraId != null) return cameraId
        return try {
            val manager = cameraManager()
            for (id in manager.cameraIdList) {
                val hasFlash = manager.getCameraCharacteristics(id)
                    .get(android.hardware.camera2.CameraCharacteristics.FLASH_INFO_AVAILABLE)
                if (hasFlash == true) {
                    cameraId = id
                    return id
                }
            }
            null
        } catch (e: Exception) {
            null
        }
    }

    /** True if this app currently holds the WRITE_SETTINGS grant (needed for brightness). */
    fun canWriteSettings(): Boolean {
        return Settings.System.canWrite(context)
    }

    fun requestWriteSettingsPermission() {
        try {
            val intent = Intent(Settings.ACTION_MANAGE_WRITE_SETTINGS)
            intent.data = Uri.parse("package:${context.packageName}")
            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            context.startActivity(intent)
        } catch (e: Exception) {
            // ignore
        }
    }

    /** value: 0.0..1.0 */
    fun setBrightness(value: Double): Boolean {
        if (!canWriteSettings()) return false
        return try {
            val level = (value.coerceIn(0.0, 1.0) * 255).toInt()
            Settings.System.putInt(
                context.contentResolver,
                Settings.System.SCREEN_BRIGHTNESS,
                level
            )
            true
        } catch (e: Exception) {
            false
        }
    }

    fun getBrightness(): Double {
        return try {
            val level = Settings.System.getInt(
                context.contentResolver,
                Settings.System.SCREEN_BRIGHTNESS
            )
            level / 255.0
        } catch (e: Exception) {
            0.7
        }
    }

    fun setFlashlight(on: Boolean): Boolean {
        val id = resolveCameraId() ?: return false
        return try {
            cameraManager().setTorchMode(id, on)
            torchOn = on
            true
        } catch (e: Exception) {
            false
        }
    }

    fun isFlashlightOn(): Boolean = torchOn
}
