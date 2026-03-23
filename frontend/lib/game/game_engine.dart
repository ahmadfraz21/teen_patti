// ─────────────────────────────────────────
//  game_engine.dart  –  Teen Patti game loop
// ─────────────────────────────────────────

import 'card.dart';
import 'deck.dart';
import 'player.dart';
import 'hand_evaluator.dart';

enum GamePhase {
  idle,         // waiting for players
  dealing,      // cards being dealt
  betting,      // betting round in progress
  showdown,     // hands revealed, winner decided
  gameOver,     // not enough chips to continue
}

enum BetAction {
  blind,    // bet without seeing cards (chaal × blind multiplier)
  seen,     // bet after seeing cards
  fold,     // pack / quit this round
  show,     // request showdown (costs seen-bet amount)
  sideshow, // request sideshow with previous player
}

class GameResult {
  final Player winner;
  final HandResult? winnerHand; // null if everyone else folded
  final int potWon;
  final String reason;

  const GameResult({
    required this.winner,
    this.winnerHand,
    required this.potWon,
    required this.reason,
  });
}

class GameEngine {
  // ── State ──────────────────────────────────────────────────────────────
  final List<Player> players;
  final int bootAmount;   // mandatory ante every round
  final int minBet;       // minimum chaal for seen players

  late Deck _deck;
  int _pot = 0;
  int _currentBet = 0;    // current stake (seen amount)
  int _turnIndex = 0;
  GamePhase _phase = GamePhase.idle;

  // Callbacks – UI layer connects these
  void Function(String message)? onLog;
  void Function(GamePhase phase)? onPhaseChange;
  void Function(Player player)? onTurnChange;
  void Function(GameResult result)? onRoundEnd;

  GameEngine({
    required this.players,
    this.bootAmount = 10,
    this.minBet = 10,
  }) : _deck = Deck();

  // ── Getters ────────────────────────────────────────────────────────────
  GamePhase get phase => _phase;
  int get pot => _pot;
  int get currentBet => _currentBet;
  Player get currentPlayer => players[_turnIndex];
  List<Player> get activePlayers => players.where((p) => p.isActive).toList();

  // ── Round lifecycle ────────────────────────────────────────────────────

  /// Start a new round
  void startRound() {
    _log('── New round starting ──');
    _deck.reset();

    // Reset all players
    for (final p in players) {
      p.resetForRound();
      p.status = PlayerStatus.active;
    }

    // Collect boot (ante)
    _pot = 0;
    for (final p in players) {
      final paid = p.placeBet(bootAmount);
      _pot += paid;
    }
    _log('Pot after boot: $_pot');

    // Deal 3 cards face-down to each player
    for (final p in players) {
      p.hand = _deck.deal(3);
    }

    _currentBet = minBet;
    _turnIndex = 0;
    _setPhase(GamePhase.betting);
    _log('${currentPlayer.name}\'s turn');
    onTurnChange?.call(currentPlayer);
  }

  // ── Player actions ─────────────────────────────────────────────────────

  void performAction(BetAction action) {
    if (_phase != GamePhase.betting) return;

    final player = currentPlayer;

    switch (action) {
      case BetAction.fold:
        _handleFold(player);
        break;
      case BetAction.blind:
        _handleBlind(player);
        break;
      case BetAction.seen:
        _handleSeen(player);
        break;
      case BetAction.show:
        _handleShow(player);
        break;
      case BetAction.sideshow:
        _handleSideshow(player);
        break;
    }
  }

  void _handleFold(Player player) {
    player.fold();
    _log('${player.name} folded');
    if (!_checkRoundOver()) _advanceTurn();
  }

  void _handleBlind(Player player) {
    // Blind players bet half the current stake
    final betAmount = player.isSeen ? _currentBet : (_currentBet ~/ 2).clamp(minBet ~/ 2, 999999);
    final paid = player.placeBet(betAmount);
    _pot += paid;
    _log('${player.name} bets blind: $paid (pot: $_pot)');
    _advanceTurn();
  }

