/// App configuration supporting compilation with --dart-define
/// Example:
/// flutter run --dart-define=SUPABASE_URL=https://xyz.supabase.co --dart-define=SUPABASE_ANON_KEY=ey...
class AppConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://demo-iloop-project.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'demo-anon-key-placeholder',
  );

  static bool get isConfigured =>
      supabaseUrl != 'https://demo-iloop-project.supabase.co' &&
      supabaseAnonKey != 'demo-anon-key-placeholder';
}
