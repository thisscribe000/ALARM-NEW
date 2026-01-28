import 'dart:async';

import 'package:flutter/material.dart';

import '../data/world_clock_store.dart';
import '../domain/world_city.dart';
import 'add_city_screen.dart';

class WorldClockTab extends StatefulWidget {
  const WorldClockTab({super.key});

  @override
  State<WorldClockTab> createState() => _WorldClockTabState();
}

class _WorldClockTabState extends State<WorldClockTab> {
  final _store = WorldClockStore();

  bool _loading = true;
  List<WorldCity> _cities = [];

  Timer? _ticker;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _load();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final cities = await _store.load();
    if (!mounted) return;
    setState(() {
      _cities = cities;
      _loading = false;
    });
  }

  Future<void> _persist() async {
    await _store.save(_cities);
  }

  Future<void> _addCity() async {
    final existingIds = _cities.map((c) => c.id).toSet();
    final picked = await Navigator.of(context).push<WorldCity>(
      MaterialPageRoute(builder: (_) => AddCityScreen(existingIds: existingIds)),
    );

    if (!mounted) return;
    if (picked == null) return;

    setState(() => _cities = [..._cities, picked]);
    await _persist();
  }

  Future<void> _removeCity(WorldCity city) async {
    setState(() => _cities = _cities.where((c) => c.id != city.id).toList());
    await _persist();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('World Clock'),
        actions: [
          IconButton(
            tooltip: 'Reload',
            onPressed: _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _cities.isEmpty
              ? _EmptyWorldClock(onAdd: _addCity)
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
                  itemCount: _cities.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final city = _cities[index];
                    final cityTime = _cityTime(_now, city.utcOffsetMinutes);
                    final diffText = _diffFromLocal(city.utcOffsetMinutes);

                    return Dismissible(
                      key: ValueKey(city.id),
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
                                title: const Text('Remove city?'),
                                content: Text('Remove ${city.displayName}?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text('Remove'),
                                  ),
                                ],
                              ),
                            ) ??
                            false;
                      },
                      onDismissed: (_) => _removeCity(city),
                      child: Card(
                        child: ListTile(
                          leading: const Icon(Icons.public),
                          title: Text(
                            city.displayName,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            '${_fmtOffset(city.utcOffsetMinutes)} • $diffText',
                          ),
                          trailing: Text(
                            _fmtTime(cityTime, use24h: true),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addCity,
        icon: const Icon(Icons.add),
        label: const Text('Add City'),
      ),
    );
  }

  /// Local time + (cityUTC - localUTC)
  DateTime _cityTime(DateTime localNow, int cityUtcOffsetMinutes) {
    final localOffset = localNow.timeZoneOffset.inMinutes;
    final delta = cityUtcOffsetMinutes - localOffset;
    return localNow.add(Duration(minutes: delta));
  }

  String _diffFromLocal(int cityUtcOffsetMinutes) {
    final localOffset = _now.timeZoneOffset.inMinutes;
    final diff = cityUtcOffsetMinutes - localOffset;

    if (diff == 0) return 'Same as local';

    final ahead = diff > 0;
    final abs = diff.abs();
    final h = abs ~/ 60;
    final m = abs % 60;

    final mm = m == 0 ? '' : ' ${m}m';
    return ahead ? '+${h}h$mm ahead' : '-${h}h$mm behind';
  }

  String _fmtOffset(int minutes) {
    final sign = minutes >= 0 ? '+' : '-';
    final abs = minutes.abs();
    final h = abs ~/ 60;
    final m = abs % 60;
    final mm = m.toString().padLeft(2, '0');
    return 'UTC$sign$h:$mm';
  }

  String _fmtTime(DateTime dt, {required bool use24h}) {
    final h = dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');

    if (use24h) {
      final hh = h.toString().padLeft(2, '0');
      return '$hh:$m';
    }

    final isPm = h >= 12;
    var hh = h % 12;
    if (hh == 0) hh = 12;
    final suffix = isPm ? 'PM' : 'AM';
    return '$hh:$m $suffix';
  }
}

class _EmptyWorldClock extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyWorldClock({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.public, size: 56),
            const SizedBox(height: 12),
            const Text(
              'No cities yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            const Text(
              'Add cities to see their current time.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add City'),
            ),
          ],
        ),
      ),
    );
  }
}
