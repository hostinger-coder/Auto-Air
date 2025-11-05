// ===== lib/providers/profile_provider.dart =====

import 'package:flutter/material.dart';
import 'package:AutoAir/api/api_service.dart';
import 'package:AutoAir/features/profile/models/user_model.dart';

class ProfileProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  Future<void> fetchUser() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userData = await _apiService.authenticate();
      if (userData != null) {
        _user = userData;
      } else {
        _error = "Could not retrieve user data.";
      }
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateUserProfile(Map<String, dynamic> data) async {
    if (_user == null) {
      _error = "User not found. Cannot update profile.";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedUser = await _apiService.updateUserProfile(userId: _user!.id, data: data);
      _user = updatedUser;
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    if (_user == null) {
      _error = "User not found. Cannot change password.";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.changePassword(
        userId: _user!.id,
        currentPassword: currentPassword,
        newPassword: newPassword,
        newPasswordConfirmation: newPasswordConfirmation,
      );
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}