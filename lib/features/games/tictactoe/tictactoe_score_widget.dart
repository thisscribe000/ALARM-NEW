import 'package:flutter/material.dart';

import 'tictactoe_score.dart';

class TicTacToeScoreWidget extends StatelessWidget {
  final TicTacToeScore score;

  const TicTacToeScoreWidget({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const Icon(Icons.grid_3x3),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Tic-Tac-Toe score',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            _Pill(label: 'W', value: score.wins),
            const SizedBox(width: 6),
            _Pill(label: 'L', value: score.losses),
            const SizedBox(width: 6),
            _Pill(label: 'D', value: score.draws),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final int value;

  const _Pill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Text('$label: $value'),
    );
  }
}
