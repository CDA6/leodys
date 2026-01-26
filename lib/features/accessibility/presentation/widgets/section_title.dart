import 'package:flutter/material.dart';

import 'package:leodys/common/theme/theme_context_extension.dart';

class SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const SectionTitle({
    super.key,
    required this.icon,
    required this.title
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 24, color: context.colorScheme.primary ),
        const SizedBox(width: 8),
        Expanded(
            child: Text(
              title,
              style: TextStyle(
                  color: context.colorScheme.primary
              ),
            ),
        ),
      ],
    );
  }
}