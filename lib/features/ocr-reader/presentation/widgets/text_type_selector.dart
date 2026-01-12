import 'package:flutter/material.dart';
import '../../../../core/enums/text_type.dart';

class TextTypeSelector extends StatelessWidget {
  final TextType selectedType;
  final Function(TextType) onTypeChanged;

  const TextTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Type de texte à analyser :',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTextTypeButton(
                      type: TextType.printed,
                      icon: Icons.article,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextTypeButton(
                      type: TextType.handwritten,
                      icon: Icons.edit,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildInfoBanner(),
      ],
    );
  }

  Widget _buildTextTypeButton({
    required TextType type,
    required IconData icon,
  }) {
    final isSelected = selectedType == type;

    return InkWell(
      onTap: () => onTypeChanged(type),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade500 : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blue.shade700 : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? Colors.white : Colors.grey.shade700,
            ),
            const SizedBox(height: 6),
            Text(
              type.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              type.subtitle,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? Colors.white70 : Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBanner() {
    final isPrinted = selectedType == TextType.printed;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isPrinted ? Colors.green.shade50 : Colors.purple.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isPrinted ? Colors.green.shade200 : Colors.purple.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isPrinted ? Icons.offline_bolt : Icons.cloud,
            color: isPrinted ? Colors.green.shade700 : Colors.purple.shade700,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isPrinted
                  ? 'ML Kit • Hors-ligne • Texte imprimé uniquement'
                  : 'OCR.space • En ligne • Manuscrit & imprimé (25k/mois gratuit)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}