// ─────────────────────────────────────────
//  player.dart  –  Player state
// ─────────────────────────────────────────

import 'card.dart';

enum PlayerStatus {
  waiting,  // not yet dealt in
  active,   // in the round
  folded,   // packed / folded
  allIn,    // out of chips but still in hand
}

class Player {
  final String id;
  final String name;

  int chips;
  List<Card> hand;
  PlayerStatus status;
  bool isSeen;       // has the player looked at their cards?
  int betInRound;    // total bet this round

  Player({
    required this.id,
    required this.name,
    this.chips = 1000,
  })  : hand = [],
        status = PlayerStatus.waiting,
        isSeen = false,
        betInRound = 0;

  bool get isActive => status == PlayerStatus.active;
  bool get hasFolded => status == PlayerStatus.folded;

  /// Player looks at their cards (blind → seen)
  void seeCards() => isSeen = true;

  /// Deduct bet from chip stack, add to round total
  /// Returns actual amount deducted (may be less if going all-in)
  int placeBet(int amount) {
    final actual = amount.clamp(0, chips);
    chips -= actual;
    betInRound += actual;
    if (chips == 0) status = PlayerStatus.allIn;
    return actual;
  }

  void fold() => status = PlayerStatus.folded;

  void resetForRound() {
    hand = [];
    status = PlayerStatus.waiting;
    isSeen = false;
    betInRound = 0;
  }

  @override
  String toString() => '$name [$chips chips]';
}
