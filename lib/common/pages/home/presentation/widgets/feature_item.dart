import 'package:flutter/material.dart';
import '../../domain/entities/app_feature.dart';

/// Widget représentant une fonctionnalité individuelle.
class FeatureItem extends StatelessWidget {
  final AppFeature feature;
  final bool isAccessible;
  final VoidCallback onTap;

  const FeatureItem({
    super.key,
    required this.feature,
    required this.isAccessible,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isAccessible ? feature.color : Colors.grey.shade300,
          width: 1,
        ),
      ),
      color: isAccessible ? Colors.white : Colors.grey.shade100,
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icône
              _buildIcon(),
              const SizedBox(height: 8),

              // Nom de la feature
              _buildTitle(),
              const SizedBox(height: 20),

              // Badges des prérequis
              _buildBadges(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isAccessible
            ? feature.color.withValues(alpha: 0.1)
            : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        feature.icon,
        size: 40,
        color: isAccessible ? feature.color : Colors.grey.shade400,
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      feature.name,
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: isAccessible ? Colors.black87 : Colors.grey.shade500,
        height: 1.2,
      ),
    );
  }

  Widget _buildBadges() {
    final badges = <Widget>[];

    if (feature.requiresInternet) {
      badges.add(_buildBadge(
        icon: Icons.wifi,
        color: isAccessible ? Colors.blue : Colors.grey,
      ));
    }

    if (feature.requiresAuth) {
      badges.add(_buildBadge(
        icon: Icons.lock,
        color: isAccessible ? Colors.orange : Colors.grey,
      ));
    }

    if (!feature.isAvailable) {
      badges.add(_buildBadge(
        icon: Icons.construction,
        color: Colors.grey,
      ));
    }

    if (badges.isEmpty) {
      return const SizedBox(height: 16);
    }

    return Wrap(
      spacing: 3,
      runSpacing: 3,
      alignment: WrapAlignment.center,
      children: badges,
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Icon(icon, size: 10, color: color),
    );
  }
}