import 'package:flutter/material.dart';
import '../models/pantry_item.dart';
import '../database/database_helper.dart';

class AddItemScreen extends StatefulWidget {
  final PantryItem? item;
  final String? defaultLocation;
  const AddItemScreen({super.key, this.item, this.defaultLocation});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _quantityController = TextEditingController();
  DateTime _expirationDate = DateTime.now().add(Duration(days: 7));
  String _location = 'pantry';
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _nameController.text = widget.item!.name;
      _typeController.text = widget.item!.type;
      _quantityController.text = widget.item!.quantity.toString();
      _expirationDate = widget.item!.expirationDate;
      _location = widget.item!.location;
    } else if (widget.defaultLocation != null) {
      _location = widget.defaultLocation!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.item == null ? 'Add Item' : 'Edit Item')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Item Name'),
                validator: (value) => value?.isEmpty ?? true ? 'Please enter a name' : null,
              ),
              TextFormField(
                controller: _typeController,
                decoration: InputDecoration(labelText: 'Type'),
                validator: (value) => value?.isEmpty ?? true ? 'Please enter a type' : null,
              ),
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                validator: (value) => value?.isEmpty ?? true ? 'Please enter quantity' : null,
              ),
              DropdownButtonFormField<String>(
                initialValue: _location,
                decoration: InputDecoration(labelText: 'Location'),
                items: ['pantry', 'fridge'].map((String value) {
                  return DropdownMenuItem<String>(value: value, child: Text(value));
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _location = newValue!;
                  });
                },
              ),
              ListTile(
                title: Text('Expiration Date'),
                subtitle: Text('${_expirationDate.toLocal()}'.split(' ')[0]),
                trailing: Icon(Icons.calendar_today),
                onTap: _selectDate,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveItem,
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expirationDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null && picked != _expirationDate) {
      setState(() {
        _expirationDate = picked;
      });
    }
  }

  void _saveItem() async {
    if (_formKey.currentState!.validate()) {
      final item = PantryItem(
        id: widget.item?.id,
        name: _nameController.text,
        type: _typeController.text,
        quantity: int.parse(_quantityController.text),
        expirationDate: _expirationDate,
        location: _location,
      );

      try {
        if (widget.item == null) {
          await _dbHelper.insertItem(item);
          // Item inserted successfully
        } else {
          await _dbHelper.updateItem(item);
          // Item updated successfully
        }
        if (mounted) Navigator.pop(context);
      } catch (e) {
        // Error saving item
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving item: $e')),
          );
        }
      }
    }
  }
}