import 'package:leodys/constants/auth_constants.dart';
import 'package:leodys/features/map/data/dataSources/geolocator_datasource.dart';
import 'package:leodys/features/map/data/repositories/location_repository_impl.dart';
import 'package:leodys/features/map/presentation/viewModel/map_view_model.dart';
import 'package:leodys/features/cards/presentation/display_cards_screen.dart';
import 'package:leodys/common/utils/internet_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'features/calendar/presentation/viewModels/calendar_controller.dart';
import 'package:leodys/features/calendar/presentation/screens/calendar_screen.dart';
import 'package:leodys/features/notification/presentation/controllers/notification_controller.dart';
import 'package:leodys/features/notification/presentation/pages/notification_dashboard_page.dart';
import 'package:leodys/features/ocr-reader/presentation/viewmodels/handwritten_text_viewmodel.dart';
import 'package:leodys/features/web_audio_reader/data/datasources/web_page_datasource.dart';
import 'package:leodys/features/web_audio_reader/domain/usecases/read_webpage_usecase.dart';
import 'package:leodys/features/web_audio_reader/presentation/controllers/web_reader_controller.dart';
import 'package:leodys/features/ocr-ticket-caisse/data/datasources/receipt_remote_datasource.dart';
import 'package:leodys/features/ocr-ticket-caisse/data/repositories/receipt_repository_impl.dart';
import 'package:leodys/features/ocr-ticket-caisse/presentation/pages/receipt_page.dart';
import 'package:leodys/features/profile/presentation/screens/profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'common/pages/home/presentation/screens/home_page.dart';
import 'common/utils/app_logger.dart';
import 'common/services/database_service.dart';
import 'common/theme/app_theme_manager.dart';
import 'common/widget/global_overlay.dart';
import 'features/accessibility/presentation/viewmodels/settings_viewmodel.dart';
import 'features/audio_reader/presentation/pages/document_screen.dart';
import 'features/audio_reader/presentation/pages/reader_screen.dart';
import 'features/confidential_document/presentation/confidential_document_screen.dart';
import 'features/forum/presentation/screens/forum_screen.dart';
import 'features/gamecards-reader/presentation/screens/gamecard_reader_screen.dart';
import 'features/gamecards-reader/presentation/viewmodels/gamecard_reader_viewmodel.dart';
import 'features/ocr-reader/injection_container.dart' as ocr_reader;
import 'features/left_right/presentation/real_time_yolo_screen.dart';
import 'package:leodys/features/ocr-ticket-caisse/domain/usecases/scan_receipt_usecase.dart';
import 'package:leodys/features/ocr-ticket-caisse/presentation/controllers/receipt_controller.dart';
import 'features/vehicle_recognition/presentation/pages/historicals_scan.dart';
import 'features/vehicle_recognition/presentation/pages/scan_immatriculation_screen.dart';
import 'features/voice-clock/presentation/screen/voice_clock_screen.dart';
import 'features/voice-clock/presentation/viewmodel/voice_clock_viewmodel.dart';
import 'features/voice-clock/voice_clock_injection.dart' as voice_clock;
import 'features/notification/notification_injection.dart' as messagerie;
import 'features/cards/providers.dart' as cards;
import 'features/ocr-reader/presentation/screens/handwritten_text_reader_screen.dart';
import 'features/calculator/presentation/views/calculator_view.dart';
import 'features/ocr-reader/presentation/screens/printed_text_reader_screen.dart';
import 'features/ocr-reader/presentation/viewmodels/printed_text_viewmodel.dart';
import 'features/vehicle_recognition/injection/vehicle_recognition_injection.dart';
import 'features/vocal_notes/injection_container.dart' as vocal_notes;
import 'features/calendar/calendar_injection.dart' as calendar_injection;

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'features/map/data/dataSources/geolocator_datasource.dart';
import 'features/map/data/repositories/location_repository_impl.dart';
import 'features/map/presentation/viewModel/map_view_model.dart';
import 'features/vocal_chat/injection_container.dart' as vocal_chat;
import 'features/text_simplification/injection_container.dart' as text_simplification;
import 'features/accessibility/accessibility_injection.dart' as accessibility;
import 'features/accessibility/presentation/screens/settings_screen.dart';
import 'features/map/domain/useCases/watch_user_location_usecase.dart';
import 'features/map/presentation/screen/map_screen.dart';
import 'features/left_right/injection_container.dart' as pose_detection;
import 'features/authentication/domain/services/auth_service.dart';
import 'features/vocal_notes/presentation/screens/vocal_note_editor_screen.dart';
import 'features/vocal_notes/presentation/screens/vocal_notes_list_screen.dart';
import 'features/vocal_notes/presentation/viewmodels/vocal_notes_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'features/money_manager/domain/models/payment_transaction.dart';
import 'features/money_manager/presentation/views/money_manager_view.dart';
import 'features/money_manager/presentation/views/payment_history_view.dart';
import 'features/vocal_chat/presentation/screens/vocal_chat_screen.dart';
import 'features/vocal_chat/presentation/viewmodels/vocal_chat_viewmodel.dart';
import 'features/text_simplification/presentation/screens/text_simplification_screen.dart';
import 'features/text_simplification/presentation/viewmodels/text_simplification_viewmodel.dart';
import 'features/gamecards-reader/injection_container.dart' as gamecard_reader;
import 'features/web_audio_reader/data/repositories/tts_repository_impl.dart';
import 'features/web_audio_reader/data/repositories/web_reader_repository_impl.dart';
import 'features/web_audio_reader/data/services/tts_service.dart';
import 'features/web_audio_reader/domain/usecases/read_text_usecase.dart';
import 'features/web_audio_reader/presentation/pages/web_reader_screen.dart';
import 'features/profile/providers.dart' as profile;

