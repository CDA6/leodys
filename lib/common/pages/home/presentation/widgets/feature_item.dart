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

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isAccessible ? context.colorScheme.primary.withValues(alpha: 0.5) : Colors.grey.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      color: isAccessible
          ? context.colorScheme.surfaceContainerHighest
          : Colors.grey.withValues(alpha: 0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIcon(context),
              const SizedBox(height: 8),
              _buildTitle(context),
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
            ? context.colorScheme.primary.withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        feature.icon,
        size: 40,
        color: isAccessible ? context.colorScheme.primary: Colors.grey.withValues(alpha: 0.35),
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
        color: isAccessible ? context.colorScheme.secondary : Colors.grey.withValues(alpha: 0.35),
        height: 1.2,
      ),
    );
  }
}