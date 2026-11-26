import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';

class AuthRepository {
  final SupabaseClient _client = Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );
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

    if (data == null) return null;
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

    await _client.from('profiles').update({
      'full_name': fullName,
      'city': city,
      'campus_or_area': campusOrArea,
      'phone_number': phoneNumber,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', user.id);
  }
}
