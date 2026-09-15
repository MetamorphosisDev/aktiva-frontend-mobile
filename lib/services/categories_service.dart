import 'api_service.dart';

class CategoryService {
  static Future<List<dynamic>> getCategories() async {
    return await ApiService.get('/categories');
  }
}
