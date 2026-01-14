import 'package:Leodys/features/map/data/dataSources/geolocator_datasource.dart';
import 'package:Leodys/features/map/data/repositories/location_repository_impl.dart';
import 'package:Leodys/features/map/presentation/viewModel/map_view_model.dart';
import 'package:Leodys/utils/internet_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leodys/src/features/cards/presentation/display_cards_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'features/map/domain/useCases/watch_user_location_usecase.dart';
import 'features/map/presentation/screen/map_screen.dart';
import 'nav_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //Init our internet listener and current status
  await InternetUtil.init();

  // Initialisation de Supabase avec l'URL du projet et la clé anonyme
  await Supabase.initialize(
    url: 'https://vkhlvzfvmzqcmrkxxaaf.supabase.co', // ⚠️ Remplacez par votre URL
    anonKey: 'sb_publishable_mRFGHPKaqF6sAoLeWKHmYw_R-xMnVCX', // ⚠️ Remplacez par votre API Key
  );

  runApp(const MyApp());
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      title: 'Card Scanner',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const DisplayCardsScreen(),
    );
  }
}

      title: 'Leodys',
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
      routes: {
        HomePage.route: (context) => const HomePage(),
        MapScreen.route: (context) {
          final dataSource = GeolocatorDatasource();
          final repository = LocationRepositoryImpl(dataSource);
          final useCase = WatchUserLocationUseCase(repository);
          final viewModel = MapViewModel(useCase);

          return MapScreen(viewModel: viewModel);
        },
      },
      //initialRoute: LoginPage.route,
    );
  }
}
