import 'package:flutter/material.dart';
import 'package:leodys/features/notification/presentation/pages/notification_dashboard_page.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:leodys/features/ocr-reader/presentation/viewmodels/handwritten_text_viewmodel.dart';
import 'package:leodys/features/vocal_notes/presentation/viewmodels/vocal_notes_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'common/utils/internet_util.dart';
import 'constants/auth_constants.dart';
import 'features/ocr-reader/injection_container.dart' as ocr_reader;
import 'features/notification/notification_injection.dart' as messagerie;
import 'features/ocr-reader/presentation/screens/ocr_type_selection.dart';
import 'features/ocr-reader/presentation/viewmodels/printed_text_viewmodel.dart';
import 'common/services/database_service.dart';

import 'features/vocal_notes/injection_container.dart' as vocal_notes;
import 'features/vocal_notes/presentation/screens/vocal_notes_list_screen.dart';
import 'features/vocal_notes/presentation/screens/vocal_note_editor_screen.dart';

import 'features/map/data/dataSources/geolocator_datasource.dart';
import 'features/map/data/repositories/location_repository_impl.dart';
import 'features/map/presentation/viewModel/map_view_model.dart';
import 'features/map/domain/useCases/watch_user_location_usecase.dart';
import 'features/map/presentation/screen/map_screen.dart';
import 'common/pages/home_page.dart';
import 'features/authentication/domain/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await InternetUtil.init();

  await Supabase.initialize(
    url: AuthConstants.projectUrl,
    anonKey: AuthConstants.apiKey,
  );

  await ocr_reader.init();
  await messagerie.init();

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
          OcrTypeSelectionScreen.route: (context) => const OcrTypeSelectionScreen(),
        },
      ),
    );
  }
}
