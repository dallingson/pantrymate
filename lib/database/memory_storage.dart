import '../models/pantry_item.dart';

class MemoryStorage {
  static final MemoryStorage _instance = MemoryStorage._internal();
  factory MemoryStorage() => _instance;
  MemoryStorage._internal();

  final List<PantryItem> _items = [];
  int _nextId = 1;

  Future<int> insertItem(PantryItem item) async {
    final newItem = PantryItem(
      id: _nextId++,
      name: item.name,
      type: item.type,
      quantity: item.quantity,
      expirationDate: item.expirationDate,
      location: item.location,
    );
    _items.add(newItem);
    return newItem.id!;
  }

  Future<List<PantryItem>> getAllItems() async {
    return List.from(_items);
  }

  Future<int> updateItem(PantryItem item) async {
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _items[index] = item;
      return 1;
    }
    return 0;
  }

  Future<int> deleteItem(int id) async {
    final index = _items.indexWhere((i) => i.id == id);
    if (index != -1) {
      _items.removeAt(index);
      return 1;
    }
    return 0;
  }
}