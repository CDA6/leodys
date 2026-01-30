import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:leodys/features/vehicle_recognition/presentation/controllers/plate_tts_controller.dart';
import 'package:leodys/features/vehicle_recognition/presentation/widgets/scan_plate_button.dart';
import 'package:leodys/features/vehicle_recognition/presentation/widgets/vehicle_label_preview.dart';

import '../../../../common/theme/theme_context_extension.dart';
import '../../injection/vehicle_recognition_injection.dart';
import '../controllers/scan_immatriculation_controller.dart';
import '../widgets/audio_control_button.dart';

class ScanImmatriculationScreen extends StatefulWidget {
  const ScanImmatriculationScreen({super.key});

  static const route = '/immatriculation';

  @override
  State<ScanImmatriculationScreen> createState() =>
      _ScanImmatriculationScreenState();
}

class _ScanImmatriculationScreenState extends State<ScanImmatriculationScreen> {

  late final ScanImmatriculationController controller;
  late final PlateTtsController ttsController;

  @override
  void initState() {
    super.initState();
    controller = createScanImmatriculationController();
    ttsController = createPlateTtsController();
  }

  @override
  void dispose() {
    controller.dispose();
    ttsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      // Listenable.merge combine plusieurs objets écoutable
      animation: Listenable.merge([controller, ttsController]),
      builder: (context, _) {
        return Scaffold(
            appBar: AppBar(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Image.asset('assets/images/logo.jpeg', height: 32),
                  const SizedBox(width: 5),
                  Text('LeoDys',
                    style: TextStyle(
                      color: context.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              backgroundColor: context.colorScheme.primaryContainer,
            ),
            drawer: Drawer(
              child: ListView(
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(color: context.colorScheme.primaryContainer,
                    ),
                    child: Text('Menu',
                      style: TextStyle(
                      color: context.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.photo),
                    title: const Text('Prendre une photo',),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/immatriculation');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.history),
                    title: const Text('Historique'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/historique_plaques');
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

          body: Padding(
            padding: const EdgeInsets.all(20),
            child: ListView(
              children: [
                // scan de la photo
                ScanPlateButton(
                  isLoading: controller.isLoading,
                  onPressed: _takePictureAndScan,
                ),

                const SizedBox(height: 16),

                // le retour visuel
                if (controller.isLoading)
                  const Text(
                    'Analyse en cours…',
                    textAlign: TextAlign.center,
                  ),

                // Pas de résultats
                if (!controller.isLoading &&
                controller.hasScanned &&
                controller.result == null)
                const Text(
                'Aucune plaque reconnue.\nEssayez une autre photo.',
                textAlign: TextAlign.center,
                ),

                // Résultats
                // les ... sont appelés l'opérateur de décomposition
                // si les conditions sont remplis (ici result est différent à null)
                // on déroule SizeBox, VehicleLabelPreview et AudioContolButton
                // sinon on affiche rien
                if (controller.result != null) ...[
                  const SizedBox(height: 16),
                  VehicleLabelPreview(
                    text: controller.result!.vehicleLabel,
                  ),
                  const SizedBox(height: 16),

                  // Controleur de lecture vocale
                  AudioControlButton(
                    onPlay: () =>
                        ttsController.play(controller.result!),
                    onStop: ttsController.stop,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }


  /// Ouvre la caméra pour prendre une photo
  /// La photo est enregistrée localement sur l'appareil
  Future<String> scanWithCamera() async {
    // Instancier ImagePicker
    final picker = ImagePicker();
    // XFile est un objet représentant un fichier. Il contient la taille le nom et le chemin du fichier
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    // cas d'annulation de l'utilisateur
    if (image == null) {
      return '';
    }

    // Récuperer le chemin de la photo
    return image.path;
  }

  Future<void> _takePictureAndScan() async {
    // ICI : récupération du chemin image (camera / image_picker)
    final String imagePath = await scanWithCamera();

    if (imagePath.isNotEmpty) {
      await controller.scan(imagePath);
    }
  }
}
