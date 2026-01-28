import 'package:flutter/cupertino.dart';
import 'package:leodys/features/ocr-ticket-caisse/domain/entities/receipt.dart';

class ReceiptParser {
  Receipt parse(Map<String, dynamic> json) {
    final text = json["document"]["text"] as String? ?? "";
    debugPrint(text);
    return fromText(text);
  }

  Receipt fromText(String text) {
    final lines = text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    String shop = lines.isNotEmpty ? lines[0] : "Unknown";
    String date = "Unknown"; // No date in this receipt
    double total = 0.0;
    final items = <ReceiptItem>[];

    // Find where "Description" and "Total" appear
    final descIndex = lines.indexWhere((l) => l.toLowerCase().contains("description"));
    final totalIndex = lines.indexWhere((l) => l.toLowerCase().contains("total"));

    if (descIndex != -1 && totalIndex != -1 && totalIndex > descIndex) {
      // Skip "Description" and "Price" headers
      for (int i = descIndex + 2; i < totalIndex; i += 2) {
        final name = lines[i];
        final priceLine = lines[i + 1];
        final price = double.tryParse(priceLine.replaceAll(',', '.')) ?? 0.0;
        if (name.isNotEmpty && price > 0) items.add(ReceiptItem(name: name, price: price));
      }

      // Parse total
      final totalLine = lines[totalIndex + 1]; // The line after "Total"
      total = double.tryParse(totalLine.replaceAll(',', '.')) ?? 0.0;
    }

    final receipt = Receipt(
      shopName: shop,
      date: date,
      items: items,
      total: total,
    );

    debugPrint(receipt.toString());
    return receipt;
  }
}