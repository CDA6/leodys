import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:leodys/src/features/audio_reader/domain/models/reader_config.dart';
import 'package:leodys/src/features/audio_reader/domain/models/reading_progress.dart';
import 'package:leodys/src/features/audio_reader/injection.dart';
import 'package:leodys/src/features/audio_reader/presentation/controllers/reader_controller.dart';
import 'package:leodys/src/features/audio_reader/presentation/controllers/reading_progess_controller.dart';
import 'package:leodys/src/features/audio_reader/presentation/controllers/scan_and_read_text_controller.dart';
import 'package:leodys/src/features/audio_reader/presentation/widgets/audio_controls.dart';
import 'package:leodys/src/features/audio_reader/presentation/widgets/scan_button.dart';
import 'package:leodys/src/features/audio_reader/presentation/widgets/text_preview.dart';

class ReaderScreen extends StatefulWidget {
  const ReaderScreen({super.key});

  static const route = '/read';

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  late final ReaderController readerController;
  late final ScanAndReadTextController scanAndReadController;
  late final ReadingProgressController readingProgressController;

  final ReaderConfig defaultConfig = ReaderConfig.defaultConfig;
  int currentPageIndex = 0;
  int currentBlocIndex = 0;

  @override
  void initState() {
    super.initState();
    readerController = createReaderController();
    scanAndReadController = createScanAndReadController();
    readingProgressController = createReadingProgressController();

    readerController.addListener(() => setState(() {}));
    scanAndReadController.addListener(() => setState(() {}));
    readingProgressController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    readerController.dispose();
    scanAndReadController.dispose();
    readingProgressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Image.asset('assets/images/logo.jpeg', height: 32),
            const SizedBox(width: 5),
            Text('LeoDys'),
          ],
        ),

        backgroundColor: Colors.green.shade400,
      ),

      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Text('Menu'),
              decoration: BoxDecoration(color: Colors.green),
            ),
            ListTile(
              leading: Icon(Icons.scanner),
              title: Text('Scanner un document'),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/read');
              },
            ),
            //Sous menu
            ExpansionTile(
              leading: const Icon(Icons.menu_book),
              title: const Text('Lecture audio'),
              children: [
                ListTile(
                  leading: const Icon(Icons.library_books),
                  title: const Text('Document scannés'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/documents');
                  },
                ),
              ],
            ),

            ListTile(
              leading: Icon(Icons.photo_camera),
              title: Text('Reconnaissance immatriculation'),

              onTap: () {},
            ),
          ],
        ),
      ),

      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: ListView(
            children: [
              ScanButton(
                isLoading: readerController.isLoading,
                onPressed: () {
                  readerController.isLoading ? null : scanWithCamera();
                },
              ),

              const SizedBox(height: 12),

              TextPreview(text: readerController.recognizedText),

              const SizedBox(height: 12),

              AudioControls(
                onPlay: () {
                  readerController.readText(defaultConfig);
                },
                onPause: () {
                  readerController.pause();
                  readingProgressController.saveProgress(
                    ReadingProgress(
                      pageIndex: currentPageIndex,
                      blocIndex: currentBlocIndex,
                    ),
                  );
                },
                onResume: () {
                  readingProgressController.loadProgress();
                  readerController.resume(defaultConfig);
                },
                onStop: () {
                  readerController.stop();
                  readingProgressController.resetProgress();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> scanWithCamera() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (image == null) {
      return;
    }

    final imagePath = image.path;

    readerController.scanDocument(imagePath);
  }
}
