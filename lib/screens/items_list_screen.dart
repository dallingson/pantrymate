import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/pantry_item.dart';
import '../database/database_helper.dart';
import 'add_item_screen.dart';

class ItemsListScreen extends StatefulWidget {
  final String location;
  
  const ItemsListScreen({super.key, required this.location});

  @override
  State<ItemsListScreen> createState() => _ItemsListScreenState();
}

class _ItemsListScreenState extends State<ItemsListScreen> {
  List<PantryItem> items = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final allItems = await _dbHelper.getAllItems();
    setState(() {
      items = allItems.where((item) => item.location == widget.location).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.location.toUpperCase()} Items'),
      ),
      body: items.isEmpty
          ? Center(child: Text('No items in ${widget.location}'))
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final daysUntilExpiry = item.expirationDate.difference(DateTime.now()).inDays;
                return Card(
                  child: ListTile(
                    title: Text(item.name),
                    subtitle: Text('${item.type} • Qty: ${item.quantity} • Expires: ${DateFormat('MM/dd/yyyy').format(item.expirationDate)}'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          daysUntilExpiry <= 0 ? 'Expired' : '${daysUntilExpiry}d',
                          style: TextStyle(
                            color: daysUntilExpiry <= 2 ? Colors.red : 
                                   daysUntilExpiry <= 7 ? Colors.orange : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteItem(item),
                        ),
                      ],
                    ),
                    onTap: () => _editItem(item),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addItem(),
        child: Icon(Icons.add),
      ),
    );
  }

  void _addItem() async {
    await Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => AddItemScreen(defaultLocation: widget.location))
    );
    _loadItems();
  }

  void _editItem(PantryItem item) async {
    await Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => AddItemScreen(item: item))
    );
    _loadItems();
  }

  void _deleteItem(PantryItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Item'),
        content: Text('Are you sure you want to delete ${item.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Delete')),
        ],
      ),
    );
    
    if (confirm == true) {
      await _dbHelper.deleteItem(item.id!);
      _loadItems();
    }
  }
}