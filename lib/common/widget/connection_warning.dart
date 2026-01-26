import 'package:flutter/material.dart';
import 'package:leodys/common/theme/state_color_extension.dart';
import 'package:leodys/common/theme/theme_context_extension.dart';

class ConnectionWarning extends StatelessWidget {
  final String message;

  const ConnectionWarning({
    super.key,
    required this.message
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.stateColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.stateColors.warning),
      ),
      child: Row(
        children: [
          Icon(Icons.wifi_off, color: context.stateColors.warning, size: context.titleFontSize),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: context.stateColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }
}