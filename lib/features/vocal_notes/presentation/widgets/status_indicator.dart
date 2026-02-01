import 'package:flutter/material.dart';
import 'package:leodys/common/theme/theme_context_extension.dart';

class StatusIndicator extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color activeColor;
  final Color? inactiveColor;

  const StatusIndicator({
    super.key,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveInactiveColor = inactiveColor ?? context.colorScheme.outline;

    return Column(
      children: [
        Icon(icon, size: 32, color: isActive ? activeColor : effectiveInactiveColor),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: isActive ? activeColor : effectiveInactiveColor,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
