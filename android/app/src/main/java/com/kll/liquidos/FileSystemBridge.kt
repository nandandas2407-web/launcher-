package com.kll.liquidos

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.Settings
import androidx.core.content.FileProvider
import java.io.File
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/**
 * Handles all real filesystem access for the File Manager: listing, navigation,
 * rename/copy/move, and a soft-delete "Trash" implemented as a hidden folder
 * (Android has no OS-level trash API for arbitrary files, so we emulate one).
 */
class FileSystemBridge(private val context: Context) {

    companion object {
        // Hidden trash folder at the root of external storage.
        const val TRASH_DIR_NAME = ".liquidos_trash"
    }

    private fun trashDir(): File {
        val dir = File(Environment.getExternalStorageDirectory(), TRASH_DIR_NAME)
        if (!dir.exists()) dir.mkdirs()
        return dir
    }

    /** True if the app currently holds full storage access. */
    fun hasFullStorageAccess(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            android.os.Environment.isExternalStorageManager()
        } else {
            true // Below API 30, normal READ/WRITE_EXTERNAL_STORAGE covers this (requested separately)
        }
    }

    /** Opens the system "All files access" grant screen for this app. */
    fun requestFullStorageAccess() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            try {
                val intent = Intent(Settings.ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION)
                intent.data = Uri.parse("package:${context.packageName}")
                intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                context.startActivity(intent)
            } catch (e: Exception) {
                val intent = Intent(Settings.ACTION_MANAGE_ALL_FILES_ACCESS_PERMISSION)
                intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                context.startActivity(intent)
            }
        }
    }

    fun listDirectory(path: String): List<Map<String, Any>> {
        val dir = if (path.isEmpty()) Environment.getExternalStorageDirectory() else File(path)
        if (!dir.exists() || !dir.isDirectory) return emptyList()

        val entries = dir.listFiles() ?: return emptyList()
        val dateFormat = SimpleDateFormat("yyyy-MM-dd HH:mm", Locale.getDefault())

        return entries
            .filter { it.name != TRASH_DIR_NAME } // hide our trash folder from normal browsing
            .map { f ->
                mapOf(
                    "name" to f.name,
                    "path" to f.absolutePath,
                    "isDirectory" to f.isDirectory,
                    "sizeBytes" to (if (f.isDirectory) 0L else f.length()),
                    "modified" to dateFormat.format(Date(f.lastModified())),
                    "extension" to (if (f.isDirectory) "" else f.extension.lowercase())
                )
            }
            .sortedWith(compareByDescending<Map<String, Any>> { it["isDirectory"] as Boolean }
                .thenBy { (it["name"] as String).lowercase() })
    }

    fun getRootPath(): String = Environment.getExternalStorageDirectory().absolutePath

    fun createFolder(parentPath: String, name: String): Boolean {
        val newDir = File(parentPath, name)
        return newDir.mkdirs()
    }

    fun rename(path: String, newName: String): Boolean {
        val file = File(path)
        val target = File(file.parentFile, newName)
        return file.renameTo(target)
    }

    fun copy(sourcePath: String, destDirPath: String): Boolean {
        return try {
            val source = File(sourcePath)
            val dest = File(destDirPath, source.name)
            if (source.isDirectory) {
                source.copyRecursively(dest, overwrite = true)
            } else {
                source.copyTo(dest, overwrite = true)
            }
            true
        } catch (e: Exception) {
            false
        }
    }

    fun move(sourcePath: String, destDirPath: String): Boolean {
        return try {
            val source = File(sourcePath)
            val dest = File(destDirPath, source.name)
            val ok = source.renameTo(dest)
            if (!ok) {
                // Fallback across filesystems/volumes: copy then delete
                if (source.isDirectory) {
                    source.copyRecursively(dest, overwrite = true)
                } else {
                    source.copyTo(dest, overwrite = true)
                }
                source.deleteRecursively()
            }
            true
        } catch (e: Exception) {
            false
        }
    }

    /** Soft-delete: moves the file/folder into the hidden trash dir instead of erasing it. */
    fun moveToTrash(path: String): Boolean {
        return try {
            val source = File(path)
            val trashTarget = File(trashDir(), "${System.currentTimeMillis()}_${source.name}")
            val ok = source.renameTo(trashTarget)
            if (ok) {
                // Record original path so restore can put it back where it came from
                File(trashDir(), "${trashTarget.name}.origin").writeText(source.absolutePath)
            }
            ok
        } catch (e: Exception) {
            false
        }
    }

    fun listTrash(): List<Map<String, Any>> {
        val dir = trashDir()
        val dateFormat = SimpleDateFormat("yyyy-MM-dd HH:mm", Locale.getDefault())
        return (dir.listFiles() ?: emptyArray())
            .filter { !it.name.endsWith(".origin") }
            .map { f ->
                val originFile = File(dir, "${f.name}.origin")
                val originalPath = if (originFile.exists()) originFile.readText() else f.name
                mapOf(
                    "name" to f.name.substringAfter("_"),
                    "path" to f.absolutePath,
                    "originalPath" to originalPath,
                    "isDirectory" to f.isDirectory,
                    "sizeBytes" to (if (f.isDirectory) 0L else f.length()),
                    "deletedAt" to dateFormat.format(Date(f.lastModified()))
                )
            }
            .sortedByDescending { it["deletedAt"] as String }
    }

    fun restoreFromTrash(trashPath: String): Boolean {
        return try {
            val trashFile = File(trashPath)
            val originFile = File(trashDir(), "${trashFile.name}.origin")
            val originalPath = if (originFile.exists()) originFile.readText() else null
                ?: return false
            val restoreTarget = File(originalPath)
            restoreTarget.parentFile?.mkdirs()
            val ok = trashFile.renameTo(restoreTarget)
            if (ok) originFile.delete()
            ok
        } catch (e: Exception) {
            false
        }
    }

    fun permanentlyDelete(path: String): Boolean {
        return try {
            val file = File(path)
            val originFile = File(trashDir(), "${file.name}.origin")
            if (originFile.exists()) originFile.delete()
            if (file.isDirectory) file.deleteRecursively() else file.delete()
        } catch (e: Exception) {
            false
        }
    }

    fun emptyTrash(): Boolean {
        return try {
            trashDir().listFiles()?.forEach { it.deleteRecursively() }
            true
        } catch (e: Exception) {
            false
        }
    }

    /** Opens a file with the appropriate installed app via FileProvider (avoids FileUriExposedException). */
    fun openFile(path: String): Boolean {
        return try {
            val file = File(path)
            val uri: Uri = FileProvider.getUriForFile(
                context, "${context.packageName}.fileprovider", file
            )
            val mimeType = context.contentResolver.getType(uri)
                ?: guessMimeType(file.extension)
            val intent = Intent(Intent.ACTION_VIEW).apply {
                setDataAndType(uri, mimeType)
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            context.startActivity(intent)
            true
        } catch (e: Exception) {
            false
        }
    }

    private fun guessMimeType(extension: String): String {
        return when (extension.lowercase()) {
            "jpg", "jpeg", "png", "webp", "gif" -> "image/*"
            "mp4", "mkv", "webm" -> "video/*"
            "mp3", "wav", "ogg" -> "audio/*"
            "txt", "md" -> "text/plain"
            "pdf" -> "application/pdf"
            "zip" -> "application/zip"
            "apk" -> "application/vnd.android.package-archive"
            else -> "*/*"
        }
    }
}
