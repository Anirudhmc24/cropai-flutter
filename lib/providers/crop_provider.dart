import 'package:flutter/material.dart';
import '../models/recommendation.dart';
import '../services/api_service.dart';

class CropProvider extends ChangeNotifier {
  List<String>         _districts       = [];
  List<Recommendation> _recommendations = [];
  List<CalendarEntry>  _calendar        = [];
  String               _selectedDistrict = '';
  int                  _selectedMonth   = DateTime.now().month;
  bool                 _isLoading       = false;
  String               _error           = '';

  List<String>         get districts        => _districts;
  List<Recommendation> get recommendations  => _recommendations;
  List<CalendarEntry>  get calendar         => _calendar;
  String               get selectedDistrict => _selectedDistrict;
  int                  get selectedMonth    => _selectedMonth;
  bool                 get isLoading        => _isLoading;
  String               get error            => _error;

  Future<void> loadDistricts() async {
    _isLoading = true;
    _error     = '';
    notifyListeners();
    try {
      _districts = await ApiService.getDistricts();
      if (_districts.isNotEmpty) {
        _selectedDistrict = _districts[0];
      }
    } catch (e) {
      _error = 'Could not load districts. Is the server running?';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadRecommendations() async {
    if (_selectedDistrict.isEmpty) return;
    _isLoading = true;
    _error     = '';
    notifyListeners();
    try {
      _recommendations = await ApiService.getRecommendations(
        district: _selectedDistrict,
        month:    _selectedMonth,
      );
      _calendar = await ApiService.getCalendar(
        district: _selectedDistrict,
      );
    } catch (e) {
      _error = 'Could not load recommendations. Check your connection.';
    }
    _isLoading = false;
    notifyListeners();
  }

  void setDistrict(String district) {
    _selectedDistrict = district;
    notifyListeners();
    loadRecommendations();
  }

  void setMonth(int month) {
    _selectedMonth = month;
    notifyListeners();
    loadRecommendations();
  }
}