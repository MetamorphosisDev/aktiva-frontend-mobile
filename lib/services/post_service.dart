import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'api_service.dart';

class PostService {
  // GET ALL POSTS
  static Future<List<dynamic>> getPosts() async {
    return await ApiService.get('/posts');
  }

  // GET POST BY ID
  static Future<Map<String, dynamic>> getPostById(int id) async {
    return await ApiService.get('/posts/$id');
  }

  // CREATE POST
  static Future<bool> createPost({
    required int categoryId,
    required String slug,
    required String title,
    required String content,
    required String summary,
    required String source,
    required String location,
    required String status,
    File? image,
  }) async {
    final token = await ApiService.getToken();

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConfig.baseUrl}/posts'),
    );

    request.headers['Authorization'] = 'Bearer $token';

    request.fields['categoryId'] = categoryId.toString();
    request.fields['slug'] = slug;
    request.fields['title'] = title;
    request.fields['content'] = content;
    request.fields['summary'] = summary;
    request.fields['source'] = source;
    request.fields['location'] = location;
    request.fields['status'] = status;

    if (image != null) {
      request.files.add(
        await http.MultipartFile.fromPath('coverImage', image.path),
      );
    }

    final response = await request.send();

    final responseBody = await response.stream.bytesToString();

    print('CREATE POST STATUS: ${response.statusCode}');
    print('CREATE POST RESPONSE: $responseBody');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }

    throw Exception('Gagal membuat post (${response.statusCode})');
  }

  // UPDATE POST
  static Future<bool> updatePost({
    required int id,
    required int categoryId,
    required String slug,
    required String title,
    required String content,
    required String summary,
    required String source,
    required String location,
    required String status,
    File? image,
  }) async {
    final token = await ApiService.getToken();

    final request = http.MultipartRequest(
      'PATCH',
      Uri.parse('${ApiConfig.baseUrl}/posts/$id'),
    );

    request.headers['Authorization'] = 'Bearer $token';

    request.fields['categoryId'] = categoryId.toString();
    request.fields['slug'] = slug;
    request.fields['title'] = title;
    request.fields['content'] = content;
    request.fields['summary'] = summary;
    request.fields['source'] = source;
    request.fields['location'] = location;
    request.fields['status'] = status;

    if (image != null) {
      request.files.add(
        await http.MultipartFile.fromPath('coverImage', image.path),
      );
    }

    final response = await request.send();

    final responseBody = await response.stream.bytesToString();

    print('UPDATE POST STATUS: ${response.statusCode}');
    print('UPDATE POST RESPONSE: $responseBody');

    if (response.statusCode == 200) {
      return true;
    }

    throw Exception('Gagal mengubah post (${response.statusCode})');
  }

  // DELETE POST
  static Future<bool> deletePost(int id) async {
    return await ApiService.delete('/posts/$id');
  }
}
