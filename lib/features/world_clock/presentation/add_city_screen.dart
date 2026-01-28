import 'package:flutter/material.dart';

import '../domain/world_city.dart';

class AddCityScreen extends StatefulWidget {
  final Set<String> existingIds;

  const AddCityScreen({super.key, required this.existingIds});

  @override
  State<AddCityScreen> createState() => _AddCityScreenState();
}

class _AddCityScreenState extends State<AddCityScreen> {
  String _query = '';

  // Manual UTC offsets. Simple + reliable.
  // You can add more later.
  static const List<WorldCity> presets = [
    WorldCity(id: 'lagos_ng', name: 'Lagos', country: 'Nigeria', utcOffsetMinutes: 60),
    WorldCity(id: 'london_uk', name: 'London', country: 'UK', utcOffsetMinutes: 0),
    WorldCity(id: 'newyork_us', name: 'New York', country: 'USA', utcOffsetMinutes: -300),
    WorldCity(id: 'dubai_ae', name: 'Dubai', country: 'UAE', utcOffsetMinutes: 240),
    WorldCity(id: 'tokyo_jp', name: 'Tokyo', country: 'Japan', utcOffsetMinutes: 540),
    WorldCity(id: 'sydney_au', name: 'Sydney', country: 'Australia', utcOffsetMinutes: 600),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = presets.where((c) {
      final q = _query.trim().toLowerCase();
      if (q.isEmpty) return true;
      return c.name.toLowerCase().contains(q) || c.country.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Add City')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search city (e.g. Lagos, London)',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              itemCount: filtered.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final city = filtered[index];
                final already = widget.existingIds.contains(city.id);

                return Card(
                  child: ListTile(
                    enabled: !already,
                    leading: const Icon(Icons.public),
                    title: Text(city.displayName),
                    subtitle: Text(_fmtOffset(city.utcOffsetMinutes)),
                    trailing: already
                        ? const Text('Added')
                        : const Icon(Icons.add),
                    onTap: already ? null : () => Navigator.of(context).pop(city),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _fmtOffset(int minutes) {
    final sign = minutes >= 0 ? '+' : '-';
    final abs = minutes.abs();
    final h = abs ~/ 60;
    final m = abs % 60;
    final mm = m.toString().padLeft(2, '0');
    return 'UTC$sign$h:$mm';
  }
}
