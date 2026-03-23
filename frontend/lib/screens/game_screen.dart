import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../providers/auth_provider.dart';
import '../game/game_engine.dart';
import '../game/player.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D5C2E),
      body: SafeArea(
        child: Consumer<GameProvider>(
          builder: (context, game, _) {
            if (game.lastResult != null) {
              return _WinnerOverlay(result: game.lastResult!, game: game);
            }
            return Column(
              children: [
                _TopBar(pot: game.pot),
                Expanded(child: _TableArea(game: game)),
                _ActionBar(game: game),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── Top bar ────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final int pot;
  const _TopBar({required this.pot});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white70),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black38,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '🟡 Pot: $pot',
              style: const TextStyle(
                color: Color(0xFFFFD700),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const Spacer(),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

// ── Table ──────────────────────────────────────────────────────────────────
class _TableArea extends StatelessWidget {
  final GameProvider game;
  const _TableArea({required this.game});

  @override
  Widget build(BuildContext context) {
    final players = game.players;
    final engine  = game.engine;
    final current = engine?.currentPlayer;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 8),
          // Other players
          ...players.skip(1).map((p) => _PlayerRow(
                player: p,
                isCurrentTurn: p.id == current?.id,
                showCards: p.hasFolded,
              )),
          const Spacer(),
          // Current user (always first player)
          if (players.isNotEmpty)
            _CurrentPlayerArea(
              player: players.first,
              isCurrentTurn: players.first.id == current?.id,
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

// ── Player row (opponents) ─────────────────────────────────────────────────
class _PlayerRow extends StatelessWidget {
  final Player player;
  final bool isCurrentTurn;
  final bool showCards;

  const _PlayerRow({
    required this.player,
    required this.isCurrentTurn,
    required this.showCards,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentTurn ? Colors.white15 : Colors.black26,
        borderRadius: BorderRadius.circular(14),
        border: isCurrentTurn
            ? Border.all(color: const Color(0xFFFFD700), width: 1.5)
            : null,
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            backgroundColor: isCurrentTurn
                ? const Color(0xFFFFD700)
                : Colors.white24,
            child: Text(
              player.name[0].toUpperCase(),
              style: TextStyle(
                color: isCurrentTurn ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(player.name,
                  style: TextStyle(
                    color: player.hasFolded ? Colors.white38 : Colors.white,
                    fontWeight: FontWeight.w600,
                    decoration: player.hasFolded
                        ? TextDecoration.lineThrough
                        : null,
                  )),
              Text(
                '🟡 ${player.chips}',
                style: const TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ],
          ),

          const Spacer(),

          // Cards (face down or revealed)
          Row(
            children: List.generate(
              3,
              (i) => _CardWidget(
                card: showCards && player.hand.isNotEmpty
                    ? player.hand[i].toString()
                    : null,
                isFaceDown: !showCards,
                folded: player.hasFolded,
              ),
            ),
          ),

          if (player.isSeen)
            const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Text('👁', style: TextStyle(fontSize: 14)),
            ),
        ],
      ),
    );
  }
}

// ── Current player area ────────────────────────────────────────────────────
class _CurrentPlayerArea extends StatelessWidget {
  final Player player;
  final bool isCurrentTurn;

  const _CurrentPlayerArea({
    required this.player,
    required this.isCurrentTurn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(16),
        border: isCurrentTurn
            ? Border.all(color: const Color(0xFFFFD700), width: 2)
            : null,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                player.name,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
              const SizedBox(width: 12),
              Text('🟡 ${player.chips}',
                  style: const TextStyle(color: Color(0xFFFFD700))),
            ],
          ),
          const SizedBox(height: 12),
          // Your cards (face up)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: player.hand.isEmpty
                ? [const Text('Dealing...', style: TextStyle(color: Colors.white54))]
                : player.hand
                    .map((c) => _CardWidget(
                          card: c.toString(),
                          isFaceDown: false,
                          folded: player.hasFolded,
                        ))
                    .toList(),
          ),
        ],
      ),
    );
  }
}

// ── Card widget ────────────────────────────────────────────────────────────
class _CardWidget extends StatelessWidget {
  final String? card;
  final bool isFaceDown;
  final bool folded;

  const _CardWidget({
    this.card,
    required this.isFaceDown,
    this.folded = false,
  });

  @override
  Widget build(BuildContext context) {
    final isRed = card != null &&
        (card!.contains('♥') || card!.contains('♦'));

    return Opacity(
      opacity: folded ? 0.35 : 1.0,
      child: Container(
        width: 44,
        height: 64,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          color: isFaceDown ? const Color(0xFF1565C0) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white24),
          boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 4, offset: Offset(1, 2))],
        ),
        child: Center(
          child: isFaceDown
              ? const Text('🂠',
                  style: TextStyle(fontSize: 28, color: Colors.white70))
              : Text(
                  card ?? '',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isRed ? Colors.red : Colors.black,
                  ),
                ),
        ),
      ),
    );
  }
}

// ── Action bar ─────────────────────────────────────────────────────────────
class _ActionBar extends StatelessWidget {
  final GameProvider game;
  const _ActionBar({required this.game});

  @override
  Widget build(BuildContext context) {
    final engine = game.engine;
    final myPlayer = game.players.isNotEmpty ? game.players.first : null;
    final isMyTurn = engine?.currentPlayer.id == myPlayer?.id;
    final active = isMyTurn && game.phase == GamePhase.betting;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      color: Colors.black45,
      child: Row(
        children: [
          // Fold
          Expanded(
            child: _ActionButton(
              label: 'Fold',
              color: Colors.red.shade700,
              enabled: active,
              onTap: () => game.performAction(BetAction.fold),
            ),
          ),
          const SizedBox(width: 8),
          // Blind / Seen
          Expanded(
            flex: 2,
            child: _ActionButton(
              label: myPlayer?.isSeen == true ? 'Chaal (Seen)' : 'Chaal (Blind)',
              color: const Color(0xFF2E7D32),
              enabled: active,
              onTap: () => game.performAction(
                myPlayer?.isSeen == true ? BetAction.seen : BetAction.blind,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Show
          Expanded(
            child: _ActionButton(
              label: 'Show',
              color: const Color(0xFFE65100),
              enabled: active && (engine?.activePlayers.length ?? 0) == 2,
              onTap: () => game.performAction(BetAction.show),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool enabled;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.35,
      child: ElevatedButton(
        onPressed: enabled ? onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          label,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

// ── Winner overlay ─────────────────────────────────────────────────────────
class _WinnerOverlay extends StatelessWidget {
  final GameResult result;
  final GameProvider game;

  const _WinnerOverlay({required this.result, required this.game});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFF0D3B1A),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFFFD700), width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🏆', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 12),
            Text(
              '${result.winner.name} wins!',
              style: const TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 28,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Won 🟡 ${result.potWon} chips',
              style: const TextStyle(color: Colors.white70, fontSize: 18),
            ),
            if (result.winnerHand != null) ...[
              const SizedBox(height: 6),
              Text(
                result.winnerHand!.label,
                style: const TextStyle(color: Colors.white54),
              ),
            ],
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: game.startNewRound,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Next Round',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
