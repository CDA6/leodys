import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/ocr-reader/injection_container.dart' as ocr_reader;
import 'features/ocr-reader/presentation/screens/reader_screen.dart';
import 'features/ocr-reader/presentation/viewmodels/reader_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ocr_reader.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ocr_reader.sl<ReaderViewModel>(),
        ),
      ],
      child: MaterialApp(
        title: 'OCR Reader',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const ReaderScreen(),
        routes: {
          ReaderScreen.route: (context) => const ReaderScreen(),
        },
      ),
    );
  }
}