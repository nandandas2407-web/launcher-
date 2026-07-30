package com.kll.liquidos

import android.app.WallpaperManager
import android.content.Context
import android.graphics.BitmapFactory
import android.net.Uri
import android.provider.MediaStore
import java.io.File
import java.io.FileInputStream

/**
 * Scans device photos via MediaStore (shared by Gallery viewer and Wallpaper picker)
 * and applies a chosen image as the real Android wallpaper.
 */
class MediaBridge(private val context: Context) {

    /** Returns all images visible to MediaStore, newest first. */
    fun getAllImages(): List<Map<String, Any>> {
        val images = mutableListOf<Map<String, Any>>()
        val projection = arrayOf(
            MediaStore.Images.Media._ID,
            MediaStore.Images.Media.DATA,
            MediaStore.Images.Media.DISPLAY_NAME,
            MediaStore.Images.Media.DATE_ADDED,
            MediaStore.Images.Media.BUCKET_DISPLAY_NAME
        )
        val sortOrder = "${MediaStore.Images.Media.DATE_ADDED} DESC"

        val cursor = context.contentResolver.query(
            MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
            projection, null, null, sortOrder
        )

        cursor?.use {
            val idCol = it.getColumnIndexOrThrow(MediaStore.Images.Media._ID)
            val dataCol = it.getColumnIndexOrThrow(MediaStore.Images.Media.DATA)
            val nameCol = it.getColumnIndexOrThrow(MediaStore.Images.Media.DISPLAY_NAME)
            val dateCol = it.getColumnIndexOrThrow(MediaStore.Images.Media.DATE_ADDED)
            val bucketCol = it.getColumnIndexOrThrow(MediaStore.Images.Media.BUCKET_DISPLAY_NAME)

            while (it.moveToNext()) {
                val id = it.getLong(idCol)
                val contentUri = Uri.withAppendedPath(
                    MediaStore.Images.Media.EXTERNAL_CONTENT_URI, id.toString()
                )
                images.add(
                    mapOf(
                        "id" to id,
                        "uri" to contentUri.toString(),
                        "path" to (it.getString(dataCol) ?: ""),
                        "name" to (it.getString(nameCol) ?: "Image"),
                        "dateAdded" to it.getLong(dateCol),
                        "album" to (it.getString(bucketCol) ?: "Gallery")
                    )
                )
            }
        }
        return images
    }

    /** Applies an image (by content URI string or file path) as the real system wallpaper. */
    fun setWallpaper(uriOrPath: String): Boolean {
        return try {
            val wallpaperManager = WallpaperManager.getInstance(context)
            val bitmap = if (uriOrPath.startsWith("content://")) {
                val inputStream = context.contentResolver.openInputStream(Uri.parse(uriOrPath))
                BitmapFactory.decodeStream(inputStream)
            } else {
                val inputStream = FileInputStream(File(uriOrPath))
                BitmapFactory.decodeStream(inputStream)
            }
            if (bitmap != null) {
                wallpaperManager.setBitmap(bitmap)
                true
            } else {
                false
            }
        } catch (e: Exception) {
            false
        }
    }

    /**
     * Reads an image (content:// URI or file path) and returns JPEG-encoded bytes,
     * downscaled to [maxDimension] on the longest side. Flutter's Image.network can't
     * load content:// URIs directly, so the UI calls this and renders via Image.memory.
     */
    fun readImageBytes(uriOrPath: String, maxDimension: Int): ByteArray? {
        return try {
            val rawBitmap = if (uriOrPath.startsWith("content://")) {
                val inputStream = context.contentResolver.openInputStream(Uri.parse(uriOrPath))
                BitmapFactory.decodeStream(inputStream)
            } else {
                val inputStream = FileInputStream(File(uriOrPath))
                BitmapFactory.decodeStream(inputStream)
            } ?: return null

            val scale = maxDimension.toFloat() / maxOf(rawBitmap.width, rawBitmap.height)
            val bitmap = if (scale < 1.0f) {
                android.graphics.Bitmap.createScaledBitmap(
                    rawBitmap,
                    (rawBitmap.width * scale).toInt().coerceAtLeast(1),
                    (rawBitmap.height * scale).toInt().coerceAtLeast(1),
                    true
                )
            } else {
                rawBitmap
            }

            val stream = java.io.ByteArrayOutputStream()
            bitmap.compress(android.graphics.Bitmap.CompressFormat.JPEG, 85, stream)
            stream.toByteArray()
        } catch (e: Exception) {
            null
        }
    }
}
