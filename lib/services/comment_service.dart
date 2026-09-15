import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'api_service.dart';

class CommentService {
  // GET COMMENTS
  static Future<List<dynamic>> getComments(int postId) async {
    return await ApiService.get('/comments/post/$postId');
  }

  // CREATE COMMENT
  static Future<bool> createComment(int postId, String comment) async {
    final token = await ApiService.getToken();

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/comments/post/$postId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'comment': comment}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }

    final data = jsonDecode(response.body);

    throw Exception(data['message'] ?? 'Gagal menambahkan komentar');
  }

  // DELETE COMMENT
  static Future<bool> deleteComment(int commentId) async {
    return await ApiService.delete('/comments/$commentId');
  }
}
