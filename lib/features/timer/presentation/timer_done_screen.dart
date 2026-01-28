import 'package:flutter/material.dart';

class TimerDoneScreen extends StatelessWidget {
  final String label;

  const TimerDoneScreen({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
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
                      'TIMER DONE',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Icon(Icons.hourglass_bottom, size: 90),
              const SizedBox(height: 18),
              Text(
                label.isEmpty ? 'Time is up!' : label,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'Tap dismiss to stop.',
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.check),
                label: const Text('Dismiss'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                  minimumSize: const Size.fromHeight(52),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
