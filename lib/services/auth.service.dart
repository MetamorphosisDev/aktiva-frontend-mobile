import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'token_storage.dart';

class AuthService {
  // Login ke backend
  static Future<void> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = jsonDecode(response.body);

    // Jika login berhasil
    if (response.statusCode == 200 && data['success'] == true) {
      final token = data['token'];

      // Simpan JWT
      await TokenStorage.saveToken(token);

      return;
    }

    // Jika login gagal
    throw Exception(data['message'] ?? 'Login gagal');
  }
}
