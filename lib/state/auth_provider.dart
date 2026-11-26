import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/profile_model.dart';
import '../data/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repo = AuthRepository();

  ProfileModel? _currentProfile;
  bool _isLoading = false;
  String? _errorMessage;

  ProfileModel? get currentProfile => _currentProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _repo.isAuthenticated;
  User? get currentUser => _repo.currentUser;

  AuthProvider() {
    _init();
  }

  void _init() {
    // Muat profil segera jika sesi persisten sudah aktif pada startup
    if (_repo.isAuthenticated) {
      loadCurrentProfile();
    }

    _repo.authStateChanges.listen((event) async {
      if (event.session != null) {
        await loadCurrentProfile();
      } else {
        _currentProfile = null;
        notifyListeners();
      }
    });
  }

  Future<void> loadCurrentProfile() async {
    _isLoading = true;
    notifyListeners();
    try {
      _currentProfile = await _repo.getCurrentProfile();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repo.signIn(email: email, password: password);
      await loadCurrentProfile();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    required String city,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repo.signUp(
        email: email,
        password: password,
        fullName: fullName,
        city: city,
      );
      await loadCurrentProfile();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _repo.signOut();
    _currentProfile = null;
    notifyListeners();
  }

  Future<bool> updateProfile({
    required String fullName,
    required String city,
    String? campusOrArea,
    String? phoneNumber,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repo.updateProfile(
        fullName: fullName,
        city: city,
        campusOrArea: campusOrArea,
        phoneNumber: phoneNumber,
      );
      await loadCurrentProfile();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
