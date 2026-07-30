import 'package:flutter/material.dart';
import '../../widgets/liquid_glass_panel.dart';
import '../../widgets/real_app_icon.dart';
import '../../core/platform/launcher_service.dart';
import '../../core/theme/glass_tokens.dart';

/// Real device notifications, sourced from NotificationListenerService.
/// Requires a manual one-time grant in Settings > Notification access —
/// Android does not allow this to be requested via a normal permission
/// dialog, so we show an honest explanation + button that deep-links there.
class NotificationsFeedWidget extends StatefulWidget {
  const NotificationsFeedWidget({super.key});

  @override
  State<NotificationsFeedWidget> createState() => _NotificationsFeedWidgetState();
}

class _NotificationsFeedWidgetState extends State<NotificationsFeedWidget> with WidgetsBindingObserver {
  bool _granted = false;
  bool _loading = true;
  List<NotificationEntry> _notifications = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-check permission when returning from the system settings screen.
    if (state == AppLifecycleState.resumed) {
      _load();
    }
  }

  Future<void> _load() async {
    final granted = await LauncherService.isNotificationAccessGranted();
    List<NotificationEntry> notifications = [];
    if (granted) {
      notifications = await LauncherService.getNotifications();
    }
    if (mounted) {
      setState(() {
        _granted = granted;
        _notifications = notifications;
        _loading = false;
      });
    }
  }

  Future<void> _dismiss(NotificationEntry entry) async {
    setState(() => _notifications.removeWhere((n) => n.key == entry.key));
    await LauncherService.dismissNotification(entry.key);
  }

  @override
  Widget build(BuildContext context) {
    return LiquidGlassPanel(
      padding: const EdgeInsets.all(16.0),
      borderRadius: 18.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Notifications',
                  style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 14.0, fontWeight: FontWeight.w600),
                ),
              ),
              if (_granted && _notifications.isNotEmpty)
                GestureDetector(
                  onTap: () async {
                    for (final n in List.of(_notifications)) {
                      await _dismiss(n);
                    }
                  },
                  child: Text('Clear All', style: TextStyle(color: GlassTokens.accentAqua.withOpacity(0.80), fontSize: 11.0)),
                ),
            ],
          ),
          const SizedBox(height: 10.0),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: SizedBox(width: 16.0, height: 16.0, child: CircularProgressIndicator(strokeWidth: 2.0)),
            )
          else if (!_granted)
            _permissionPrompt()
          else if (_notifications.isEmpty)
            Text('No notifications', style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 12.0, fontStyle: FontStyle.italic))
          else
            ...(_notifications.take(5).map((n) => _notificationRow(n))),
        ],
      ),
    );
  }

  Widget _permissionPrompt() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Grant notification access to see your real alerts here.',
          style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 12.0),
        ),
        const SizedBox(height: 10.0),
        GestureDetector(
          onTap: () => LauncherService.requestNotificationAccess(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: GlassTokens.accentAqua.withOpacity(0.20),
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(color: GlassTokens.accentAqua.withOpacity(0.40)),
            ),
            child: Text('Open Settings', style: TextStyle(color: GlassTokens.accentAqua, fontSize: 12.0, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  Widget _notificationRow(NotificationEntry entry) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Dismissible(
        key: ValueKey(entry.key),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => _dismiss(entry),
        background: const SizedBox.shrink(),
        child: Row(
          children: [
            RealAppIcon(packageName: entry.packageName, appName: entry.title, size: 32.0, borderRadius: 8.0),
            const SizedBox(width: 10.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(entry.title, style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12.0, fontWeight: FontWeight.w600)),
                  Text(entry.text, style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 11.0), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Text(entry.relativeTime, style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 10.0)),
          ],
        ),
      ),
    );
  }
}
