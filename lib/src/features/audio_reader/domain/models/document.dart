import 'package:flutter/cupertino.dart';

class Document {
  final String idText;
  final String title;
  final String content;
  final DateTime createAt;

  Document({
    required this.idText,
    required this.title,
    required this.content,
    required this.createAt,
  });
}
