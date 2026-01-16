import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Authentication
import 'package:leodys/constants/auth_constants.dart';
import 'package:leodys/features/authentication/domain/services/auth_service.dart';
import 'package:leodys/features/authentication/presentation/pages/auth/home_page.dart';

// Map
import 'package:leodys/features/map/data/dataSources/geolocator_datasource.dart';
import 'package:leodys/features/map/data/repositories/location_repository_impl.dart';
import 'package:leodys/features/map/presentation/viewModel/map_view_model.dart';
import 'package:leodys/features/map/presentation/screens/map_screen.dart';

// OCR
import 'package:leodys/features/ocr-reader/presentation/viewmodels/handwritten_text_viewmodel.dart';
import 'package:leodys/features/ocr-reader/presentation/viewmodels/printed_text_viewmodel.dart';
import 'package:leodys/features/ocr-reader/presentation/screens/handwritten_text_reader_screen.dart';
import 'package:leodys/features/ocr-reader/presentation/screens/ocr_type_selection.dart';
import 'package:leodys/features/ocr-reader/presentation/screens/printed_text_reader_screen.dart';
import 'features/ocr-reader/injection_container.dart' as ocr_reader;

// Utils
import 'package:leodys/utils/internet_util.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init internet listener and current status
  await InternetUtil.init();

  // Init Supabase
  await Supabase.initialize(
    url: AuthConstants.projectUrl,
    anonKey: AuthConstants.apiKey,
  );

  // Init OCR dependencies
  await ocr_reader.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Authentication
        ChangeNotifierProvider(
          create: (_) => AuthService(),
        ),
        // OCR
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
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const HomePage(),
        routes: {
          // Authentication
          HomePage.route: (context) => const HomePage(),

          // Map
          MapScreen.route: (context) {
            final dataSource = GeolocatorDatasource();
            final repository = LocationRepositoryImpl(dataSource);
            final useCase = WatchUserLocationUseCase(repository);
            final viewModel = MapViewModel(useCase);
            return MapScreen(viewModel: viewModel);
          },

          // OCR
          OcrTypeSelectionScreen.route: (context) => const OcrTypeSelectionScreen(),
          PrintedTextReaderScreen.route: (context) => const PrintedTextReaderScreen(),
          HandwrittenTextReaderScreen.route: (context) => const HandwrittenTextReaderScreen(),
        },
      ),
    );
  }
}