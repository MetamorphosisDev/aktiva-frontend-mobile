import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiService {
  static Future<List<dynamic>> getPosts(String token) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/posts'),
      headers: {'Authorization': 'Bearer $token'},
    );

    print('STATUS: ${response.statusCode}');
    print('BODY: ${response.body}');

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data'] ?? [];
    }

    throw Exception('Gagal mengambil posts');
  }
}
