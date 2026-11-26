import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../state/auth_provider.dart';
import '../auth/login_screen.dart';
import '../main_nav.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    // Delay estetis untuk menampilkan logo I'LOOP
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;

    // Cek apakah Supabase memiliki sesi tersimpan yang persisten
    final session = Supabase.instance.client.auth.currentSession;
    final auth = context.read<AuthProvider>();

    if (session != null || auth.isAuthenticated) {
      // Auto-Login: pengguna sudah login sebelumnya, langsung arahkan ke beranda utama
      try {
        await auth.loadCurrentProfile();
      } catch (e) {
        debugPrint('Auto-login: Gagal memuat profil: $e');
      }
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavScreen()),
      );
    } else {
      // Pengguna belum login atau sudah logout
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.recycling, size: 72, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            const Text(
              "I'LOOP",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Circular Economy & Reuse Marketplace',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.5),
          ],
        ),
      ),
    );
  }
}
