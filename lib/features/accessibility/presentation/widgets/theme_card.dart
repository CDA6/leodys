import 'package:flutter/material.dart';
import 'package:leodys/common/theme/theme_context.dart';

import '../../../../common/theme/app_themes.dart';

class ThemeCard extends StatelessWidget {
  final String themeMode;
  final ValueChanged<String?> onUpdateThemeMode;

  const ThemeCard({
    super.key,
    required this.themeMode,
    required this.onUpdateThemeMode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: AppThemes.availableThemes.asMap().entries.map((entry) {
        final index = entry.key;
        final themeConfig = entry.value;

        return Column(
          children: [
            if (index > 0) const SizedBox(height: 12),
            _ThemeOptionCard(
              title: themeConfig.title,
              description: themeConfig.description,
              icon: themeConfig.icon,
              value: themeConfig.key,
              groupValue: themeMode,
              onChanged: (value) => onUpdateThemeMode(value!),
            ),
          ],
        );
      }).toList(),
    );
  }
}

class _ThemeOptionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final String value;
  final String groupValue;
  final ValueChanged<String?> onChanged;

  const _ThemeOptionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? context.colorScheme.primary
              : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      color: isSelected
          ? context.colorScheme.surfaceContainerHighest.withValues(alpha: 0.1)
          : context.colorScheme.surfaceContainerHighest,
      child: InkWell(
        onTap: () => onChanged(value),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Radio<String>(
                fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                  if (states.contains(WidgetState.selected)) {
                    return context.colorScheme.primary;
                  }
                  return context.colorScheme.secondary;
                }),
                value: value,
                groupValue: groupValue,
                onChanged: onChanged,
              ),
              Icon(
                icon,
                size: 32,
                color: isSelected
                    ? context.colorScheme.primary
                    : context.colorScheme.secondary,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? context.colorScheme.primary
                            : context.colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}