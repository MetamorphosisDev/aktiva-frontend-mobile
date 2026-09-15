import 'api_service.dart';

class BookmarkService {
  // GET ALL BOOKMARKS
  static Future<List<dynamic>> getBookmarks() async {
    return await ApiService.get('/bookmarks');
  }

  // CREATE BOOKMARK
  static Future<bool> createBookmark(int postId) async {
    return await ApiService.post('/bookmarks/$postId');
  }

  // DELETE BOOKMARK
  static Future<bool> deleteBookmark(int postId) async {
    return await ApiService.delete('/bookmarks/$postId');
  }
}
