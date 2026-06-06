class CartItem {
  final String name;
  final String desc;
  final String price;
  int quantity;

  CartItem({
    required this.name,
    required this.desc,
    required this.price,
    this.quantity = 1,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'desc': desc,
      'price': price,
      'quantity': quantity,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      name: json['name'],
      desc: json['desc'],
      price: json['price'],
      quantity: json['quantity'] ?? 1,
    );
  }
}
