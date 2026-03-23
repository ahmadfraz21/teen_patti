import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/game_provider.dart';
import 'game_screen.dart';

class LobbyScreen extends StatefulWidget {
  const LobbyScreen({super.key});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  void _startLocalGame(BuildContext context) {
    final auth = context.read<AuthProvider>();
    // For testing: create 3 players including current user
    context.read<GameProvider>().startLocalGame([
      auth.user?.name ?? 'You',
      'Bot Ravi',
      'Bot Priya',
    ]);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const GameScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: const Color(0xFF0D3B1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('🃏 Teen Patti', style: TextStyle(color: Color(0xFFFFD700))),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                user?.name ?? '',
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Chips display
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('🟡', style: TextStyle(fontSize: 24)),
                      SizedBox(width: 8),
                      Text(
                        '1,000 chips',
                        style: TextStyle(
                          color: Color(0xFFFFD700),
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Quick play (local test)
                _LobbyButton(
                  icon: '⚡',
                  label: 'Quick Play',
                  subtitle: 'Play vs bots (test mode)',
                  onTap: () => _startLocalGame(context),
                ),
                const SizedBox(height: 16),

                // Multiplayer (coming soon)
                _LobbyButton(
                  icon: '👥',
                  label: 'Multiplayer',
                  subtitle: 'Coming soon',
                  onTap: null,
                ),
                const SizedBox(height: 16),

                _LobbyButton(
                  icon: '🏆',
                  label: 'Tournament',
                  subtitle: 'Coming soon',
                  onTap: null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LobbyButton extends StatelessWidget {
  final String icon;
  final String label;
  final String subtitle;
  final VoidCallback? onTap;

  const _LobbyButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onTap == null ? 0.4 : 1.0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  Text(subtitle,
                      style: const TextStyle(color: Colors.white54, fontSize: 13)),
                ],
              ),
              const Spacer(),
              if (onTap != null)
                const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
