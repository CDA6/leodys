import 'package:leodys/features/ocr-ticket-caisse/core/parser/receipt_parser.dart';

import 'package:leodys/features/ocr-ticket-caisse/domain/entities/receipt.dart';
import 'package:leodys/features/ocr-ticket-caisse/domain/repositories/receipt_repository.dart';
import 'package:leodys/features/ocr-ticket-caisse/data/datasources/receipt_remote_datasource.dart';
import 'dart:io';

class ReceiptRepositoryImpl implements ReceiptRepository {
  final ReceiptRemoteDataSource remoteDataSource;

  ReceiptRepositoryImpl(this.remoteDataSource);

  @override
  Future<Receipt> scanReceipt(File imageFile) async {
    final json = await remoteDataSource.uploadReceipt(imageFile);
    ReceiptParser parser = ReceiptParser();
    return parser.parse(json);
  }

}
