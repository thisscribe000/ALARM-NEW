import 'dart:async';

import 'package:flutter/material.dart';

import '../../../services/alarm_runtime.dart';
import '../domain/alarm.dart';

class AlarmRingScreen extends StatefulWidget {
  final Alarm alarm;

  const AlarmRingScreen({super.key, required this.alarm});

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

    // Countdown display for auto-stop
    _countdown = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_secondsLeft > 0) _secondsLeft--;
      });
    });

    // If runtime stops (auto-stop or dismiss elsewhere), close this screen.
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

  void _snoozeDev() {
    // Snooze system comes next step; for now just stop ringing.
    AlarmRuntime.instance.stopRinging(reason: 'snooze_placeholder');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Snooze coming next step')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final alarm = widget.alarm;
    final time = alarm.timeText(use24h: true);

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
                  child: Row(
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
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _snoozeDev,
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