  void _handleSeen(Player player) {
    // Looking at cards upgrades blind player to seen
    if (!player.isSeen) player.seeCards();

    final paid = player.placeBet(_currentBet);
    _pot += paid;
    _log('${player.name} calls seen: $paid (pot: $_pot)');
    _advanceTurn();
  }

  void _handleShow(Player player) {
    // Show is only valid when exactly 2 active players remain
    if (activePlayers.length != 2) {
      _log('Show only allowed when 2 players remain');
      return;
    }
    if (!player.isSeen) player.seeCards();
    final paid = player.placeBet(_currentBet);
    _pot += paid;
    _log('${player.name} calls Show');
    _resolveShowdown();
  }

  void _handleSideshow(Player player) {
    // Find previous active player
    final prev = _previousActivePlayer();
    if (prev == null) return;

    if (!player.isSeen) player.seeCards();

    final evalA = HandEvaluator.evaluate(player.hand);
    final evalB = HandEvaluator.evaluate(prev.hand);
    final cmp   = evalA.compareTo(evalB);

    if (cmp >= 0) {
      // Current player wins sideshow → prev must fold
      _log('${player.name} wins sideshow vs ${prev.name}');
      prev.fold();
    } else {
      // Current player loses → they must fold
      _log('${player.name} loses sideshow vs ${prev.name} and folds');
      player.fold();
    }
    if (!_checkRoundOver()) _advanceTurn();
  }

  // ── Internal helpers ───────────────────────────────────────────────────

  void _advanceTurn() {
    // Move to next active player
    int next = (_turnIndex + 1) % players.length;
    int attempts = 0;
    while (!players[next].isActive && attempts < players.length) {
      next = (next + 1) % players.length;
      attempts++;
    }
    _turnIndex = next;
    _log('${currentPlayer.name}\'s turn');
    onTurnChange?.call(currentPlayer);
  }

  bool _checkRoundOver() {
    final active = activePlayers;
    if (active.length == 1) {
      _endRound(winner: active.first, reason: 'All others folded');
      return true;
    }
    return false;
  }

  void _resolveShowdown() {
    _setPhase(GamePhase.showdown);
    final active = activePlayers;
    if (active.isEmpty) return;

    Player best = active.first;
    HandResult bestResult = HandEvaluator.evaluate(best.hand);

    for (final p in active.skip(1)) {
      final result = HandEvaluator.evaluate(p.hand);
      if (result.beats(bestResult)) {
        best = p;
        bestResult = result;
      }
    }

    _endRound(winner: best, winnerHand: bestResult, reason: 'Showdown');
  }

  void _endRound({
    required Player winner,
    HandResult? winnerHand,
    required String reason,
  }) {
    _setPhase(GamePhase.showdown);
    winner.chips += _pot;
    _log('${winner.name} wins $_pot chips! ($reason)');

    final result = GameResult(
      winner: winner,
      winnerHand: winnerHand,
      potWon: _pot,
      reason: reason,
    );
    onRoundEnd?.call(result);
    _pot = 0;

    // Check if any player is out of chips
    final playersWithChips = players.where((p) => p.chips >= bootAmount).toList();
    if (playersWithChips.length < 2) {
      _setPhase(GamePhase.gameOver);
      _log('Game over! ${playersWithChips.isNotEmpty ? playersWithChips.first.name : "Nobody"} wins!');
    } else {
      _setPhase(GamePhase.idle);
    }
  }

  Player? _previousActivePlayer() {
    int idx = (_turnIndex - 1 + players.length) % players.length;
    int attempts = 0;
    while (!players[idx].isActive && attempts < players.length) {
      idx = (idx - 1 + players.length) % players.length;
      attempts++;
    }
    return players[idx].isActive ? players[idx] : null;
  }

  void _setPhase(GamePhase phase) {
    _phase = phase;
    onPhaseChange?.call(phase);
  }

  void _log(String msg) => onLog?.call(msg);
}
