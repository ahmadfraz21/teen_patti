// ─────────────────────────────────────────
//  app_config.dart  –  centralised config
// ─────────────────────────────────────────
//
//  Replace the placeholder values below with
//  your real URLs after deploying the backend.

class AppConfig {
  AppConfig._();

  // ── Backend ────────────────────────────────────────────────────────────
  // Local dev:  'http://localhost:3000'
  // Production: 'https://your-app.up.railway.app'
  static const String serverUrl = String.fromEnvironment(
    'SERVER_URL',
    defaultValue: 'http://localhost:3000',
  );

  // ── Game defaults ──────────────────────────────────────────────────────
  static const int defaultBootAmount = 10;
  static const int defaultStartingChips = 1000;
  static const int maxPlayersPerRoom = 6;
  static const int minPlayersPerRoom = 2;

  // ── Feature flags ──────────────────────────────────────────────────────
  static const bool enableSideshow = true;
  static const bool enableTournamentMode = false; // coming soon
}
