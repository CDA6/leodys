import 'dart:io';
import 'package:flutter/material.dart';
import 'package:leodys/features/ocr-ticket-caisse/domain/entities/receipt.dart';
import 'package:leodys/features/ocr-ticket-caisse/domain/usecases/scan_receipt_usecase.dart';

class ReceiptController extends ChangeNotifier {
  final ScanReceiptUseCase useCase;

  Receipt? receipt;
  bool isLoading = false;
  String? error;

  ReceiptController(this.useCase);

  Future<void> scan(File image) async {
    try {
      isLoading = true;
      notifyListeners();

      receipt = await useCase.execute(image);
      error = null;
    } catch (e) {
      error = e.toString();
      debugPrint(e.toString());
    }

    isLoading = false;
    notifyListeners();
  }
}
