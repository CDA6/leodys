import 'package:leodys/features/cards/presentation/card_details_screen.dart';
import 'package:leodys/features/map/data/dataSources/geolocator_datasource.dart';
import 'package:leodys/features/map/data/repositories/location_repository_impl.dart';
import 'package:leodys/features/map/presentation/viewModel/map_view_model.dart';
import 'package:leodys/features/cards/presentation/display_cards_screen.dart';
import 'package:leodys/utils/internet_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'features/map/domain/useCases/watch_user_location_usecase.dart';
import 'features/map/presentation/screen/map_screen.dart';
import 'nav_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await InternetUtil.init();
  await Supabase.initialize(url: "https://ccaqaarhhdpqjxcotuxc.supabase.co", anonKey: "sb_publishable_eK9_jwNygwwJQZbp9LAjSw_ej_N--f7");
  runApp(const ProviderScope(
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // title: 'Card Scanner',
      // theme: ThemeData(
      //   colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      // ),
      // home: const DisplayCardsScreen(),
      title: 'Leodys',
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
      routes: {
        // initialRoute: LoginPage.route,
        HomePage.route: (context) => const HomePage(),
        MapScreen.route: (context) {
          final dataSource = GeolocatorDatasource();
          final repository = LocationRepositoryImpl(dataSource);
          final useCase = WatchUserLocationUseCase(repository);
          final viewModel = MapViewModel(useCase);

          return MapScreen(viewModel: viewModel);
        },
        DisplayCardsScreen.route: (context) => const DisplayCardsScreen(),
        CardDetailsScreen.route: (context) => const CardDetailsScreen()
      },
    );
  }
}




