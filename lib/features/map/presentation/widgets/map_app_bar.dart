import 'package:flutter/material.dart';
import 'package:leodys/common/theme/state_color_extension.dart';
import 'package:leodys/common/theme/theme_context_extension.dart';
import 'package:leodys/common/utils/app_logger.dart';
import 'package:leodys/features/map/domain/entities/location_search_result.dart';

class MapAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Future<List<LocationSearchResult>> Function(String) onSearch;
  final Function(LocationSearchResult) onLocationSelected;

  const MapAppBar({
    super.key,
    required this.onSearch,
    required this.onLocationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final suggestionTextStyle = TextStyle(
      color: context.colorScheme.onSurface,
      fontWeight: FontWeight.w500,
      fontSize: context.baseFontSize,
    );

    return AppBar(
      backgroundColor: context.colorScheme.primaryContainer,
      iconTheme: IconThemeData(color: context.colorScheme.onPrimaryContainer),
      title: Text(
        "Navigation Piéton",
        style: TextStyle(color: context.colorScheme.onPrimaryContainer),
      ),
      actions: [
        SearchAnchor(
          viewLeading: IconButton(
            icon: Icon(Icons.arrow_back, color: context.colorScheme.onSurface),
            onPressed: () {
              Navigator.of(context).pop();
              AppLogger().debug("Closing navigation search bar");
            },
          ),

          viewBackgroundColor: context.colorScheme.surfaceContainerHighest,
          viewSurfaceTintColor: Colors.transparent,
          viewHintText: "Chercher une adresse...",

          builder: (context, controller) {
            return IconButton(
              icon: Icon(
                Icons.search,
                color: context.colorScheme.onPrimaryContainer,
              ),
              onPressed: () {
                AppLogger().info("Opening search location");
                controller.openView();
              },
            );
          },

          suggestionsBuilder: (context, controller) async {
            if (controller.text.length < 3) {
              return [
                ListTile(
                  title: Text(
                    "Trois caractères minimum",
                    style: suggestionTextStyle,
                  ),
                  leading: Icon(
                    Icons.info_outline,
                    color: context.colorScheme.onSurface,
                  ),
                ),
              ];
            }

            final results = await onSearch(controller.text);

            if (results.isEmpty) {
              return [
                ListTile(
                  title: Text(
                    "Aucun résultat trouvé",
                    style: suggestionTextStyle,
                  ),
                  leading: Icon(
                    Icons.search_off,
                    color: context.stateColors.warning,
                  ),
                ),
              ];
            }

            return results.map(
              (res) => ListTile(
                leading: Icon(
                  Icons.location_on,
                  color: context.colorScheme.primary,
                ),
                title: Text(res.name, style: suggestionTextStyle),
                onTap: () {
                  AppLogger().info("Choix destination : ${res.name}");
                  controller.closeView(res.name);
                  onLocationSelected(res);
                },
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
