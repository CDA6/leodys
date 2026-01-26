import 'package:flutter/material.dart';

Widget ConnectionWarning(String message) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.orange.shade50,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.orange.shade200),
    ),
    child: Row(
      children: [
        Icon(Icons.wifi_off, color: Colors.orange.shade700, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            message,
            style: TextStyle(
              fontSize: 13,
              color: Colors.orange.shade900,
            ),
          ),
        ),
      ],
    ),
  );
}