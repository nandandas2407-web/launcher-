import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/utils/squircle_path.dart';

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
                Text(
                  'Notifications',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.50),
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12.0),
                _NotificationCard(
                  title: 'Termux',
                  body: 'Build completed successfully',
                  time: '2m ago',
                  icon: Icons.terminal,
                  accentColor: const Color(0xFF39FF14),
                ),
                _NotificationCard(
                  title: 'GitHub',
                  body: 'New PR review requested',
                  time: '15m ago',
                  icon: Icons.code,
                  accentColor: const Color(0xFF6366F1),
                ),
                _NotificationCard(
                  title: 'Acode Editor',
                  body: 'File saved: main.dart',
                  time: '1h ago',
                  icon: Icons.edit,
                  accentColor: const Color(0xFF00E5FF),
                ),
                const SizedBox(height: 24.0),
                // Widgets section
                Text(
                  'Widgets',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.50),
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12.0),
                _MiniWeatherWidget(),
              ],
            ),
          ),
        ),
      ),
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

class _NotificationCard extends StatelessWidget {
  final String title;
  final String body;
  final String time;
  final IconData icon;
  final Color accentColor;

  const _NotificationCard({
    required this.title,
    required this.body,
    required this.time,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Container(
            width: 32.0,
            height: 32.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: accentColor.withOpacity(0.15),
            ),
            child: Icon(icon, size: 16.0, color: accentColor),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  body,
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
            time,
            style: TextStyle(
              color: Colors.white.withOpacity(0.35),
              fontSize: 10.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniWeatherWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.03),
          ],
        ),
        border: Border.all(
          width: 1.0,
          color: Colors.white.withOpacity(0.08),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.wb_sunny,
            size: 32.0,
            color: const Color(0xFFF59E0B).withOpacity(0.80),
          ),
          const SizedBox(width: 16.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '24 C',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 20.0,
                  fontWeight: FontWeight.w300,
                ),
              ),
              Text(
                'Clear skies',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.50),
                  fontSize: 11.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
