import 'package:flutter/material.dart';
import 'package:pildat_cms/models/user.dart';
import 'package:pildat_cms/services/api_service.dart';

enum AuthStatus { uninitialized, authenticated, unauthenticated, loading }

class AuthProvider with ChangeNotifier {
  final ApiService _apiService;
  AuthStatus _status = AuthStatus.uninitialized;
  User? _user;
  String _errorMessage = '';

  AuthStatus get status => _status;
  User? get user => _user;
  String get errorMessage => _errorMessage;

  AuthProvider(this._apiService) {
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Check if we have a cookie by making a test call
    try {
      final response = await _apiService.get('dashboard.php'); // A protected endpoint
      if (response['success'] == true) {
        // We're already logged in, but we don't have user data.
        // A real app would fetch user data from a 'me' endpoint.
        // For now, we'll just set to authenticated.
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String loginId, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await _apiService.login(loginId, password);

      if (response['success'] == true) {
        _user = User.fromJson(response['user']);
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Login failed';
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _status = AuthStatus.loading;
    notifyListeners();

    await _apiService.logout();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}