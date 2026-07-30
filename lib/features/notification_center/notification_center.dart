import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/utils/squircle_path.dart';
import '../../core/platform/launcher_service.dart';
import '../../widgets/real_app_icon.dart';
import '../../core/theme/glass_tokens.dart';

class NotificationCenter extends StatefulWidget {
  final VoidCallback onDismiss;

  const NotificationCenter({super.key, required this.onDismiss});

  @override
  State<NotificationCenter> createState() => _NotificationCenterState();
}

class _NotificationCenterState extends State<NotificationCenter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  bool _granted = false;
  bool _loading = true;
  List<NotificationEntry> _notifications = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
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

  Future<void> _dismissOne(NotificationEntry entry) async {
    setState(() => _notifications.removeWhere((n) => n.key == entry.key));
    await LauncherService.dismissNotification(entry.key);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            // Dimmed background
            Positioned.fill(
              child: GestureDetector(
                onTap: _dismiss,
                child: Container(
                  color: Colors.black.withOpacity(0.35 * _fadeAnimation.value),
                ),
              ),
            ),
            // Panel sliding from right
            Positioned(
              top: 36.0,
              bottom: 0,
              right: 0,
              child: Transform.translate(
                offset: Offset(350.0 * (1.0 - _slideAnimation.value), 0),
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: _buildPanel(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPanel() {
    final now = DateTime.now();
    final day = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][now.weekday % 7];
    final month = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][now.month - 1];

    return ClipPath(
      clipper: SquircleClipper(radius: 28.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 40.0, sigmaY: 40.0),
        child: Container(
          width: 340,
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.14),
                Colors.white.withOpacity(0.05),
              ],
            ),
            border: Border.all(
              width: 1.0,
              color: Colors.white.withOpacity(0.18),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.45),
                blurRadius: 40.0,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Calendar widget
                _CalendarHeader(
                  day: day,
                  date: now.day,
                  month: month,
                  year: now.year,
                ),
                const SizedBox(height: 24.0),
                // Notifications section
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Notifications',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.50),
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    if (_granted && _notifications.isNotEmpty)
                      GestureDetector(
                        onTap: () async {
                          for (final n in List.of(_notifications)) {
                            await _dismissOne(n);
                          }
                        },
                        child: Text(
                          'Clear All',
                          style: TextStyle(color: GlassTokens.accentAqua.withOpacity(0.80), fontSize: 11.0),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12.0),
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: SizedBox(width: 18.0, height: 18.0, child: CircularProgressIndicator(strokeWidth: 2.0)),
                  )
                else if (!_granted)
                  _permissionPrompt()
                else if (_notifications.isEmpty)
                  Text(
                    'No notifications',
                    style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 12.0, fontStyle: FontStyle.italic),
                  )
                else
                  ..._notifications.map((n) => _RealNotificationCard(
                        entry: n,
                        onDismiss: () => _dismissOne(n),
                      )),
              ],
            ),
          ),
        ),
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

  void _dismiss() {
    _controller.reverse().then((_) => widget.onDismiss());
  }
}

class _CalendarHeader extends StatelessWidget {
  final String day;
  final int date;
  final String month;
  final int year;

  const _CalendarHeader({
    required this.day,
    required this.date,
    required this.month,
    required this.year,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              day,
              style: TextStyle(
                color: Colors.white.withOpacity(0.50),
                fontSize: 12.0,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$date',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 48.0,
                fontWeight: FontWeight.w200,
                height: 1.1,
              ),
            ),
            Text(
              '$month $year',
              style: TextStyle(
                color: Colors.white.withOpacity(0.70),
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RealNotificationCard extends StatelessWidget {
  final NotificationEntry entry;
  final VoidCallback onDismiss;

  const _RealNotificationCard({required this.entry, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(entry.key),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: const SizedBox.shrink(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.0),
          color: Colors.white.withOpacity(0.06),
          border: Border.all(
            width: 1.0,
            color: Colors.white.withOpacity(0.06),
          ),
        ),
        child: Row(
          children: [
            RealAppIcon(
              packageName: entry.packageName,
              appName: entry.title,
              size: 32.0,
              borderRadius: 8.0,
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.title,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    entry.text,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.55),
                      fontSize: 11.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Text(
              entry.relativeTime,
              style: TextStyle(
                color: Colors.white.withOpacity(0.35),
                fontSize: 10.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
