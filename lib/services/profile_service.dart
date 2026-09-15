import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'api_service.dart';

class ProfileService {
  // GET PROFILE
  static Future<Map<String, dynamic>> getProfile() async {
    return await ApiService.get('/auth/profile');
  }

  // UPDATE PROFILE
  static Future<bool> updateProfile({
    required String name,
    required String email,
    String? phoneNumber,
  }) async {
    final token = await ApiService.getToken();

    final response = await http.patch(
      Uri.parse('${ApiConfig.baseUrl}/auth/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return true;
    }

    throw Exception(data['message'] ?? 'Gagal memperbarui profile');
  }

  // DELETE PROFILE
  static Future<bool> deleteProfile() async {
    return await ApiService.delete('/auth/profile');
  }
}
