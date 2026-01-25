import 'package:flutter/material.dart';
import 'package:leodys/common/theme/theme_context.dart';
import '../../domain/entities/app_feature.dart';

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
    final bool shouldCenter = context.baseFontSize > 16;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isAccessible ? feature.color : Colors.grey,
          width: 1,
        ),
      ),
      color: isAccessible
          ? context.colorScheme.onSurface
          : Colors.grey.withValues(alpha: 0.2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: shouldCenter
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              _buildIcon(context),
              const SizedBox(height: 8),
              _buildTitle(context),

              !shouldCenter ? Spacer() : SizedBox(height: 12),
              _buildBadges(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isAccessible
            ? feature.color.withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        feature.icon,
        size: 40,
        color: isAccessible ? feature.color : Colors.grey,
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      feature.name,
      textAlign: TextAlign.center,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: isAccessible ? context.colorScheme.secondary : Colors.grey,
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

  Widget _buildBadge({required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Icon(icon, size: 10, color: color),
    );
  }
}