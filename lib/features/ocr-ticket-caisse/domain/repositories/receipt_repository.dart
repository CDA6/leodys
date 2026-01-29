import 'package:leodys/features/ocr-ticket-caisse/domain/entities/receipt.dart';
import 'dart:io';

abstract class ReceiptRepository {
  Future<Receipt> scanReceipt(File imageFile);
}
