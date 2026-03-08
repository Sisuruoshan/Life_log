import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  User? _user;
  UserModel? _userModel;
  bool _isLoading = true;

  User? get user => _user;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;

  AuthViewModel() {
    _initAuthListener();
  }

  void _initAuthListener() {
    _authRepository.authStateChanges.listen(
      (user) async {
        _user = user;
        _isLoading = true;
        if (user != null) {
          debugPrint('👤 Auth state changed: user logged in');
        } else {
          debugPrint('👤 Auth state changed: user logged out');
        }
        notifyListeners();

        try {
          if (user != null) {
            debugPrint('📁 Fetching user profile from Firestore...');
            _userModel = await _authRepository.getCurrentUser().timeout(
              const Duration(seconds: 10),
              onTimeout: () {
                debugPrint(
                  '⏱️ Firestore fetch timeout, continuing without profile',
                );
                return null;
              },
            );
            if (_userModel != null) {
              debugPrint('✅ User profile loaded: ${_userModel!.name}');
            } else {
              debugPrint('⚠️ No user profile found in Firestore');
            }
          } else {
            _userModel = null;
          }
        } catch (e) {
          debugPrint('❌ Error fetching user profile: $e');
          _userModel = null;
        }

        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        debugPrint('❌ Auth state listener error: $e');
        _user = null;
        _userModel = null;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> _loadCurrentUserAfterAuth() async {
    try {
      _user = _authRepository.getCurrentAuthUser();
      debugPrint('👤 Loaded current user: ${_user?.uid}');
      if (_user != null) {
        debugPrint('📁 Fetching user profile from Firestore...');
        _userModel = await _authRepository.getCurrentUser().timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            debugPrint(
              '⏱️ Firestore fetch timeout, continuing without profile',
            );
            return null;
          },
        );
        if (_userModel != null) {
          debugPrint('✅ User profile loaded: ${_userModel!.name}');
        } else {
          debugPrint('⚠️ No user profile found in Firestore');
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error loading user after auth: $e');
      _user = null;
      _userModel = null;
      notifyListeners();
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      debugPrint('🔓 Starting login for $email...');
      await _authRepository
          .signIn(email, password)
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              debugPrint('❌ Login timeout after 15 seconds');
              throw TimeoutException(
                'Login took too long. Please check your connection.',
              );
            },
          );
      debugPrint('✅ Login successful, loading user profile...');
      await _loadCurrentUserAfterAuth();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Login error: $e');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signUp(String name, String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      debugPrint('🔐 Starting signup for $email...');
      await _authRepository
          .signUp(name, email, password)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              debugPrint('❌ Signup timeout after 30 seconds');
              throw TimeoutException(
                'Signup took too long. Please check your connection.',
              );
            },
          );
      debugPrint('✅ Signup successful, loading user profile...');
      await _loadCurrentUserAfterAuth();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Signup error: $e');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateProfile({String? name, String? profileImageUrl}) async {
    if (_user == null || _userModel == null) return;
    
    try {
      _isLoading = true;
      notifyListeners();
      
      await _authRepository.updateUserProfile(
        _user!.uid,
        name: name,
        profileImageUrl: profileImageUrl,
      );
      
      _userModel = _userModel!.copyWith(
        name: name,
        profileImageUrl: profileImageUrl,
      );
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error updating profile: $e');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _authRepository.resetPassword(email);
  }
}
