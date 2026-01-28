import 'dart:math';

import 'package:flutter/material.dart';

import 'tictactoe_score.dart';
import 'tictactoe_score_store.dart';

enum _Cell { empty, x, o }

class TicTacToeGameScreen extends StatefulWidget {
  /// If true: when game ends, we pop back with result immediately.
  final bool dismissOnFinish;

  const TicTacToeGameScreen({super.key, this.dismissOnFinish = true});

  @override
  State<TicTacToeGameScreen> createState() => _TicTacToeGameScreenState();
}

class _TicTacToeGameScreenState extends State<TicTacToeGameScreen> {
  final _store = TicTacToeScoreStore();
  TicTacToeScore _score = TicTacToeScore.empty;

  final _rng = Random();
  List<_Cell> _board = List<_Cell>.filled(9, _Cell.empty);

  bool _xTurn = true; // player is X
  String _status = 'Your turn (X)';
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _loadScore();
  }

  Future<void> _loadScore() async {
    final s = await _store.load();
    if (!mounted) return;
    setState(() => _score = s);
  }

  Future<void> _saveScore(TicTacToeScore s) async {
    setState(() => _score = s);
    await _store.save(s);
  }

  void _resetGame() {
    setState(() {
      _board = List<_Cell>.filled(9, _Cell.empty);
      _xTurn = true;
      _status = 'Your turn (X)';
      _finished = false;
    });
  }

  void _tap(int idx) {
    if (_finished) return;
    if (!_xTurn) return; // wait for AI
    if (_board[idx] != _Cell.empty) return;

    setState(() {
      _board[idx] = _Cell.x;
      _xTurn = false;
    });

    final res = _checkResult();
    if (res != null) {
      _finish(res);
      return;
    }

    _aiMove();
  }

  void _aiMove() {
    final empties = <int>[];
    for (var i = 0; i < _board.length; i++) {
      if (_board[i] == _Cell.empty) empties.add(i);
    }

    if (empties.isEmpty) {
      _finish('draw');
      return;
    }

    // Simple AI: random available spot
    final pick = empties[_rng.nextInt(empties.length)];

    Future.delayed(const Duration(milliseconds: 250), () {
      if (!mounted || _finished) return;

      setState(() {
        _board[pick] = _Cell.o;
        _xTurn = true;
      });

      final res = _checkResult();
      if (res != null) {
        _finish(res);
      } else {
        setState(() => _status = 'Your turn (X)');
      }
    });
  }

  String? _checkResult() {
    const wins = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    for (final line in wins) {
      final a = _board[line[0]];
      final b = _board[line[1]];
      final c = _board[line[2]];
      if (a != _Cell.empty && a == b && b == c) {
        return a == _Cell.x ? 'win' : 'loss';
      }
    }

    final anyEmpty = _board.any((c) => c == _Cell.empty);
    if (!anyEmpty) return 'draw';

    return null;
  }

  Future<void> _finish(String result) async {
    if (_finished) return;

    setState(() {
      _finished = true;
      if (result == 'win') _status = 'You won! ✅';
      if (result == 'loss') _status = 'You lost! 😅';
      if (result == 'draw') _status = 'Draw 🤝';
    });

    // Update score
    TicTacToeScore next = _score;
    if (result == 'win') next = next.copyWith(wins: next.wins + 1);
    if (result == 'loss') next = next.copyWith(losses: next.losses + 1);
    if (result == 'draw') next = next.copyWith(draws: next.draws + 1);

    await _saveScore(next);

    // If used as alarm dismiss gate, close immediately after finish
    if (widget.dismissOnFinish) {
      if (!mounted) return;
      Navigator.of(context).pop(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tic-Tac-Toe'),
        actions: [
          IconButton(
            tooltip: 'Reset',
            onPressed: _resetGame,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _status,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    const Icon(Icons.grid_3x3),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Score',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    _pill('W', _score.wins, context),
                    const SizedBox(width: 6),
                    _pill('L', _score.losses, context),
                    const SizedBox(width: 6),
                    _pill('D', _score.draws, context),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 1,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: 9,
                itemBuilder: (context, i) {
                  return _cellButton(i);
                },
              ),
            ),
            const SizedBox(height: 16),
            if (!widget.dismissOnFinish)
              FilledButton.icon(
                onPressed: _resetGame,
                icon: const Icon(Icons.refresh),
                label: const Text('New game'),
              ),
            if (widget.dismissOnFinish)
              const Text(
                'Finish the game to dismiss the alarm.',
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }

  Widget _cellButton(int idx) {
    final v = _board[idx];
    final text = v == _Cell.x
        ? 'X'
        : v == _Cell.o
            ? 'O'
            : '';

    return InkWell(
      onTap: () => _tap(idx),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }

  Widget _pill(String label, int value, BuildContext context) {
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
