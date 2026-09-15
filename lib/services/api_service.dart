import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'token_storage.dart';

class ApiService {
  // GET JWT
  static Future<String> getToken() async {
    final token = await TokenStorage.getToken();

    if (token == null) {
      throw Exception('Token tidak ditemukan');
    }

    return token;
  }

  // GET
  static Future<dynamic> get(String endpoint) async {
    final token = await getToken();

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}$endpoint'),
      headers: {'Authorization': 'Bearer $token'},
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data['data'];
    }

    throw Exception(data['message'] ?? 'Gagal mengambil data');
  }

  // DELETE
  static Future<bool> delete(String endpoint) async {
    final token = await getToken();

    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}$endpoint'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return true;
    }

    final data = jsonDecode(response.body);

    throw Exception(data['message'] ?? 'Gagal menghapus data');
  }

  // POST
  static Future<bool> post(String endpoint) async {
    final token = await getToken();

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}$endpoint'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }

    final data = jsonDecode(response.body);

    throw Exception(data['message'] ?? 'Gagal melakukan request');
  }
}
