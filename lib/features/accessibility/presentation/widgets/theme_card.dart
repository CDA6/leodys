import 'package:flutter/material.dart';

class ThemeCard extends StatelessWidget {
  final String themeMode;
  final ValueChanged<String?> onUpdateThemeMode;

  const ThemeCard({
    super.key,
    required this.themeMode,
    required this.onUpdateThemeMode
  });


  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mode d\'affichage',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _ThemeOption(
              title: 'Clair',
              description: 'Fond blanc, idéal en journée',
              icon: Icons.light_mode,
              value: 'light',
              groupValue: themeMode,
              onChanged: (value) => onUpdateThemeMode(value!),
            ),
            const SizedBox(height: 12),
            _ThemeOption(
              title: 'Sombre',
              description: 'Réduit la fatigue oculaire',
              icon: Icons.dark_mode,
              value: 'dark',
              groupValue: themeMode,
              onChanged: (value) => onUpdateThemeMode(value!),
            ),
            const SizedBox(height: 12),
            _ThemeOption(
              title: 'Contraste élevé',
              description: 'Noir sur blanc pour une lisibilité maximale',
              icon: Icons.contrast,
              value: 'highContrast',
              groupValue: themeMode,
              onChanged: (value) => onUpdateThemeMode(value!),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final String value;
  final String groupValue;
  final ValueChanged<String?> onChanged;

  const _ThemeOption({
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

    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : null,
        ),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
            ),
            Icon(icon, size: 32),
            const SizedBox(width: 12),
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
                          ? Theme.of(context).colorScheme.primary
                          : null,
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
    );
  }
}