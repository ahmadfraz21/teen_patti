// ─────────────────────────────────────────
//  card.dart  –  Card model for Teen Patti
// ─────────────────────────────────────────

enum Suit { spades, hearts, diamonds, clubs }

enum Rank {
  two,
  three,
  four,
  five,
  six,
  seven,
  eight,
  nine,
  ten,
  jack,
  queen,
  king,
  ace,
}

class Card {
  final Suit suit;
  final Rank rank;

  const Card({required this.suit, required this.rank});

  // Numeric value for comparisons (2 = lowest, Ace = highest)
  int get value => rank.index + 2;

  String get suitSymbol {
    switch (suit) {
      case Suit.spades:   return '♠';
      case Suit.hearts:   return '♥';
      case Suit.diamonds: return '♦';
      case Suit.clubs:    return '♣';
    }
  }

  String get rankLabel {
    switch (rank) {
      case Rank.ace:   return 'A';
      case Rank.king:  return 'K';
      case Rank.queen: return 'Q';
      case Rank.jack:  return 'J';
      case Rank.ten:   return '10';
      default:         return '${rank.index + 2}';
    }
  }

  @override
  String toString() => '$rankLabel${suitSymbol}';

  @override
  bool operator ==(Object other) =>
      other is Card && other.suit == suit && other.rank == rank;

  @override
  int get hashCode => Object.hash(suit, rank);
}
