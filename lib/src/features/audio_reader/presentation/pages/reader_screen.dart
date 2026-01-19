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
/// Classe UI qui représente l'écran qui permet de réaliser le scan du
/// document et la lecture de ce dernier
/// Elle prend en charge également l'initiation des contrôleurs, la synchronistion
/// entre la loqigue métier et l'interface.
class ReaderScreen extends StatefulWidget {
  const ReaderScreen({super.key});

  static const route = '/read';

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}


class _ReaderScreenState extends State<ReaderScreen> {
  /// initiation des contrôleurs
  late final ReaderController readerController;
  late final ScanAndReadTextController scanAndReadController;
  late final ReadingProgressController readingProgressController;

  ///Configuration de lecture avec des parametres par défaut
  final ReaderConfig defaultConfig = ReaderConfig.defaultConfig;
  /// Index des pages et des blocs de textes
  int currentPageIndex = 0;
  int currentBlocIndex = 0;

  /// Méthode de gestion de vie de l'écran
  /// Initialisation des controleurs
  @override
  void initState() {
    super.initState();
    readerController = createReaderController();
    scanAndReadController = createScanAndReadController();
    readingProgressController = createReadingProgressController();

    /// Ecoute le changement d'état des controleurs
    /// si changement, interface reconstruit avec setState()
    readerController.addListener(_onControllerChanged);
    scanAndReadController.addListener(_onControllerChanged);
    readingProgressController.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    setState(() {});
  }

  /// Nettoyage et libération des ressources
  @override
  void dispose() {

    readerController.removeListener(_onControllerChanged);
    scanAndReadController.removeListener(_onControllerChanged);
    readingProgressController.removeListener(_onControllerChanged);

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

  /// Ouvre la caméra pour prendre une photo
  /// La photo est enregistrée localement sur l'appareil
  Future<void> scanWithCamera() async {

    // Instancier ImagePicker
    final picker = ImagePicker();
    // XFile est un objet représentant un fichier. Il contient la taille le nom et le chemin du fichier
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    // cas d'annulation de l'utilisateur
    if (image == null) {
      return;
    }

    // Récuperer le chemin de la photo
    final imagePath = image.path;
    // Appel du controller pour lancer le scan OCR avec le parametre : le chemin de l'image
    readerController.scanDocument(imagePath);
  }
}
