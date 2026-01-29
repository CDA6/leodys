import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/models/reader_config.dart';
import '../../injection.dart';
import '../controllers/reader_controller.dart';
import '../widgets/audio_controls.dart';
import '../widgets/scan_button.dart';
import '../widgets/text_preview.dart';

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
  ///Configuration de lecture avec des parametres par défaut
  final ReaderConfig defaultConfig = ReaderConfig.defaultConfig;

  /// Méthode de gestion de vie de l'écran
  /// Initialisation des controleurs
  @override
  void initState() {
    super.initState();
    readerController = createReaderController();
  }

  /// Nettoyage et libération des ressources
  @override
  void dispose() {
    readerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Utilisation d'animatedBuilder pour écouter les notifications. C'est un observateur
    //
    return AnimatedBuilder(
      // Écoute des ChangeNotifier utilisés par l’écran
      // ici objet à écouter est le readerController
      animation: readerController,
      // Builder une fonction qui construit UI. cette fonction est appelé à chaque notification
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Image.asset('assets/images/logo.jpeg', height: 32),
                const SizedBox(width: 5),
                const Text('LeoDys'),
              ],
            ),
            backgroundColor: Colors.green.shade400,
          ),

          drawer: Drawer(
            child: ListView(
              children: [
                const DrawerHeader(
                  decoration: BoxDecoration(color: Colors.green),
                  child: Text('Menu'),
                ),
                ListTile(
                  leading: const Icon(Icons.scanner),
                  title: const Text('Scanner un document'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/read');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.library_books),
                  title: const Text('Document scannés'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/documents');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.exit_to_app),
                  title: const Text('Accueil'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/');
                  },
                ),
              ],
            ),
          ),

          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
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
                    },
                    onStop: () {
                      readerController.stop();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
