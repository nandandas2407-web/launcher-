import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/liquid_glass_panel.dart';
import '../../core/theme/glass_tokens.dart';

/// Glass sticky note widget for quick jotting. Persists to disk so the note
/// survives app restarts instead of resetting every launch.
class StickyNoteWidget extends StatefulWidget {
  const StickyNoteWidget();

  @override
  State<StickyNoteWidget> createState() => _StickyNoteWidgetState();
}

class _StickyNoteWidgetState extends State<StickyNoteWidget> {
  static const _prefsKey = 'desktop_sticky_note_text';
  final TextEditingController _controller = TextEditingController();
  bool _isEditing = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadNote();
  }

  Future<void> _loadNote() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey) ?? '';
    if (mounted) {
      setState(() {
        _controller.text = saved;
        _loaded = true;
      });
    }
  }

  Future<void> _saveNote() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, _controller.text);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _isEditing = true),
      child: LiquidGlassPanel(
        padding: const EdgeInsets.all(16.0),
        borderRadius: 18.0,
        tint: GlassTokens.accentAmber,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.note,
                  size: 16.0,
                  color: GlassTokens.accentAmber.withOpacity(0.70),
                ),
                const SizedBox(width: 8.0),
                Text(
                  'Quick Note',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.70),
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            if (_isEditing)
              TextField(
                controller: _controller,
                maxLines: 4,
                autofocus: true,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12.0,
                ),
                decoration: InputDecoration(
                  hintText: 'Jot something down...',
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.30),
                    fontSize: 12.0,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onSubmitted: (_) {
                  setState(() => _isEditing = false);
                  _saveNote();
                },
                onEditingComplete: _saveNote,
                onTapOutside: (_) {
                  setState(() => _isEditing = false);
                  _saveNote();
                },
              )
            else
              Text(
                _controller.text.isEmpty
                    ? 'Tap to jot a note...'
                    : _controller.text,
                style: TextStyle(
                  color: _controller.text.isEmpty
                      ? Colors.white.withOpacity(0.40)
                      : Colors.white.withOpacity(0.70),
                  fontSize: 12.0,
                  fontStyle: _controller.text.isEmpty
                      ? FontStyle.italic
                      : FontStyle.normal,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }
}
