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
}