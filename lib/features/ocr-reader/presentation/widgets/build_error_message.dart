import 'package:flutter/material.dart';

Widget BuildErrorMessage(String message) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.red.shade50,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.red.shade300),
    ),
    child: Row(
      children: [
        Icon(Icons.error_outline, color: Colors.red.shade700),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            style: TextStyle(
              color: Colors.red.shade700,
              fontSize: 13,
            ),
          ),
        ),
      ],
    ),
  );
}