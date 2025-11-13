import 'package:flutter/material.dart';

import '../models/pantry_item.dart';
import '../database/database_helper.dart';
import 'add_item_screen.dart';
import 'items_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<PantryItem> expiringItems = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadExpiringItems();
  }

  Future<void> _loadExpiringItems() async {
    final allItems = await _dbHelper.getAllItems();
    final now = DateTime.now();
    final oneWeekFromNow = now.add(Duration(days: 7));
    
    setState(() {
      expiringItems = allItems.where((item) => 
        item.expirationDate.isBefore(oneWeekFromNow) && 
        item.expirationDate.isAfter(now.subtract(Duration(days: 1)))
      ).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pantry Tracker')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _navigateToItems('fridge'),
                    icon: Icon(Icons.kitchen),
                    label: Text('Fridge'),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _navigateToItems('pantry'),
                    icon: Icon(Icons.inventory),
                    label: Text('Pantry'),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Items Expiring Soon',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          Expanded(
            child: expiringItems.isEmpty
                ? Center(child: Text('No items expiring soon!'))
                : ListView.builder(
                    itemCount: expiringItems.length,
                    itemBuilder: (context, index) {
                      final item = expiringItems[index];
                      final daysUntilExpiry = item.expirationDate.difference(DateTime.now()).inDays;
                      return Card(
                        color: daysUntilExpiry <= 2 ? Colors.red[100] : Colors.orange[100],
                        child: ListTile(
                          title: Text(item.name),
                          subtitle: Text('${item.type} • Qty: ${item.quantity} • ${item.location}'),
                          trailing: Text(
                            daysUntilExpiry == 0 ? 'Today!' : '${daysUntilExpiry}d',
                            style: TextStyle(
                              color: daysUntilExpiry <= 2 ? Colors.red : Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onTap: () => _editItem(item),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addItem(),
        child: Icon(Icons.add),
      ),
    );
  }

  void _navigateToItems(String location) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ItemsListScreen(location: location)),
    );
    _loadExpiringItems();
  }

  void _addItem() async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => AddItemScreen()));
    _loadExpiringItems();
  }

  void _editItem(PantryItem item) async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => AddItemScreen(item: item)));
    _loadExpiringItems();
  }
}