import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/splash/splash_screen.dart';
import 'state/auth_provider.dart';
import 'state/chat_provider.dart';
import 'state/items_provider.dart';
import 'state/proposal_provider.dart';
import 'state/upcycle_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase using --dart-define injected credentials or AppConfig fallback
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );

  // Periksa apakah sudah ada sesi persisten yang aktif pada Supabase client
  final bool hasActiveSession = Supabase.instance.client.auth.currentSession != null;
  debugPrint('Supabase initialized. Active session exists: $hasActiveSession');

  runApp(const ILoopApp());
}

class ILoopApp extends StatelessWidget {
  const ILoopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ItemsProvider()),
        ChangeNotifierProvider(create: (_) => ProposalProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => UpcycleProvider()),
      ],
      child: MaterialApp(
        title: "I'LOOP",
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('id', 'ID'),
          Locale('en', 'US'),
        ],
        locale: const Locale('id', 'ID'),
        home: const SplashScreen(),
      ),
    );
  }
}
