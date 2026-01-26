import 'package:leodys/features/map/data/dataSources/geolocator_datasource.dart';
import 'package:leodys/features/map/data/repositories/location_repository_impl.dart';
import 'package:leodys/features/map/presentation/viewModel/map_view_model.dart';
import 'package:leodys/features/cards/presentation/display_cards_screen.dart';
import 'package:leodys/common/utils/internet_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:leodys/features/notification/presentation/controllers/notification_controller.dart';
import 'package:leodys/features/notification/presentation/pages/notification_dashboard_page.dart';
import 'package:leodys/features/ocr-reader/presentation/viewmodels/handwritten_text_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'common/pages/home/presentation/screens/home_page.dart';
import 'constants/auth_constants.dart';
import 'features/audio_reader/presentation/pages/document_screen.dart';
import 'features/audio_reader/presentation/pages/reader_screen.dart';
import 'features/ocr-reader/injection_container.dart' as ocr_reader;
import 'features/voice-clock/presentation/screen/voice_clock_screen.dart';
import 'features/voice-clock/presentation/viewmodel/voice_clock_viewmodel.dart';
import 'features/voice-clock/voice_clock_injection.dart' as voice_clock;
import 'features/notification/notification_injection.dart' as messagerie;
import 'features/cards/providers.dart' as cards;
import 'features/ocr-reader/presentation/screens/handwritten_text_reader_screen.dart';
import 'features/ocr-reader/presentation/screens/printed_text_reader_screen.dart';
import 'features/ocr-reader/presentation/viewmodels/printed_text_viewmodel.dart';
import 'common/services/database_service.dart';
import 'features/vocal_notes/injection_container.dart' as vocal_notes;

import 'package:hive_flutter/hive_flutter.dart';

import 'features/map/domain/useCases/watch_user_location_usecase.dart';
import 'features/map/presentation/screen/map_screen.dart';

import 'features/authentication/domain/services/auth_service.dart';
import 'features/vocal_notes/presentation/screens/vocal_note_editor_screen.dart';
import 'features/vocal_notes/presentation/screens/vocal_notes_list_screen.dart';
import 'features/vocal_notes/presentation/viewmodels/vocal_notes_viewmodel.dart';

import 'features/calculator/calculator.dart';

/// Global navigator key pour accéder au context depuis les services
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR');

  await dotenv.load(fileName: ".env");

  // 1. Initialisation des services de base
  await DatabaseService.init();
  await InternetUtil.init();

  // double initialisation de supabase ? garder dans le main ou dans DatabaseService mais aps les 2
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // TEMPORAIRE POUR BYPASS L'AUTHENTIFICATION
  final client = Supabase.instance.client;
  await client.auth.signInWithPassword(
    email: 'coleen@test.com',
    password: 'leodys123',
  );

  await ocr_reader.init();
  await messagerie.init();
  await vocal_notes.init(navigatorKey);
  await cards.init();
  await voice_clock.init();

  runApp(MyApp());
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
          PrintedTextReaderScreen.route: (context) =>
              const PrintedTextReaderScreen(),
          HandwrittenTextReaderScreen.route: (context) =>
              const HandwrittenTextReaderScreen(),

          NotificationDashboard.route: (context) => ChangeNotifierProvider(
            create: (_) => messagerie.sl<NotificationController>(),
            child: const NotificationDashboard(),
          ),

          VocalNotesListScreen.route: (context) => const VocalNotesListScreen(),
          VocalNoteEditorScreen.route: (context) =>
              const VocalNoteEditorScreen(),

          VoiceClockScreen.route: (context) => ChangeNotifierProvider(
            create: (_) => voice_clock.sl<VoiceClockViewModel>(),
            // GetIt fournit l'instance propre
            child: const VoiceClockScreen(),
          ),

          ReaderScreen.route: (context) => const ReaderScreen(),
          DocumentsScreen.route: (context) => const DocumentsScreen(),
          // OcrTypeSelectionScreen.route: (context) => const OcrTypeSelectionScreen(),
          DisplayCardsScreen.route: (context) => const DisplayCardsScreen(),
          CalculatorView.route: (context) => const CalculatorView(),
        },
      ),
    );
  }
}