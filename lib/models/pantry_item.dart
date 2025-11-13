class PantryItem {
  int? id;
  String name;
  String type;
  int quantity;
  DateTime expirationDate;
  String location; // 'pantry' or 'fridge'

  PantryItem({
    this.id,
    required this.name,
    required this.type,
    required this.quantity,
    required this.expirationDate,
    required this.location,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'quantity': quantity,
      'expirationDate': expirationDate.millisecondsSinceEpoch,
      'location': location,
    };
  }

  factory PantryItem.fromMap(Map<String, dynamic> map) {
    return PantryItem(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      quantity: map['quantity'],
      expirationDate: DateTime.fromMillisecondsSinceEpoch(map['expirationDate']),
      location: map['location'],
    );
  }
}