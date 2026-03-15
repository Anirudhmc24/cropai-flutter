import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  AppUser? _user;
  bool     _loading = false;
  String   _error   = '';

  AppUser? get user      => _user;
  bool     get loading   => _loading;
  String   get error     => _error;
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

    await Future.delayed(const Duration(seconds: 1));

    // Simulate registration — in production, POST to /api/auth/register
    // For now store as pending user
    _user = AppUser(
      id:        DateTime.now().millisecondsSinceEpoch.toString(),
      name:      name,
      phone:     phone,
      district:  district,
      village:   village,
      role:      UserRole.farmer,
      status:    UserStatus.pending,
      createdAt: DateTime.now(),
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode({
      'id':         _user!.id,
      'name':       name,
      'phone':      phone,
      'district':   district,
      'village':    village,
      'role':       'farmer',
      'status':     'pending',
      'created_at': DateTime.now().toIso8601String(),
    }));

    _loading = false;
    notifyListeners();
    return true;
  }

  Future<bool> login({
    required String phone,
    required String password,
  }) async {
    _loading = true;
    _error   = '';
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    // Admin hardcoded for demo — in production verify against DB
    if (phone == '9632838185' && password == 'admin123') {
      _user = AppUser(
        id:        'admin_1',
        name:      'Admin',
        phone:     phone,
        district:  'All',
        village:   '',
        role:      UserRole.admin,
        status:    UserStatus.approved,
        createdAt: DateTime.now(),
        token:     'admin_token',
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', jsonEncode({
        'id': 'admin_1', 'name': 'Admin', 'phone': phone,
        'district': 'All', 'village': '', 'role': 'admin',
        'status': 'approved', 'created_at': DateTime.now().toIso8601String(),
        'token': 'admin_token',
      }));
      _loading = false;
      notifyListeners();
      return true;
    }

    // Check stored farmer
    final prefs = await SharedPreferences.getInstance();
    final data  = prefs.getString('user_data');
    if (data != null) {
      final json = jsonDecode(data);
      if (json['phone'] == phone) {
        _user = AppUser.fromJson(json);
        _loading = false;
        notifyListeners();
        return true;
      }
    }

    _error   = 'Invalid phone or password';
    _loading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
    notifyListeners();
  }
}