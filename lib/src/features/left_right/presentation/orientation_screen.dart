import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import '../domain/entity/body_part_entity.dart';
import 'orientation_viewmodel.dart';

class OrientationScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const OrientationScreen({super.key, required this.cameras});

  @override
  State<OrientationScreen> createState() => _OrientationScreenState();
}

class _OrientationScreenState extends State<OrientationScreen> {
  late CameraController controller;
  bool isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  // Initialisation du flux caméra
  void _initializeCamera() async {
    // On utilise la caméra arrière par défaut (index 0)
    controller = CameraController(widget.cameras[0], ResolutionPreset.medium);

    await controller.initialize();

    // Lancer le flux d'images en continu
    controller.startImageStream((CameraImage image) {
      if (!mounted) return;

      // On envoie la frame au ViewModel pour analyse
      context.read<OrientationViewModel>().onFrameAvailable(
        image.planes[0].bytes,
        image.height,
        image.width,
        false, // isFrontCamera
      );
    });

    setState(() => isCameraInitialized = true);
  }

  @override
  void dispose() {
    controller.dispose(); // Très important pour libérer la caméra
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isCameraInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final vm = context.watch<OrientationViewModel>();

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Affichage du flux caméra
          CameraPreview(controller),

          // 2. Overlay de résultat (le texte qui s'affiche par-dessus)
          _buildResultOverlay(vm.result),

          // 3. Bouton Retour
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultOverlay(BodyPart? result) {
    if (result == null || result.side == Side.unknown) return const SizedBox();

    final isLeft = result.side == Side.left;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.only(bottom: 50),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        decoration: BoxDecoration(
          color: isLeft ? Colors.blue.withOpacity(0.8) : Colors.orange.withOpacity(0.8),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Text(
          isLeft ? "GAUCHE" : "DROITE",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 48,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}