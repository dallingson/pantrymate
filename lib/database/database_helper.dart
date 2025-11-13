import '../models/pantry_item.dart';
import 'memory_storage.dart';

// For web compatibility, we'll use in-memory storage
// For mobile, you can switch back to SQLite
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  final MemoryStorage _storage = MemoryStorage();

  Future<int> insertItem(PantryItem item) async {
    return await _storage.insertItem(item);
  }

  Future<List<PantryItem>> getAllItems() async {
    return await _storage.getAllItems();
  }

  Future<int> updateItem(PantryItem item) async {
    return await _storage.updateItem(item);
  }

  Future<int> deleteItem(int id) async {
    return await _storage.deleteItem(id);
  }
}