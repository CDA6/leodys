import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class ReaderScreen extends StatefulWidget {
  const ReaderScreen({super.key});
  static const route = '/ocr-reader';

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  File? _selectedImage;
  String? _extractedText;
  bool _isProcessing = false;
  TextRecognizer? _textRecognizer;

  @override
  void initState() {
    super.initState();
    // Script Latin pour le français (meilleur que le défaut)
    _textRecognizer = TextRecognizer(
      script: TextRecognitionScript.latin,
    );
  }

  @override
  void dispose() {
    _textRecognizer?.close();
    super.dispose();
  }

  // Prétraitement optimisé pour texte français
  Future<File> _preprocessImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) throw Exception('Impossible de décoder l\'image');

    img.Image processedImage = image;

    // 1. Redimensionne uniquement si trop grande (garde bonne résolution)
    if (image.width > 2048) {
      processedImage = img.copyResize(image, width: 2048);
    }

    // 2. Conversion en niveaux de gris
    processedImage = img.grayscale(processedImage);

    // 3. Augmente le contraste pour améliorer la lisibilité
    processedImage = img.adjustColor(processedImage, contrast: 1.3);

    // 4. Ajuste la luminosité si nécessaire
    processedImage = img.adjustColor(processedImage, brightness: 1.1);

    // Sauvegarde avec haute qualité
    final tempDir = await getTemporaryDirectory();
    final tempFile = File(
        '${tempDir.path}/processed_${DateTime.now().millisecondsSinceEpoch}.jpg'
    );
    await tempFile.writeAsBytes(img.encodeJpg(processedImage, quality: 95));

    return tempFile;
  }

  Future<void> _processImage(File image) async {
    setState(() => _isProcessing = true);
    try {
      // Teste AVEC prétraitement
      final processedImage = await _preprocessImage(image);
      final inputImage = InputImage.fromFile(processedImage);

      // Si les résultats ne sont pas bons, teste SANS prétraitement :
      // final inputImage = InputImage.fromFile(image);

      final recognizedText = await _textRecognizer!.processImage(inputImage);

      setState(() {
        _extractedText = recognizedText.text.isEmpty
            ? 'Aucun texte détecté. Assurez-vous que l\'image est nette et bien éclairée.'
            : recognizedText.text;
      });

      // Debug
      print('=== Résultats OCR ===');
      print('Blocs détectés : ${recognizedText.blocks.length}');
      print('Texte complet : ${recognizedText.text}');

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'OCR: ${e.toString()}')),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(
      source: source,
      imageQuality: 100, // Qualité maximale
      maxWidth: 2048,     // Résolution suffisante pour l'OCR
      preferredCameraDevice: CameraDevice.rear, // Caméra arrière par défaut
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _extractedText = null;
      });
      await _processImage(_selectedImage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lecture de texte français'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Conseils pour de meilleurs résultats
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Conseil : Prenez la photo bien droite, avec un bon éclairage',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.camera),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Prendre une photo'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery),
              icon: const Icon(Icons.image),
              label: const Text('Sélectionner une photo'),
            ),
            const SizedBox(height: 20),

            if (_selectedImage != null) ...[
              Container(
                constraints: const BoxConstraints(maxHeight: 300),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(_selectedImage!, fit: BoxFit.contain),
                ),
              ),
              const SizedBox(height: 20),

              if (_isProcessing)
                const Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 8),
                    Text('Analyse du texte en cours...'),
                  ],
                )
              else if (_extractedText != null) ...[
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Texte détecté :',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade50,
                    ),
                    child: SingleChildScrollView(
                      child: SelectableText(
                        _extractedText!,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}