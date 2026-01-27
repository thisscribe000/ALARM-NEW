import 'package:flutter/material.dart';

class StopwatchTab extends StatelessWidget {
  const StopwatchTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stopwatch')),
      body: const Center(
        child: Text(
          'Stopwatch tab\n(We build this later)',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
