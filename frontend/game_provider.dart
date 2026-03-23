import 'package:flutter/foundation.dart';
import '../game/card.dart' as tp;
import '../game/player.dart';
import '../game/game_engine.dart';

enum ConnectionState { disconnected, connecting, connected }

class GameProvider extends ChangeNotifier {
  final String serverUrl;

  GameEngine? _engine;
  ConnectionState _connectionState = ConnectionState.disconnected;
  String _roomCode = '';
  List<String> _logs = [];
  GameResult? _lastResult;

  GameProvider(this.serverUrl);

  // ── Getters ────────────────────────────────────────────────────────────
  ConnectionState get connectionState => _connectionState;
  String get roomCode => _roomCode;
  List<String> get logs => List.unmodifiable(_logs);
  GameEngine? get engine => _engine;
  GameResult? get lastResult => _lastResult;

  bool get isConnected => _connectionState == ConnectionState.connected;
  GamePhase get phase => _engine?.phase ?? GamePhase.idle;
  int get pot => _engine?.pot ?? 0;
  List<Player> get players => _engine?.players ?? [];

  // ── Local single-device game (for testing) ─────────────────────────────
  void startLocalGame(List<String> playerNames, {int bootAmount = 10}) {
    final players = playerNames.map((name) => Player(
      id: name.toLowerCase().replaceAll(' ', '_'),
      name: name,
      chips: 1000,
    )).toList();

    _engine = GameEngine(
      players: players,
      bootAmount: bootAmount,
    );
    _engine!.onLog = (msg) {
      _logs.add(msg);
      if (_logs.length > 50) _logs.removeAt(0);
      notifyListeners();
    };
    _engine!.onPhaseChange = (_) => notifyListeners();
    _engine!.onTurnChange = (_) => notifyListeners();
    _engine!.onRoundEnd = (result) {
      _lastResult = result;
      notifyListeners();
    };

    _engine!.startRound();
    notifyListeners();
  }

  void performAction(BetAction action) {
    _engine?.performAction(action);
  }

  void startNewRound() {
    _lastResult = null;
    _engine?.startRound();
    notifyListeners();
  }

  // ── Multiplayer via Socket.io (stub – wire up in Phase 3) ─────────────
  Future<void> connectToServer() async {
    _connectionState = ConnectionState.connecting;
    notifyListeners();
    // TODO: implement socket_io_client connection
    // final socket = io(serverUrl, OptionBuilder().setTransports(['websocket']).build());
    // socket.onConnect((_) { ... });
    await Future.delayed(const Duration(seconds: 1));
    _connectionState = ConnectionState.connected;
    notifyListeners();
  }

  void disconnect() {
    _connectionState = ConnectionState.disconnected;
    notifyListeners();
  }
}
