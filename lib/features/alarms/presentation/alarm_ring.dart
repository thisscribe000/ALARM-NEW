import 'dart:async';

import 'package:flutter/material.dart';

import '../../../services/alarm_runtime.dart';
import '../domain/alarm.dart';

class AlarmRingScreen extends StatefulWidget {
  final Alarm alarm;

  /// Snooze rule:
  /// - 3 or 5 for limited snoozes
  /// - null for unlimited
  final int? maxSnoozes;

  const AlarmRingScreen({
    super.key,
    required this.alarm,
    this.maxSnoozes,
  });

  @override
  State<AlarmRingScreen> createState() => _AlarmRingScreenState();
}

class _AlarmRingScreenState extends State<AlarmRingScreen> {
  StreamSubscription<Alarm?>? _sub;
  int _secondsLeft = AlarmRuntime.unattendedAutoStop.inSeconds;
  Timer? _countdown;

  @override
  void initState() {
    super.initState();

    _countdown = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_secondsLeft > 0) _secondsLeft--;
      });
    });

    _sub = AlarmRuntime.instance.ringingStream.listen((alarm) {
      if (alarm == null && mounted) {
        Navigator.of(context).maybePop();
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _countdown?.cancel();
    super.dispose();
  }

  void _dismiss() {
    AlarmRuntime.instance.stopRinging(reason: 'dismissed');
  }

  Future<void> _showSnoozePicker() async {
  final runtime = AlarmRuntime.instance;
  final max = widget.maxSnoozes;

  final isBlocked = max != null && runtime.snoozeCount >= max;

  if (isBlocked) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Snooze limit reached ($max). Dismiss to stop alarm.'),
      ),
    );
    return;
  }

  final picked = await showModalBottomSheet<int>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Snooze',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                AlarmRuntime.devModeFastSnooze
                    ? 'DEV mode: 5 min = 5 sec'
                    : 'Pick how long to snooze',
              ),
              const SizedBox(height: 14),
              _SnoozeOption(minutes: 5),
              _SnoozeOption(minutes: 10),
              _SnoozeOption(minutes: 15),
              _SnoozeOption(minutes: 30),
              const SizedBox(height: 10),
              Text(
                max == null
                    ? 'Snoozes: unlimited'
                    : 'Snoozes: ${runtime.snoozeCount} / $max',
              ),
            ],
          ),
        ),
      );
    },
  );

  if (!mounted) return;
  if (picked == null) return;

  final ok =
      AlarmRuntime.instance.snooze(minutes: picked, maxSnoozes: max);

  if (!mounted) return;

  if (!ok) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          max == null
              ? 'Could not snooze.'
              : 'Snooze limit reached ($max).',
        ),
      ),
    );
    return;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        AlarmRuntime.devModeFastSnooze
            ? 'Snoozed for $picked sec (dev)'
            : 'Snoozed for $picked min',
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final alarm = widget.alarm;
    final time = alarm.timeText(use24h: true);

    final max = widget.maxSnoozes;
    final snoozeCount = AlarmRuntime.instance.snoozeCount;
    final blocked = max != null && snoozeCount >= max;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.notifications_active, size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'ALARM RINGING',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                time,
                style: const TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                alarm.label.isEmpty ? 'Alarm' : alarm.label,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 18),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.timer),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Auto-stop in $_secondsLeft s (dev)',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          max == null
                              ? 'Snooze: $snoozeCount (unlimited)'
                              : 'Snooze: $snoozeCount / $max',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: blocked ? null : _showSnoozePicker,
                      icon: const Icon(Icons.snooze),
                      label: const Text('Snooze'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _dismiss,
                      icon: const Icon(Icons.check),
                      label: const Text('Dismiss'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _SnoozeOption extends StatelessWidget {
  final int minutes;

  const _SnoozeOption({required this.minutes});

  @override
  Widget build(BuildContext context) {
    final subtitle = AlarmRuntime.devModeFastSnooze
        ? '$minutes sec (dev)'
        : '$minutes min';

    return Card(
      child: ListTile(
        leading: const Icon(Icons.snooze),
        title: Text('$minutes'),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).pop<int>(minutes),
      ),
    );
  }
}
