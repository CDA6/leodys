import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:leodys/src/features/audio_reader/injection.dart';
import 'package:leodys/src/features/audio_reader/presentation/controllers/document_controller.dart';
import 'package:leodys/src/features/audio_reader/presentation/controllers/reader_controller.dart';
import 'package:leodys/src/features/audio_reader/presentation/pages/document_screen.dart';
import 'package:leodys/src/features/audio_reader/presentation/pages/reader_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  final readerController = createReaderController();
  final documentController = createDocumentController();
  runApp(MyApp( readerController: readerController,
    documentController: documentController,));

}

class MyApp extends StatelessWidget {
  final DocumentController documentController;
  final ReaderController readerController;
  const MyApp({super.key, required this.documentController, required this.readerController});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const ReaderScreen(),
        debugShowCheckedModeBanner: false,
      initialRoute: ReaderScreen.route,
      routes: {
        ReaderScreen.route: (context) => const ReaderScreen(),
        DocumentsScreen.route: (context) => DocumentsScreen(documentController: documentController, readerController: readerController,),
      }
    );
  }
}
