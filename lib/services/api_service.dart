import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'token_storage.dart';

class ApiService {
  // ================= GET JWT =================

  static Future<String> getToken() async {
    final token = await TokenStorage.getToken();

    if (token == null) {
      throw Exception('Token tidak ditemukan');
    }

    return token;
  }

  // ================= REQUEST GET =================

  static Future<dynamic> get(String endpoint) async {
    final token = await getToken();

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}$endpoint'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'];
    }

    throw Exception('Gagal mengambil data (${response.statusCode})');
  }

  // ================= POSTS =================

  // GET ALL POSTS
  static Future<List<dynamic>> getPosts() async {
    return await get('/posts');
  }

  // GET POST BY ID
  static Future<Map<String, dynamic>> getPostById(int id) async {
    return await get('/posts/$id');
  }

  // ================= BOOKMARKS =================

  // GET ALL BOOKMARKS
  static Future<List<dynamic>> getBookmarks() async {
    return await get('/bookmarks');
  }

  // CREATE BOOKMARK
  static Future<bool> createBookmark(int postId) async {
    final token = await getToken();

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/bookmarks/$postId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }

    throw Exception('Gagal menambahkan bookmark (${response.statusCode})');
  }

  // DELETE BOOKMARK
  static Future<bool> deleteBookmark(int postId) async {
    final token = await getToken();

    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/bookmarks/$postId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return true;
    }

    throw Exception('Gagal menghapus bookmark (${response.statusCode})');
  }

  // ================= COMMENTS =================

  // GET COMMENTS
  static Future<List<dynamic>> getComments(int postId) async {
    final token = await getToken();

    final url = Uri.parse('${ApiConfig.baseUrl}/comment/post/$postId');

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    print('GET COMMENTS');
    print('URL: $url');
    print('STATUS: ${response.statusCode}');
    print('BODY: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil komentar (${response.statusCode})');
    }

    final data = jsonDecode(response.body);

    return data['data'] ?? [];
  }

  // CREATE COMMENT
  static Future<bool> createComment(int postId, String comment) async {
    final token = await getToken();

    final url = Uri.parse('${ApiConfig.baseUrl}/comment/post/$postId');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'comment': comment}),
    );

    print('CREATE COMMENT');
    print('URL: $url');
    print('STATUS: ${response.statusCode}');
    print('BODY: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }

    throw Exception('Gagal menambahkan komentar (${response.statusCode})');
  }

  // DELETE COMMENT
  static Future<bool> deleteComment(int commentId) async {
    final token = await getToken();

    final url = Uri.parse('${ApiConfig.baseUrl}/comment/$commentId');

    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    print('DELETE COMMENT');
    print('URL: $url');
    print('STATUS: ${response.statusCode}');
    print('BODY: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 204) {
      return true;
    }

    throw Exception('Gagal menghapus komentar (${response.statusCode})');
  }
}
