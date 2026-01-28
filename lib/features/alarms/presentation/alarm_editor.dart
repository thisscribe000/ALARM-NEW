import 'package:flutter/material.dart';

import '../domain/alarm.dart';

class AlarmEditor extends StatefulWidget {
  final Alarm? initial;

  const AlarmEditor({super.key, this.initial});

  @override
  State<AlarmEditor> createState() => _AlarmEditorState();
}

class _AlarmEditorState extends State<AlarmEditor> {
  late TimeOfDay _time;
  late TextEditingController _label;

  @override
  void initState() {
    super.initState();
    final now = TimeOfDay.now();
    _time = widget.initial != null
        ? TimeOfDay(hour: widget.initial!.hour, minute: widget.initial!.minute)
        : now;
    _label = TextEditingController(text: widget.initial?.label ?? '');
  }

  @override
  void dispose() {
    _label.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (picked != null) {
      setState(() => _time = picked);
    }
  }

  void _save() {
    final now = DateTime.now();
    final id = widget.initial?.id ?? '${now.microsecondsSinceEpoch}';
    final alarm = Alarm(
      id: id,
      hour: _time.hour,
      minute: _time.minute,
      label: _label.text.trim(),
      enabled: widget.initial?.enabled ?? true,
    );
    Navigator.of(context).pop<Alarm>(alarm);
  }

  @override
  Widget build(BuildContext context) {
    final timeText =
        '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initial == null ? 'Add Alarm' : 'Edit Alarm'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('SAVE'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              title: const Text('Time'),
              subtitle: Text(timeText),
              trailing: const Icon(Icons.chevron_right),
              onTap: _pickTime,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _label,
                decoration: const InputDecoration(
                  labelText: 'Label (optional)',
                  hintText: 'e.g., School, Prayer, Work',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Note: System alarm ringing + background scheduling comes later.\n'
            'For now we are building the alarm list, saving, and UI flow.',
          ),
        ],
      ),
    );
  }
}
