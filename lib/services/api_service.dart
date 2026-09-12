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

  // Request GET
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

  // GET ALL POSTS
  static Future<List<dynamic>> getPosts() async {
    return await get('/posts');
  }

  // GET POST BY ID
  static Future<Map<String, dynamic>> getPostById(int id) async {
    return await get('/posts/$id');
  }

  // GET ALL BOOKMARKS
  static Future<List<dynamic>> getBookmarks() async {
    return await get('/bookmarks');
  }
}
