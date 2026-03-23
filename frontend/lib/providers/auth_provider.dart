import 'package:flutter/foundation.dart';

enum AuthState { unknown, authenticated, unauthenticated }

class AuthUser {
  final String id;
  final String name;
  final String email;
  const AuthUser({required this.id, required this.name, required this.email});
}

class AuthProvider extends ChangeNotifier {
  AuthState _state = AuthState.unknown;
  AuthUser? _user;

  AuthState get state => _state;
  AuthUser? get user => _user;
  bool get isLoggedIn => _state == AuthState.authenticated;

  // ── Mock login for testing (replace with Firebase later) ──────────────
  Future<void> loginAsGuest(String name) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _user = AuthUser(
      id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: '',
    );
    _state = AuthState.authenticated;
    notifyListeners();
  }

  Future<void> logout() async {
    _user = null;
    _state = AuthState.unauthenticated;
    notifyListeners();
  }
}
