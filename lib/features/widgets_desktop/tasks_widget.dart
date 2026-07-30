import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/liquid_glass_panel.dart';
import '../../core/theme/glass_tokens.dart';

class _Task {
  String text;
  bool done;
  _Task({required this.text, this.done = false});

  Map<String, dynamic> toJson() => {'text': text, 'done': done};
  factory _Task.fromJson(Map<String, dynamic> json) =>
      _Task(text: json['text'] as String? ?? '', done: json['done'] as bool? ?? false);
}

/// Persisted task checklist widget — add, check off, and remove tasks.
/// Saved to shared_preferences as JSON so it survives app restarts.
class TasksWidget extends StatefulWidget {
  const TasksWidget({super.key});

  @override
  State<TasksWidget> createState() => _TasksWidgetState();
}

class _TasksWidgetState extends State<TasksWidget> {
  static const _prefsKey = 'desktop_tasks_json';
  List<_Task> _tasks = [];
  bool _loaded = false;
  final TextEditingController _newTaskController = TextEditingController();
  bool _adding = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    List<_Task> tasks = [];
    if (raw != null) {
      try {
        final decoded = jsonDecode(raw) as List<dynamic>;
        tasks = decoded.map((e) => _Task.fromJson(e as Map<String, dynamic>)).toList();
      } catch (_) {}
    }
    if (mounted) {
      setState(() {
        _tasks = tasks;
        _loaded = true;
      });
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(_tasks.map((t) => t.toJson()).toList()));
  }

  void _toggleTask(int index) {
    setState(() => _tasks[index].done = !_tasks[index].done);
    _save();
  }

  void _removeTask(int index) {
    setState(() => _tasks.removeAt(index));
    _save();
  }

  void _addTask() {
    final text = _newTaskController.text.trim();
    if (text.isEmpty) {
      setState(() => _adding = false);
      return;
    }
    setState(() {
      _tasks.add(_Task(text: text));
      _newTaskController.clear();
      _adding = false;
    });
    _save();
  }

  @override
  void dispose() {
    _newTaskController.dispose();
    super.dispose();
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
                  'Tasks',
                  style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 14.0, fontWeight: FontWeight.w600),
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _adding = true),
                child: Icon(Icons.add, size: 18.0, color: Colors.white.withOpacity(0.55)),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          if (!_loaded)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: SizedBox(
                height: 16.0,
                width: 16.0,
                child: CircularProgressIndicator(strokeWidth: 2.0),
              ),
            )
          else if (_tasks.isEmpty && !_adding)
            Text(
              'No tasks yet',
              style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 12.0, fontStyle: FontStyle.italic),
            )
          else
            ...List.generate(_tasks.length, (i) => _taskRow(i)),
          if (_adding)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: TextField(
                controller: _newTaskController,
                autofocus: true,
                style: const TextStyle(color: Colors.white, fontSize: 13.0),
                decoration: InputDecoration(
                  hintText: 'New task...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.30), fontSize: 13.0),
                  border: InputBorder.none,
                  isDense: true,
                ),
                onSubmitted: (_) => _addTask(),
                onTapOutside: (_) => _addTask(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _taskRow(int index) {
    final task = _tasks[index];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: GestureDetector(
        onTap: () => _toggleTask(index),
        onLongPress: () => _removeTask(index),
        child: Row(
          children: [
            Icon(
              task.done ? Icons.check_box : Icons.check_box_outline_blank,
              size: 18.0,
              color: task.done ? GlassTokens.accentEmerald : Colors.white.withOpacity(0.40),
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: Text(
                task.text,
                style: TextStyle(
                  color: task.done ? Colors.white.withOpacity(0.35) : Colors.white.withOpacity(0.85),
                  fontSize: 13.0,
                  decoration: task.done ? TextDecoration.lineThrough : TextDecoration.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
