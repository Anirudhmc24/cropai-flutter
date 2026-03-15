import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recommendation.dart';

class ApiService {
  static const String baseUrl =
      'https://crop-recommendation-system-production-22e6.up.railway.app/api';

  static Future<List<String>> getDistricts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/districts'),
    ).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<String>.from(data['districts']);
    }
    throw Exception('Failed to load districts');
  }

  static Future<List<Recommendation>> getRecommendations({
    required String district,
    required int month,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/recommendations?district=$district&month=$month'),
    ).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List recs = data['recommendations'];
      return recs.map((r) => Recommendation.fromJson(r)).toList();
    }
    throw Exception('Failed to load recommendations');
  }

  static Future<List<CalendarEntry>> getCalendar({
    required String district,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/recommendations/calendar?district=$district'),
    ).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List calendar = data['calendar'];
      return calendar.map((c) => CalendarEntry.fromJson(c)).toList();
    }
    throw Exception('Failed to load calendar');
  }

  static Future<List<Map<String, dynamic>>> getPriceTrend({
    required String district,
    required String commodity,
  }) async {
    final response = await http.get(
      Uri.parse(
          '$baseUrl/prices/trend?district=$district&commodity=$commodity'),
    ).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['trend']);
    }
    throw Exception('Failed to load price trend');
  }

  static Future<Map<String, dynamic>> login({
    required String phone,
    required String password,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/auth/login');
      print('LOGIN → $uri');
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept':       'application/json',
        },
        body: jsonEncode({'phone': phone, 'password': password}),
      ).timeout(const Duration(seconds: 15));
      print('STATUS → ${response.statusCode}');
      print('BODY   → ${response.body}');
      return jsonDecode(response.body);
    } catch (e) {
      print('LOGIN ERROR → $e');
      return {'error': e.toString(), 'success': false};
    }
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String phone,
    required String password,
    required String district,
    required String village,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/auth/register');
      print('REGISTER → $uri');
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept':       'application/json',
        },
        body: jsonEncode({
          'name':     name,
          'phone':    phone,
          'password': password,
          'district': district,
          'village':  village,
        }),
      ).timeout(const Duration(seconds: 15));
      print('STATUS → ${response.statusCode}');
      print('BODY   → ${response.body}');
      return jsonDecode(response.body);
    } catch (e) {
      print('REGISTER ERROR → $e');
      return {'error': e.toString(), 'success': false};
    }
  }

  static Future<Map<String, dynamic>> getAdminRequests(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/requests'),
        headers: {
          'Content-Type':  'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> approveUser(
      String userId, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/approve/$userId'),
        headers: {
          'Content-Type':  'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> rejectUser(
      String userId, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/reject/$userId'),
        headers: {
          'Content-Type':  'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}