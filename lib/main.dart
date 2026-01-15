import 'package:Leodys/features/map/data/dataSources/geolocator_datasource.dart';
import 'package:Leodys/features/map/data/repositories/location_repository_impl.dart';
import 'package:Leodys/features/map/presentation/viewModel/map_view_model.dart';
import 'package:Leodys/utils/internet_util.dart';
import 'package:flutter/material.dart';
import 'package:leodys/constants/auth_constants.dart';
import 'package:leodys/features/authentication/presentation/pages/auth/home_page.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'features/authentication/domain/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  //Init our internet listener and current status
  await InternetUtil.init();


  await Supabase.initialize(
    url: AuthConstants.projectUrl,
    anonKey: AuthConstants.apiKey,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthService(),
      child: MaterialApp(
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
        
      ),
    );
  }
}
