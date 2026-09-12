import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'token_storage.dart';

class AuthService {
  // LOGINN
  static Future<void> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['success'] == true) {
      final token = data['token'];
      await TokenStorage.saveToken(token);
      return;
    }
    throw Exception(data['message'] ?? 'Login gagal');
  }

  // REGIS
  static Future<void> register(
    String name,
    String email,
    String password,
    String phoneNumber,
  ) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'phoneNumber': phoneNumber,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201 && data['success'] == true) {
      return;
    }
    throw Exception(data['message'] ?? 'Register gagal');
  }
}
