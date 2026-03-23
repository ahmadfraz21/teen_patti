// ─────────────────────────────────────────
//  hand_evaluator.dart  –  Teen Patti hand ranking engine
// ─────────────────────────────────────────

import 'card.dart';

// Hand ranks from highest (6) to lowest (0)
enum HandRank {
  highCard,       // 0 – no combination
  pair,           // 1 – two cards same rank
  flush,          // 2 – same suit, not sequence
  sequence,       // 3 – consecutive ranks, mixed suits
  pureSequence,   // 4 – consecutive ranks, same suit (straight flush)
  trail,          // 5 – three of a kind
}

class HandResult {
  final HandRank rank;
  final List<int> tiebreakers; // for comparing equal ranks
  final String label;

  const HandResult({
    required this.rank,
    required this.tiebreakers,
    required this.label,
  });

  /// Returns > 0 if this hand beats [other], < 0 if it loses, 0 if tied
  int compareTo(HandResult other) {
    // First compare hand rank
    final rankDiff = rank.index - other.rank.index;
    if (rankDiff != 0) return rankDiff;

    // Same hand rank – compare tiebreakers in order
    for (int i = 0; i < tiebreakers.length && i < other.tiebreakers.length; i++) {
      final diff = tiebreakers[i] - other.tiebreakers[i];
      if (diff != 0) return diff;
    }
    return 0;
  }

  bool beats(HandResult other) => compareTo(other) > 0;

  @override
  String toString() => label;
}

class HandEvaluator {
  /// Evaluate a 3-card Teen Patti hand
  static HandResult evaluate(List<Card> hand) {
    assert(hand.length == 3, 'Teen Patti needs exactly 3 cards');

    // Sort descending by value for easy tiebreaking
    final sorted = [...hand]..sort((a, b) => b.value - a.value);
    final values = sorted.map((c) => c.value).toList();

    final isFlush    = _isFlush(hand);
    final isSequence = _isSequence(sorted);

    // ── Trail (Three of a kind) ──────────────────
    if (values[0] == values[1] && values[1] == values[2]) {
      return HandResult(
        rank: HandRank.trail,
        tiebreakers: [values[0]],
        label: 'Trail (${sorted[0].rankLabel}s)',
      );
    }

    // ── Pure Sequence (Straight Flush) ───────────
    if (isFlush && isSequence) {
      return HandResult(
        rank: HandRank.pureSequence,
        tiebreakers: values,
        label: 'Pure Sequence (${sorted[0].rankLabel}-${sorted[1].rankLabel}-${sorted[2].rankLabel})',
      );
    }

    // ── Sequence (Straight) ──────────────────────
    if (isSequence) {
      return HandResult(
        rank: HandRank.sequence,
        tiebreakers: values,
        label: 'Sequence (${sorted[0].rankLabel}-${sorted[1].rankLabel}-${sorted[2].rankLabel})',
      );
    }

    // ── Flush (Color) ────────────────────────────
    if (isFlush) {
      return HandResult(
        rank: HandRank.flush,
        tiebreakers: values,
        label: 'Flush (${sorted[0].rankLabel}-${sorted[1].rankLabel}-${sorted[2].rankLabel})',
      );
    }

    // ── Pair ─────────────────────────────────────
    if (values[0] == values[1] || values[1] == values[2]) {
      final pairVal   = values[0] == values[1] ? values[0] : values[1];
      final kickerVal = values[0] == values[1] ? values[2] : values[0];
      return HandResult(
        rank: HandRank.pair,
        tiebreakers: [pairVal, kickerVal],
        label: 'Pair of ${sorted[0].rankLabel}s',
      );
    }

    // ── High Card ────────────────────────────────
    return HandResult(
      rank: HandRank.highCard,
      tiebreakers: values,
      label: 'High Card (${sorted[0].rankLabel})',
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  static bool _isFlush(List<Card> hand) =>
      hand.every((c) => c.suit == hand[0].suit);

  static bool _isSequence(List<Card> sorted) {
    final v = sorted.map((c) => c.value).toList();

    // Normal sequence: each card 1 less than previous
    if (v[0] - v[1] == 1 && v[1] - v[2] == 1) return true;

    // Special case: A-2-3 (Ace plays low)
    // Ace=14, 3=3, 2=2 → sorted descending as [14,3,2]
    if (v[0] == 14 && v[1] == 3 && v[2] == 2) return true;

    return false;
  }

  /// Compare two 3-card hands, returns index of winner (0 or 1), or -1 for tie
  static int winner(List<Card> handA, List<Card> handB) {
    final a = evaluate(handA);
    final b = evaluate(handB);
    final cmp = a.compareTo(b);
    if (cmp > 0) return 0;
    if (cmp < 0) return 1;
    return -1; // tie
  }
}
