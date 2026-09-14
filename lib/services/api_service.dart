import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
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

  // DELETE POST
  static Future<bool> deletePost(int id) async {
    final token = await getToken();

    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/posts/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return true;
    }

    throw Exception('Gagal menghapus post (${response.statusCode})');
  }

  // GET ALL BOOKMARKS
  static Future<List<dynamic>> getBookmarks() async {
    return await get('/bookmarks');
  }

  // CREATE BOOKMARK
  static Future<dynamic> createBookmark(int postId) async {
    final token = await getToken();

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/bookmarks/$postId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }

    throw Exception('Gagal menambahkan bookmark');
  }

  // DELETE BOOKMARK
  static Future<dynamic> deleteBookmark(int postId) async {
    final token = await getToken();

    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/bookmarks/$postId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return true;
    }

    throw Exception('Gagal menghapus bookmark');
  }

  // ================= COMMENTS =================
  // GET COMMENTS
  static Future<List<dynamic>> getComments(int postId) async {
    final token = await getToken();

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/comments/post/$postId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data['data'];
    }

    throw Exception(data['message'] ?? 'Gagal mengambil komentar');
  }

  // CREATE COMMENT
  static Future<bool> createComment(int postId, String comment) async {
    final token = await getToken();

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
    final token = await getToken();

    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/comments/$commentId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return true;
    }

    final data = jsonDecode(response.body);

    throw Exception(data['message'] ?? 'Gagal menghapus komentar');
  }

  static Future<List<dynamic>> getCategories() async {
    final token = await getToken();

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/categories'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return data['data'];
    }

    throw Exception('Gagal mengambil kategori (${response.statusCode})');
  }

  // ================= PROFILE =================

  // GET PROFILE
  static Future<Map<String, dynamic>> getProfile() async {
    final token = await getToken();

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/auth/profile'),
      headers: {'Authorization': 'Bearer $token'},
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data['data'];
    }

    throw Exception(data['message'] ?? 'Gagal mengambil profile');
  }

  // UPDATE PROFILE
  static Future<bool> updateProfile({
    required String name,
    required String email,
    String? phoneNumber,
  }) async {
    final token = await getToken();

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
    final token = await getToken();

    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/auth/profile'),
      headers: {'Authorization': 'Bearer $token'},
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 204) {
      return true;
    }

    throw Exception(data['message'] ?? 'Gagal menghapus akun');
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
    final token = await getToken();

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
    final token = await getToken();

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
}
