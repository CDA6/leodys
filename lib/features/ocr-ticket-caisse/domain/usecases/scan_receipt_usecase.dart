import 'package:leodys/features/ocr-ticket-caisse/domain/repositories/receipt_repository.dart';
import 'package:leodys/features/ocr-ticket-caisse/domain/entities/receipt.dart';
import 'dart:io';

class ScanReceiptUseCase {
  final ReceiptRepository repository;

  ScanReceiptUseCase(this.repository);

  Future<Receipt> execute(File image) {
    return repository.scanReceipt(image);
  }
}
