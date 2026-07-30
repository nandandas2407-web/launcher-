import 'package:flutter/material.dart';
import '../../widgets/liquid_glass_panel.dart';
import '../../core/theme/glass_tokens.dart';

/// Real month calendar grid — computes actual days/weekdays for the current
/// month via DateTime, highlights today, and lets the user page between months.
class CalendarWidget extends StatefulWidget {
  const CalendarWidget({super.key});

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late DateTime _viewedMonth;
  final DateTime _today = DateTime.now();

  static const _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  static const _dayHeaders = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  @override
  void initState() {
    super.initState();
    _viewedMonth = DateTime(_today.year, _today.month, 1);
  }

  void _changeMonth(int delta) {
    setState(() {
      _viewedMonth = DateTime(_viewedMonth.year, _viewedMonth.month + delta, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(_viewedMonth.year, _viewedMonth.month + 1, 0).day;
    // DateTime.weekday: Mon=1..Sun=7. We want Sun=0..Sat=6 for the grid.
    final firstWeekday = _viewedMonth.weekday % 7;

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
                  '${_monthNames[_viewedMonth.month - 1]} ${_viewedMonth.year}',
                  style: const TextStyle(color: Colors.white, fontSize: 14.0, fontWeight: FontWeight.w600),
                ),
              ),
              _navButton(Icons.chevron_left, () => _changeMonth(-1)),
              _navButton(Icons.chevron_right, () => _changeMonth(1)),
            ],
          ),
          const SizedBox(height: 10.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _dayHeaders
                .map((d) => SizedBox(
                      width: 24.0,
                      child: Text(
                        d,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white.withOpacity(0.40), fontSize: 11.0),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 6.0),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 2.0,
            ),
            itemCount: firstWeekday + daysInMonth,
            itemBuilder: (context, index) {
              if (index < firstWeekday) return const SizedBox.shrink();
              final day = index - firstWeekday + 1;
              final isToday = _viewedMonth.year == _today.year &&
                  _viewedMonth.month == _today.month &&
                  day == _today.day;
              return Center(
                child: Container(
                  width: 24.0,
                  height: 24.0,
                  alignment: Alignment.center,
                  decoration: isToday
                      ? BoxDecoration(
                          color: GlassTokens.accentAqua,
                          shape: BoxShape.circle,
                        )
                      : null,
                  child: Text(
                    '$day',
                    style: TextStyle(
                      color: isToday ? Colors.black : Colors.white.withOpacity(0.75),
                      fontSize: 11.0,
                      fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _navButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, size: 18.0, color: Colors.white.withOpacity(0.55)),
    );
  }
}
