import 'package:flutter/material.dart';

class AlarmsTab extends StatelessWidget {
  const AlarmsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alarm')),
      body: const Center(
        child: Text(
          'Alarms tab\n(We build alarms next)',
          textAlign: TextAlign.center,
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add Alarm (coming next step)')),
          );
        },
        icon: const Icon(Icons.add_alarm),
        label: const Text('Add'),
      ),
    );
  }
}
