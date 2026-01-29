class Receipt {
  final String shopName;
  final String date;
  final List<ReceiptItem> items;
  final double total;

  Receipt({
    required this.shopName,
    required this.date,
    required this.items,
    required this.total,
  });
}

class ReceiptItem {
  final String name;
  final double price;

  ReceiptItem({
    required this.name,
    required this.price,
  });
}
