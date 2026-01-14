import 'package:flutter/material.dart';
import 'package:leodys/features/ocr-reader/presentation/viewmodels/handwritten_text_viewmodel.dart';
import 'package:leodys/features/ocr-reader/presentation/viewmodels/printed_text_viewmodel.dart';
import 'package:provider/provider.dart';
import 'features/ocr-reader/injection_container.dart' as ocr_reader;
import 'features/ocr-reader/presentation/screens/handwritten_text_reader_screen.dart';
import 'features/ocr-reader/presentation/screens/ocr_type_selection.dart';
import 'features/ocr-reader/presentation/screens/printed_text_reader_screen.dart';

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
          create: (_) => ocr_reader.sl<PrintedTextViewModel>(),
        ),
        ChangeNotifierProvider(
          create: (_) => ocr_reader.sl<HandwrittenTextViewModel>(),
        ),
      ],
      child: MaterialApp(
        title: 'OCR Reader',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const OcrTypeSelectionScreen(),
        routes: {
          OcrTypeSelectionScreen.route: (context) => const OcrTypeSelectionScreen(),
          PrintedTextReaderScreen.route: (_) => const PrintedTextReaderScreen(),
          HandwrittenTextReaderScreen.route: (_) => const HandwrittenTextReaderScreen(),
        },
      ),
    );
  }
}