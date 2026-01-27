import 'package:flutter/material.dart';

class TimerTab extends StatelessWidget {
  const TimerTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Timer')),
      body: const Center(
        child: Text(
          'Timer tab\n(We build this later)',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
