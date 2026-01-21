import 'package:leodys/features/cards/presentation/card_details_screen.dart';
import 'package:leodys/features/map/data/dataSources/geolocator_datasource.dart';
import 'package:leodys/features/map/data/repositories/location_repository_impl.dart';
import 'package:leodys/features/map/presentation/viewModel/map_view_model.dart';
import 'package:leodys/features/cards/presentation/display_cards_screen.dart';
import 'package:leodys/common/utils/internet_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:leodys/features/notification/presentation/pages/notification_dashboard_page.dart';
import 'package:leodys/features/ocr-reader/presentation/viewmodels/handwritten_text_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'common/pages/home/presentation/screens/home_page.dart';
import 'common/utils/internet_util.dart';
import 'constants/auth_constants.dart';
import 'features/audio_reader/presentation/pages/document_screen.dart';
import 'features/audio_reader/presentation/pages/reader_screen.dart';
import 'features/ocr-reader/injection_container.dart' as ocr_reader;
import 'features/notification/notification_injection.dart' as messagerie;
import 'features/ocr-reader/presentation/screens/handwritten_text_reader_screen.dart';
import 'features/ocr-reader/presentation/screens/printed_text_reader_screen.dart';
import 'features/ocr-reader/presentation/viewmodels/printed_text_viewmodel.dart';
import 'common/services/database_service.dart';
import 'features/vocal_notes/injection_container.dart' as vocal_notes;

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'features/map/data/dataSources/geolocator_datasource.dart';
import 'features/map/data/repositories/location_repository_impl.dart';
import 'features/map/presentation/viewModel/map_view_model.dart';
import 'features/map/domain/useCases/watch_user_location_usecase.dart';
import 'features/map/presentation/screen/map_screen.dart';

import 'features/authentication/domain/services/auth_service.dart';
import 'features/vocal_notes/presentation/screens/vocal_note_editor_screen.dart';
import 'features/vocal_notes/presentation/screens/vocal_notes_list_screen.dart';
import 'features/vocal_notes/presentation/viewmodels/vocal_notes_viewmodel.dart';

/// Global navigator key pour accéder au context depuis les services
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR');

  await dotenv.load(fileName: ".env");

  await Hive.initFlutter();

  // 1. Initialisation des services de base
  await DatabaseService.init();
  await InternetUtil.init();

  await Supabase.initialize(
    url: AuthConstants.projectUrl,
    anonKey: AuthConstants.apiKey,
  );

  final client = Supabase.instance.client;
  await client.auth.signInWithPassword(email: 'coleenconte@icloud.com', password: '780Asq35.');

  await ocr_reader.init();
  await messagerie.init();
  await vocal_notes.init(navigatorKey);

  runApp(const ProviderScope(
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(
          create: (_) => ocr_reader.sl<PrintedTextViewModel>(),
        ),
        ChangeNotifierProvider(
          create: (_) => ocr_reader.sl<HandwrittenTextViewModel>(),
        ),
        ChangeNotifierProvider(
          create: (_) => vocal_notes.sl<VocalNotesViewModel>(),
        ),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
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
          NotificationDashboard.route: (context) =>
              const NotificationDashboard(),
          VocalNotesListScreen.route: (context) => const VocalNotesListScreen(),
          VocalNoteEditorScreen.route: (context) =>
              const VocalNoteEditorScreen(),
          ReaderScreen.route: (context) => const ReaderScreen(),
          DocumentsScreen.route: (context) => const DocumentsScreen(),
          OcrTypeSelectionScreen.route: (context) => const OcrTypeSelectionScreen(),
          DisplayCardsScreen.route: (context) => const DisplayCardsScreen()
        },
      ),
    );
  }
}