/// Global navigator key pour accéder au context depuis les services
/// Global navigator key pour accéder au context depuis les datasource
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR');

  await dotenv.load(fileName: ".env");

  // Initialisation des datasource de base
  await InternetUtil.init();
  await DatabaseService.init();

  await Supabase.initialize(
    url: AuthConstants.projectUrl,
    anonKey: AuthConstants.apiKey,
  );

  //ThemeManager
  final themeManager = AppThemeManager();

  //Features
  await accessibility.init(themeManager);
  await ocr_reader.init();
  await messagerie.init();
  await vocal_notes.init(navigatorKey);
  await calendar_injection.init();
  await vocal_chat.init();
  await text_simplification.init();
  await cards.init();
  await pose_detection.init();
  await voice_clock.init();
  await gamecard_reader.init();
  await profile.init();

  initVehicleRecognition();
  runApp(riverpod.ProviderScope(child: MyApp(themeManager: themeManager)));
}

class MyApp extends StatelessWidget {
  final AppThemeManager themeManager;

  const MyApp({super.key, required this.themeManager});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeManager),
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
        ChangeNotifierProvider(
          create: (_) => calendar_injection.sl<CalendarController>(),
        ),

        ChangeNotifierProvider(
          create: (_) {
            if (SettingsViewModel.isAvailable) {
              final viewModel = accessibility.sl<SettingsViewModel>();
              Future.microtask(() => viewModel.init());
              return viewModel;
            } else {
              throw Exception("SettingsViewModel non disponible");
            }
          },
        ),

        ChangeNotifierProvider(
          create: (_) => gamecard_reader.sl<GamecardReaderViewModel>(),
        ),
      ],
      child: Consumer<AppThemeManager>(
        builder: (context, themeManager, _) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            title: 'Leodys',
            debugShowCheckedModeBanner: false,
            theme: themeManager.currentTheme,
            initialRoute: HomePage.route,
            builder: (context, child) {
              return GlobalOverlay(child: child ?? const SizedBox());
            },
            routes: {
              HomePage.route: (context) => const HomePage(),

              SettingsScreen.route: (context) => const SettingsScreen(),

              MapScreen.route: (context) {
                final dataSource = GeolocatorDatasource();
                final repository = LocationRepositoryImpl(dataSource);
                final useCase = WatchUserLocationUseCase(repository);
                final viewModel = MapViewModel(useCase);

                return MapScreen(viewModel: viewModel);
              },

              RealTimeYoloScreen.route: (context) => const RealTimeYoloScreen(),

              PrintedTextReaderScreen.route: (context) =>
                  const PrintedTextReaderScreen(),

              HandwrittenTextReaderScreen.route: (context) =>
                  const HandwrittenTextReaderScreen(),

              NotificationDashboard.route: (context) => ChangeNotifierProvider(
                create: (_) => messagerie.sl<NotificationController>(),
                child: const NotificationDashboard(),
              ),

              VocalNotesListScreen.route: (context) =>
                  const VocalNotesListScreen(),

              VocalNoteEditorScreen.route: (context) =>
                  const VocalNoteEditorScreen(),

              VocalChatScreen.route: (context) => ChangeNotifierProvider(
                create: (_) => vocal_chat.sl<VocalChatViewModel>(),
                child: const VocalChatScreen(),
              ),

              TextSimplificationScreen.route: (context) => ChangeNotifierProvider(
                create: (_) => text_simplification.sl<TextSimplificationViewModel>(),
                child: const TextSimplificationScreen(),
              ),

              VoiceClockScreen.route: (context) => ChangeNotifierProvider(
                create: (_) => voice_clock.sl<VoiceClockViewModel>(),
                child: const VoiceClockScreen(),
              ),
              // NOTE MERCI DE NE
              MoneyManagerView.route: (context) => const MoneyManagerView(),
              PaymentHistoryView.route: (context) => const PaymentHistoryView(),
              CalculatorView.route: (context) => const CalculatorView(),
              // PAS EFFACER DE NOUVEAU
              ReaderScreen.route: (context) => const ReaderScreen(),
              DocumentsScreen.route: (context) => const DocumentsScreen(),
              DisplayCardsScreen.route: (context) => const DisplayCardsScreen(),
              GamecardReaderScreen.route: (context) =>
                  const GamecardReaderScreen(),
              ScanImmatriculationScreen.route: (context) =>
                  const ScanImmatriculationScreen(),
              HistoricalsScan.route: (context) => const HistoricalsScan(),
              ReceiptPage.route: (context) {
                const String endpoint =
                    "https://eu-documentai.googleapis.com/v1/projects/663203358287/locations/eu/processors/b0a1bf5c3d83919e:process";
                final remoteDataSource = ReceiptRemoteDataSource(endpoint);
                final repository = ReceiptRepositoryImpl(remoteDataSource);
                final scanReceiptUseCase = ScanReceiptUseCase(repository);
                return ChangeNotifierProvider(
                  create: (_) => ReceiptController(scanReceiptUseCase),
                  child: const ReceiptPage(),
                );
              },

              WebReaderScreen.route: (context) {
                final webDataSource = WebPageDataSource();
                final webRepo = WebReaderRepositoryImpl(webDataSource);

                final ttsService = TtsService();
                final ttsRepo = TtsRepositoryImpl(ttsService);

                final readWebUseCase = ReadWebPageUseCase(webRepo);
                final readTextUseCase = ReadTextUseCase(ttsRepo);

                final controller = WebReaderController(
                  readWebPageUseCase: readWebUseCase,
                  readTextUseCase: readTextUseCase,
                );
                return WebReaderScreen(controller: controller);
              },

              ForumScreen.route: (context) => const ForumScreen(),

              ConfidentialDocumentScreen.route: (context) =>
                  const ConfidentialDocumentScreen(),
              ProfileScreen.route: (context) => const ProfileScreen(),
              CalendarScreen.route: (context) => const CalendarScreen(),
            },
          );
        },
      ),
    );
  }
}
