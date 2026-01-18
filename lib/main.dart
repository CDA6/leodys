import 'package:flutter/material.dart';
import 'package:leodys/features/ocr-reader/presentation/viewmodels/handwritten_text_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'common/pages/home/presentation/screens/home_page.dart';
import 'common/utils/internet_util.dart';
import 'constants/auth_constants.dart';

import 'features/ocr-reader/injection_container.dart' as ocr_reader;
import 'features/ocr-reader/presentation/screens/handwritten_text_reader_screen.dart';
import 'features/ocr-reader/presentation/screens/printed_text_reader_screen.dart';
import 'features/ocr-reader/presentation/viewmodels/printed_text_viewmodel.dart';

import 'features/map/data/dataSources/geolocator_datasource.dart';
import 'features/map/data/repositories/location_repository_impl.dart';
import 'features/map/presentation/viewModel/map_view_model.dart';
import 'features/map/domain/useCases/watch_user_location_usecase.dart';
import 'features/map/presentation/screen/map_screen.dart';

import 'features/authentication/domain/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await InternetUtil.init();

  await Supabase.initialize(
    url: AuthConstants.projectUrl,
    anonKey: AuthConstants.apiKey,
  );

  await ocr_reader.init();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthService(),
        ),
        ChangeNotifierProvider(
          create: (_) => ocr_reader.sl<PrintedTextViewModel>(),
        ),
        ChangeNotifierProvider(
          create: (_) => ocr_reader.sl<HandwrittenTextViewModel>(),
        ),
      ],
      child: MaterialApp(
        title: 'Leodys',
        debugShowCheckedModeBanner: false,
        initialRoute: HomePage.route,
        routes: {
          HomePage.route: (context) => const HomePage(),
          MapScreen.route: (context) {
            final dataSource = GeolocatorDatasource();
            final repository = LocationRepositoryImpl(dataSource);
            final useCase = WatchUserLocationUseCase(repository);
            final viewModel = MapViewModel(useCase);

            return MapScreen(viewModel: viewModel);
          },
          PrintedTextReaderScreen.route: (context) => const PrintedTextReaderScreen(),
          HandwrittenTextReaderScreen.route: (context) => const HandwrittenTextReaderScreen(),
        },
      ),
    );
  }
}
