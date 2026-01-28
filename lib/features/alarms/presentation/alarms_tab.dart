import 'package:flutter/material.dart';

import '../../../services/alarm_runtime.dart';
import '../data/alarm_store.dart';
import '../domain/alarm.dart';
import 'alarm_editor.dart';
import 'alarm_ring.dart';

class AlarmsTab extends StatefulWidget {
  const AlarmsTab({super.key});

  @override
  State<AlarmsTab> createState() => _AlarmsTabState();
}

class _AlarmsTabState extends State<AlarmsTab> {
  final AlarmStore _store = AlarmStore();
  bool _loading = true;
  List<Alarm> _alarms = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final loaded = await _store.load();
    loaded.sort(_alarmSort);
    setState(() {
      _alarms = loaded;
      _loading = false;
    });
  }

  int _alarmSort(Alarm a, Alarm b) {
    final at = a.hour * 60 + a.minute;
    final bt = b.hour * 60 + b.minute;
    return at.compareTo(bt);
  }

  Future<void> _persist() async {
    final sorted = [..._alarms]..sort(_alarmSort);
    setState(() => _alarms = sorted);
    await _store.save(sorted);
  }

  Future<void> _addAlarm() async {
    final created = await Navigator.of(context).push<Alarm>(
      MaterialPageRoute(builder: (_) => const AlarmEditor()),
    );

    if (created == null) return;

    setState(() {
      _alarms = [..._alarms, created];
    });
    await _persist();
  }

  Future<void> _editAlarm(Alarm alarm) async {
    final updated = await Navigator.of(context).push<Alarm>(
      MaterialPageRoute(builder: (_) => AlarmEditor(initial: alarm)),
    );

    if (updated == null) return;

    setState(() {
      _alarms = _alarms.map((a) => a.id == alarm.id ? updated : a).toList();
    });
    await _persist();
  }

  Future<void> _toggle(Alarm alarm, bool value) async {
    setState(() {
      _alarms = _alarms
          .map((a) => a.id == alarm.id ? a.copyWith(enabled: value) : a)
          .toList();
    });
    await _persist();
  }

  Future<void> _deleteAlarm(Alarm alarm) async {
    setState(() {
      _alarms = _alarms.where((a) => a.id != alarm.id).toList();
    });
    await _persist();
  }

  void _testRing(Alarm alarm) {
    AlarmRuntime.instance.startRinging(alarm);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AlarmRingScreen(alarm: alarm)),
    );
  }

  void _testRingQuick() {
    final now = TimeOfDay.now();
    final alarm = Alarm(
      id: 'test_${DateTime.now().microsecondsSinceEpoch}',
      hour: now.hour,
      minute: now.minute,
      label: 'Test Ring',
      enabled: true,
    );
    _testRing(alarm);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alarm'),
        actions: [
          IconButton(
            tooltip: 'Test ring',
            onPressed: _testRingQuick,
            icon: const Icon(Icons.notifications_active),
          ),
          IconButton(
            tooltip: 'Reload',
            onPressed: _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _alarms.isEmpty
              ? _EmptyState(onAdd: _addAlarm, onTestRing: _testRingQuick)
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
                  itemCount: _alarms.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final alarm = _alarms[i];
                    return Dismissible(
                      key: ValueKey(alarm.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        color: Theme.of(context).colorScheme.errorContainer,
                        child: Icon(
                          Icons.delete,
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                      confirmDismiss: (_) async {
                        return await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Delete alarm?'),
                                content: Text(
                                  'Delete "${alarm.label.isEmpty ? 'Alarm' : alarm.label}" '
                                  'at ${alarm.timeText(use24h: true)}?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            ) ??
                            false;
                      },
                      onDismissed: (_) => _deleteAlarm(alarm),
                      child: Card(
                        child: Column(
                          children: [
                            ListTile(
                              onTap: () => _editAlarm(alarm),
                              leading: Icon(
                                alarm.enabled
                                    ? Icons.alarm_on
                                    : Icons.alarm_off,
                              ),
                              title: Text(
                                alarm.timeText(use24h: true),
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                alarm.label.isEmpty ? 'Alarm' : alarm.label,
                              ),
                              trailing: Switch(
                                value: alarm.enabled,
                                onChanged: (v) => _toggle(alarm, v),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => _testRing(alarm),
                                      icon: const Icon(Icons.notifications),
                                      label: const Text('Test Ring'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addAlarm,
        icon: const Icon(Icons.add_alarm),
        label: const Text('Add'),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  final VoidCallback onTestRing;

  const _EmptyState({required this.onAdd, required this.onTestRing});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.alarm, size: 56),
            const SizedBox(height: 12),
            const Text(
              'No alarms yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            const Text(
              'Tap Add to create your first alarm.\n'
              'Or test the ring screen now.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_alarm),
              label: const Text('Add Alarm'),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: onTestRing,
              icon: const Icon(Icons.notifications_active),
              label: const Text('Test Ring'),
            ),
          ],
        ),
      ),
    );
  }
}
