package com.kll.liquidos

import android.app.Notification
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification

/**
 * Captures real device notifications. Requires the user to manually grant
 * "Notification access" in Android Settings > Apps > Special app access —
 * this is a privilege Android will not let any app request via a normal
 * runtime permission dialog, by design, since it exposes all notification
 * content system-wide.
 *
 * Notifications are cached in-memory here and pulled by MainActivity via
 * the companion object, rather than pushed live to Flutter — simpler and
 * avoids managing a persistent EventChannel stream for something the UI
 * only needs to poll (Control Center / desktop widget open).
 */
class NotificationListener : NotificationListenerService() {

    companion object {
        // Most-recent-first cache of active notifications, updated as they
        // post/get removed. Read-only snapshot handed to MainActivity on demand.
        private var cachedNotifications: List<Map<String, Any>> = emptyList()
        private var listenerInstance: NotificationListener? = null

        fun getCachedNotifications(): List<Map<String, Any>> = cachedNotifications

        fun isListenerConnected(context: android.content.Context): Boolean {
            val enabledListeners = android.provider.Settings.Secure.getString(
                context.contentResolver, "enabled_notification_listeners"
            ) ?: return false
            return enabledListeners.contains(context.packageName)
        }

        fun requestDismiss(key: String) {
            listenerInstance?.dismissNotification(key)
        }
    }

    override fun onListenerConnected() {
        super.onListenerConnected()
        listenerInstance = this
        refreshCache()
    }

    override fun onListenerDisconnected() {
        super.onListenerDisconnected()
        listenerInstance = null
    }

    override fun onNotificationPosted(sbn: StatusBarNotification) {
        super.onNotificationPosted(sbn)
        refreshCache()
    }

    override fun onNotificationRemoved(sbn: StatusBarNotification) {
        super.onNotificationRemoved(sbn)
        refreshCache()
    }

    private fun refreshCache() {
        cachedNotifications = try {
            activeNotifications
                .mapNotNull { sbn -> notificationToMap(sbn) }
                .sortedByDescending { it["postTime"] as Long }
        } catch (e: Exception) {
            emptyList()
        }
    }

    private fun notificationToMap(sbn: StatusBarNotification): Map<String, Any>? {
        // Skip our own app's notifications.
        if (sbn.packageName == packageName) return null

        val extras = sbn.notification.extras
        val title = extras.getCharSequence(Notification.EXTRA_TITLE)?.toString() ?: return null
        val text = extras.getCharSequence(Notification.EXTRA_TEXT)?.toString() ?: ""

        return mapOf(
            "packageName" to sbn.packageName,
            "title" to title,
            "text" to text,
            "postTime" to sbn.postTime,
            "key" to sbn.key
        )
    }

    fun dismissNotification(key: String) {
        try {
            cancelNotification(key)
            refreshCache()
        } catch (e: Exception) {
            // ignore
        }
    }
}
