import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  AppUser? _user;
  bool     _loading = false;
  String   _error   = '';

  AppUser? get user       => _user;
  bool     get loading    => _loading;
  String   get error      => _error;
  bool     get isLoggedIn => _user != null;
  bool     get isAdmin    => _user?.isAdmin ?? false;
  bool     get isApproved => _user?.isApproved ?? false;

  Future<void> checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final data  = prefs.getString('user_data');
    if (data != null) {
      try {
        _user = AppUser.fromJson(jsonDecode(data));
        notifyListeners();
      } catch (_) {}
    }
  }

  Future<bool> login({
    required String phone,
    required String password,
  }) async {
    _loading = true;
    _error   = '';
    notifyListeners();

    try {
      final data = await ApiService.login(
        phone:    phone,
        password: password,
      );

      if (data['success'] == true) {
        final userData    = Map<String, dynamic>.from(data['user']);
        userData['token'] = data['token'];
        _user             = AppUser.fromJson(userData);
        final prefs       = await SharedPreferences.getInstance();
        await prefs.setString('user_data', jsonEncode(userData));
        _loading = false;
        notifyListeners();
        return true;
      } else {
        _error   = data['error'] ?? 'Invalid phone or password';
        _loading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error   = e.toString();
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String phone,
    required String district,
    required String village,
    required String password,
  }) async {
    _loading = true;
    _error   = '';
    notifyListeners();

    try {
      final data = await ApiService.register(
        name:     name,
        phone:    phone,
        password: password,
        district: district,
        village:  village,
      );

      if (data['success'] == true) {
        _user = AppUser.fromJson(data['user']);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', jsonEncode(data['user']));
        _loading = false;
        notifyListeners();
        return true;
      } else {
        _error   = data['error'] ?? 'Registration failed';
        _loading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error   = e.toString();
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
    notifyListeners();
  }
}