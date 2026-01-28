import 'dart:async';

import 'package:flutter/material.dart';

class StopwatchTab extends StatefulWidget {
  const StopwatchTab({super.key});

  @override
  State<StopwatchTab> createState() => _StopwatchTabState();
}

class _StopwatchTabState extends State<StopwatchTab> {
  final Stopwatch _sw = Stopwatch();
  Timer? _ticker;

  Duration _elapsed = Duration.zero;
  final List<Duration> _laps = [];

  bool get _running => _sw.isRunning;

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _start() {
    if (_running) return;

    _sw.start();

    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (!mounted) return;
      setState(() {
        _elapsed = _sw.elapsed;
      });
    });

    setState(() {
      _elapsed = _sw.elapsed;
    });
  }

  void _pause() {
    if (!_running) return;

    _sw.stop();
    _ticker?.cancel();
    _ticker = null;

    setState(() {
      _elapsed = _sw.elapsed;
    });
  }

  void _reset() {
    _sw.reset();
    _ticker?.cancel();
    _ticker = null;

    setState(() {
      _elapsed = Duration.zero;
      _laps.clear();
    });
  }

  void _lap() {
    if (!_running) return;
    final lapTime = _sw.elapsed;
    setState(() => _laps.insert(0, lapTime));
  }

  @override
  Widget build(BuildContext context) {
    final timeText = _fmt(_elapsed);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stopwatch'),
        actions: [
          IconButton(
            tooltip: 'Reset',
            onPressed: (_running || _elapsed > Duration.zero) ? _reset : null,
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
                    const SizedBox(height: 6),
                    Text(
                      timeText,
                      style: const TextStyle(
                        fontSize: 52,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _running ? _pause : _start,
                            icon: Icon(_running ? Icons.pause : Icons.play_arrow),
                            label: Text(_running ? 'Pause' : 'Start'),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _running ? _lap : null,
                            icon: const Icon(Icons.flag),
                            label: const Text('Lap'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: (!_running && _elapsed > Duration.zero) ? _reset : null,
                      icon: const Icon(Icons.restore),
                      label: const Text('Reset'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _laps.isEmpty
                  ? const _EmptyLaps()
                  : ListView.separated(
                      itemCount: _laps.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final lap = _laps[i];
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text('#${_laps.length - i}'),
                            ),
                            title: Text(
                              _fmt(lap),
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            subtitle: const Text('Lap time'),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(Duration d) {
    final totalMs = d.inMilliseconds;

    final minutes = (totalMs ~/ 60000);
    final seconds = (totalMs % 60000) ~/ 1000;
    final centis = (totalMs % 1000) ~/ 10;

    final mm = minutes.toString().padLeft(2, '0');
    final ss = seconds.toString().padLeft(2, '0');
    final cc = centis.toString().padLeft(2, '0');

    return '$mm:$ss.$cc';
  }
}

class _EmptyLaps extends StatelessWidget {
  const _EmptyLaps();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.flag_outlined, size: 56),
            SizedBox(height: 12),
            Text(
              'No laps yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 6),
            Text(
              'Start the stopwatch and tap Lap.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
