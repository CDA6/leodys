import 'package:flutter/material.dart';

// Carte affichant le logo d'une station de radio ou catégorie.
class RadioLogoCard extends StatelessWidget {
  final String logoUrl;
  final String label;
  final Color borderColor;
  final VoidCallback onTap;
  final bool isCustom;

  const RadioLogoCard({
    super.key,
    required this.logoUrl,
    required this.label,
    required this.borderColor,
    required this.onTap,
    this.isCustom = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildLogo(),
            const SizedBox(height: 20),
            Text(
              label,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    if (isCustom) {
      return Icon(
        Icons.playlist_add_check_circle,
        size: 80,
        color: Colors.blueGrey.shade300,
      );
    }

    return Image.network(
      logoUrl,
      height: 80,
      fit: BoxFit.contain,
      errorBuilder: (_, e, s) => const Icon(Icons.radio, size: 80),
    );
  }
}
