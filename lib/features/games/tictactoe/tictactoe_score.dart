class TicTacToeScore {
  final int wins;
  final int losses;
  final int draws;

  const TicTacToeScore({
    required this.wins,
    required this.losses,
    required this.draws,
  });

  static const empty = TicTacToeScore(wins: 0, losses: 0, draws: 0);

  TicTacToeScore copyWith({
    int? wins,
    int? losses,
    int? draws,
  }) {
    return TicTacToeScore(
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      draws: draws ?? this.draws,
    );
  }

  Map<String, dynamic> toJson() => {
        'wins': wins,
        'losses': losses,
        'draws': draws,
      };

  static TicTacToeScore fromJson(Map<String, dynamic> json) {
    return TicTacToeScore(
      wins: (json['wins'] ?? 0) as int,
      losses: (json['losses'] ?? 0) as int,
      draws: (json['draws'] ?? 0) as int,
    );
  }
}
