import 'package:flutter/material.dart';
import 'package:leodys/common/theme/state_color_extension.dart';
import 'package:leodys/common/theme/theme_context_extension.dart';
import 'package:leodys/common/utils/app_logger.dart';
import 'package:leodys/features/map/domain/entities/location_search_result.dart';

class MapAppBar extends StatefulWidget implements PreferredSizeWidget {
  final Future<List<LocationSearchResult>> Function(String) onSearch;
  final Function(LocationSearchResult) onLocationSelected;
  final VoidCallback onClearSearch;

  const MapAppBar({
    super.key,
    required this.onSearch,
    required this.onLocationSelected,
    required this.onClearSearch,
  });

  @override
  State<MapAppBar> createState() => _MapAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _MapAppBarState extends State<MapAppBar> {
  // 1. On déclare le controller ici
  late final SearchController _searchController;

  @override
  void initState() {
    super.initState();
    // 2. On l'initialise
    _searchController = SearchController();
  }

  @override
  void dispose() {
    // 3. On le libère pour éviter les fuites de mémoire
    _searchController.dispose();
    super.dispose();
  }

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
          // 4. On lie le controller au widget
          searchController: _searchController,

          viewLeading: IconButton(
            icon: Icon(Icons.arrow_back, color: context.colorScheme.onSurface),
            onPressed: () {
              _searchController.clear(); // Vide le texte
              widget.onClearSearch(); // Annule l'API
              Navigator.of(context).pop();
            },
          ),

          viewTrailing: [
            IconButton(
              icon: Icon(Icons.close, color: context.colorScheme.onSurface),
              onPressed: () {
                _searchController.clear(); // Vide le texte
                widget.onClearSearch(); // Annule l'API
              },
            ),
          ],

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
            // Ici controller est le même que _searchController
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

            final results = await widget.onSearch(controller.text);

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
                  widget.onLocationSelected(res);
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
