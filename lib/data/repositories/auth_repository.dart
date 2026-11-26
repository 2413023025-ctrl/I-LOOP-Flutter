import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';

class AuthRepository {
  final SupabaseClient _client = Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;
  Session? get currentSession => _client.auth.currentSession;
  bool get isAuthenticated => _client.auth.currentSession != null || _client.auth.currentUser != null;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required String city,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'city': city,
      },
    );

    // Pastikan record profil terisi kota tempat tinggal
    final user = response.user;
    if (user != null) {
      try {
        await _client.from('profiles').upsert({
          'id': user.id,
          'full_name': fullName,
          'city': city,
          'updated_at': DateTime.now().toIso8601String(),
        });
      } catch (_) {
        // Fallback jika ditangani oleh database trigger
      }
    }

    return response;
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response;
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<ProfileModel?> getCurrentProfile() async {
    final user = currentUser;
    if (user == null) return null;

    final data = await _client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (data == null) {
      // Jika profil belum ada di database, buat profil dasar
      final newProfile = {
        'id': user.id,
        'full_name': user.userMetadata?['full_name'] as String? ?? 'Pengguna I\'LOOP',
        'city': user.userMetadata?['city'] as String? ?? 'Jakarta',
      };
      try {
        await _client.from('profiles').insert(newProfile);
      } catch (_) {}
      return ProfileModel.fromJson(newProfile);
    }
    return ProfileModel.fromJson(data);
  }

  Future<void> updateProfile({
    required String fullName,
    required String city,
    String? campusOrArea,
    String? phoneNumber,
  }) async {
    final user = currentUser;
    if (user == null) return;

    await _client.from('profiles').upsert({
      'id': user.id,
      'full_name': fullName,
      'city': city,
      'campus_or_area': campusOrArea,
      'phone_number': phoneNumber,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}
