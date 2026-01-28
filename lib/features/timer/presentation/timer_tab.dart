import 'dart:async';

import 'package:flutter/material.dart';

import 'timer_done_screen.dart';

class TimerTab extends StatefulWidget {
  const TimerTab({super.key});

  @override
  State<TimerTab> createState() => _TimerTabState();
}

class _TimerTabState extends State<TimerTab> {
  Timer? _ticker;

  Duration _setDuration = const Duration(minutes: 5);
  Duration _remaining = const Duration(minutes: 5);

  bool _running = false;
  bool _paused = false;

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _applyPreset(Duration d) {
    if (_running) return;
    setState(() {
      _setDuration = d;
      _remaining = d;
    });
  }

  Future<void> _pickCustom() async {
    if (_running) return;

    int h = _setDuration.inHours;
    int m = _setDuration.inMinutes % 60;
    int s = _setDuration.inSeconds % 60;

    final picked = await showModalBottomSheet<Duration>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 22),
            child: StatefulBuilder(
              builder: (context, setSheet) {
                Widget numberRow(String label, int value, void Function(int) onSet,
                    {int min = 0, int max = 59}) {
                  return Row(
                    children: [
                      SizedBox(
                        width: 70,
                        child: Text(
                          label,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      IconButton(
                        onPressed: value > min
                            ? () => setSheet(() => onSet(value - 1))
                            : null,
                        icon: const Icon(Icons.remove),
                      ),
                      SizedBox(
                        width: 60,
                        child: Center(
                          child: Text(
                            value.toString().padLeft(2, '0'),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: value < max
                            ? () => setSheet(() => onSet(value + 1))
                            : null,
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  );
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Custom timer',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    numberRow('Hours', h, (v) => h = v, min: 0, max: 23),
                    numberRow('Minutes', m, (v) => m = v),
                    numberRow('Seconds', s, (v) => s = v),
                    const SizedBox(height: 14),
                    FilledButton.icon(
                      onPressed: () {
                        final d = Duration(hours: h, minutes: m, seconds: s);
                        Navigator.of(context).pop(d);
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Set'),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );

    if (!mounted) return;
    if (picked == null) return;

    // Avoid 0 timer
    final d = picked.inSeconds <= 0 ? const Duration(seconds: 1) : picked;

    setState(() {
      _setDuration = d;
      _remaining = d;
    });
  }

  void _start() {
    if (_running) return;

    if (_remaining.inSeconds <= 0) {
      setState(() => _remaining = _setDuration);
    }

    setState(() {
      _running = true;
      _paused = false;
    });

    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (!_running || _paused) return;

      setState(() {
        final next = _remaining - const Duration(seconds: 1);
        _remaining = next.isNegative ? Duration.zero : next;
      });

      if (_remaining.inSeconds <= 0) {
        _finish();
      }
    });
  }

  void _pause() {
    if (!_running) return;
    setState(() => _paused = true);
  }

  void _resume() {
    if (!_running) return;
    setState(() => _paused = false);
  }

  void _cancel() {
    _ticker?.cancel();
    _ticker = null;

    setState(() {
      _running = false;
      _paused = false;
      _remaining = _setDuration;
    });
  }

  Future<void> _finish() async {
    _ticker?.cancel();
    _ticker = null;

    setState(() {
      _running = false;
      _paused = false;
      _remaining = Duration.zero;
    });

    // Show done screen
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const TimerDoneScreen(label: 'Time is up!'),
      ),
    );

    if (!mounted) return;

    // Reset after dismiss
    setState(() {
      _remaining = _setDuration;
    });
  }

  @override
  Widget build(BuildContext context) {
    final timeText = _fmt(_remaining);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Timer'),
        actions: [
          IconButton(
            tooltip: 'Custom',
            onPressed: _running ? null : _pickCustom,
            icon: const Icon(Icons.tune),
          ),
          IconButton(
            tooltip: 'Reset',
            onPressed: _running ? null : () => _applyPreset(_setDuration),
            icon: const Icon(Icons.restart_alt),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    Text(
                      timeText,
                      style: const TextStyle(
                        fontSize: 52,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _PresetChip(
                          label: '1m',
                          onTap: () => _applyPreset(const Duration(minutes: 1)),
                          enabled: !_running,
                        ),
                        _PresetChip(
                          label: '5m',
                          onTap: () => _applyPreset(const Duration(minutes: 5)),
                          enabled: !_running,
                        ),
                        _PresetChip(
                          label: '10m',
                          onTap: () => _applyPreset(const Duration(minutes: 10)),
                          enabled: !_running,
                        ),
                        _PresetChip(
                          label: '25m',
                          onTap: () => _applyPreset(const Duration(minutes: 25)),
                          enabled: !_running,
                        ),
                        _PresetChip(
                          label: 'Custom',
                          onTap: _pickCustom,
                          enabled: !_running,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: !_running
                                ? _start
                                : _paused
                                    ? _resume
                                    : _pause,
                            icon: Icon(
                              !_running
                                  ? Icons.play_arrow
                                  : _paused
                                      ? Icons.play_arrow
                                      : Icons.pause,
                            ),
                            label: Text(
                              !_running
                                  ? 'Start'
                                  : _paused
                                      ? 'Resume'
                                      : 'Pause',
                            ),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _running ? _cancel : null,
                            icon: const Icon(Icons.stop),
                            label: const Text('Cancel'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _running
                          ? (_paused ? 'Paused' : 'Running')
                          : 'Set: ${_fmt(_setDuration)}',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Expanded(
              child: Center(
                child: Text(
                  'Tip: Use presets for quick timers.\nCustom lets you pick hours/min/sec.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(Duration d) {
    final total = d.inSeconds;
    final h = total ~/ 3600;
    final m = (total % 3600) ~/ 60;
    final s = total % 60;

    final hh = h.toString().padLeft(2, '0');
    final mm = m.toString().padLeft(2, '0');
    final ss = s.toString().padLeft(2, '0');

    return '$hh:$mm:$ss';
  }
}

class _PresetChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool enabled;

  const _PresetChip({
    required this.label,
    required this.onTap,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: enabled ? onTap : null,
    );
  }
}
