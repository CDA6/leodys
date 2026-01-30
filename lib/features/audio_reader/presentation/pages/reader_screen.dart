import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../common/theme/theme_context_extension.dart';
import '../../domain/models/reader_config.dart';
import '../../injection.dart';
import '../controllers/reader_controller.dart';
import '../widgets/audio_controls.dart';
import '../widgets/scan_button.dart';
import '../widgets/text_preview.dart';

/// Classe UI qui représente l'écran qui permet de réaliser le scan du
/// document et la lecture de ce dernier
/// Elle prend en charge également l'initiation des contrôleurs, la synchronistion
/// entre la loqigue métier et l'interfaces.
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
    // Utilisation d'animatedBuilder pour écouter les notifications de changeNotifier.
    // C'est un observateur qui se recontruit quand il recoit le signal de changeNotifier
    // sans avoir recours à setState
    return AnimatedBuilder(
      // Écoute des ChangeNotifier utilisés par l’écran
      // animation défini l'objet à écouter
      // ici objet à écouter est le readerController
      animation: readerController,
      // Builder une fonction qui construit UI. cette fonction est appelé à chaque notification
      // context donne l'acces aux theme, mediaQuery et navigator et _ pour passer un parametre non utiliser
      builder: (context, _) {

        // Squelette de la page
        return Scaffold(
          appBar: AppBar(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Image.asset('assets/images/logo.jpeg', height: 32),
                const SizedBox(width: 5),
                Text(
                  'LeoDys',
                  style: TextStyle(
                    color: context.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            backgroundColor: context.colorScheme.primaryContainer,
          ),

          // Menu drawer
          drawer: Drawer(
            child: ListView(
              children: [
                // entete
                DrawerHeader(
                  // decaration pour styliser
                  decoration: BoxDecoration(
                    color: context.colorScheme.primaryContainer,
                  ),
                  child: Text(
                    'Menu',
                    style: TextStyle(
                      color: context.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Ligne cliquable
                ListTile(
                  // leading ajoute une icone au début
                  leading: const Icon(Icons.scanner),
                  title: const Text('Scanner un document'),
                  // trailing ajoute une icone à la fin
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pop(context); // Ferme le menu drawer
                    Navigator.pushNamed(context, '/read'); // naviguer vers la page read
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

          body: Center( // centrer les éléments à l'interieur
            child: Padding(
              // Ajouter de l'espace à lintérieur tout au autour de l'écran. Evite que les éléments
              // touchent le bord de l'écran
              padding: const EdgeInsets.all(20),
              child: ListView(
                children: [
                  ScanButton(
                    // transmettre l'état de chargement du controller au widget
                    isLoading: readerController.isLoading,
                    onPressed: () {
                      // action onPress: si loading == true alors le bouton est désactivé (null)
                      // si loading == false le bouton actif et appel scanWithCamera au clic
                      readerController.isLoading ? null : scanWithCamera();
                    },
                  ),

                  const SizedBox(height: 12),
                  // Processus de reconnaissance de texte à travers l'image scané
                  TextPreview(text: readerController.recognizedText),

                  const SizedBox(height: 12),

                  // Les boutons de controle de la lecture vocale
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
