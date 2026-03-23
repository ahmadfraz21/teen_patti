// ─────────────────────────────────────────
//  deck.dart  –  52-card deck
// ─────────────────────────────────────────

import 'dart:math';
import 'card.dart';

class Deck {
  final List<Card> _cards = [];
  final Random _rng;

  Deck({int? seed}) : _rng = Random(seed) {
    _build();
  }

  void _build() {
    _cards.clear();
    for (final suit in Suit.values) {
      for (final rank in Rank.values) {
        _cards.add(Card(suit: suit, rank: rank));
      }
    }
  }

  /// Fisher-Yates shuffle
  void shuffle() {
    for (int i = _cards.length - 1; i > 0; i--) {
      final j = _rng.nextInt(i + 1);
      final tmp = _cards[i];
      _cards[i] = _cards[j];
      _cards[j] = tmp;
    }
  }

  /// Deal [count] cards off the top
  List<Card> deal(int count) {
    if (count > _cards.length) {
      throw StateError('Not enough cards in deck');
    }
    final hand = _cards.sublist(0, count);
    _cards.removeRange(0, count);
    return hand;
  }

  int get remaining => _cards.length;

  /// Reset and reshuffle
  void reset() {
    _build();
    shuffle();
  }
}
