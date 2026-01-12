import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';

enum TextType { printed, handwritten }

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
  TextType _selectedTextType = TextType.printed;
  TextRecognizer? _textRecognizer;

  static const String ocrSpaceApiKey = 'K88946411988957';

  @override
  void initState() {
    super.initState();
    _textRecognizer = TextRecognizer(
      script: TextRecognitionScript.latin,
    );
  }

  @override
  void dispose() {
    _textRecognizer?.close();
    super.dispose();
  }

  // Vérifie la connexion Internet
  Future<bool> _hasInternetConnection() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return false;
      }

      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // Prétraitement optimisé pour texte français (ML Kit)
  Future<File> _preprocessImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) throw Exception('Impossible de décoder l\'image');

    img.Image processedImage = image;

    if (image.width > 2048) {
      processedImage = img.copyResize(image, width: 2048);
    }

    processedImage = img.grayscale(processedImage);
    processedImage = img.adjustColor(processedImage, contrast: 1.3);
    processedImage = img.adjustColor(processedImage, brightness: 1.1);

    final tempDir = await getTemporaryDirectory();
    final tempFile = File(
        '${tempDir.path}/processed_${DateTime.now().millisecondsSinceEpoch}.jpg'
    );
    await tempFile.writeAsBytes(img.encodeJpg(processedImage, quality: 95));

    return tempFile;
  }

  // Compression d'image pour OCR.space (limite 1 MB)
  Future<File> _compressImageForOCRSpace(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    var image = img.decodeImage(bytes);

    if (image == null) throw Exception('Impossible de décoder l\'image');

    // Redimensionnement si nécessaire
    if (image.width > 1920) {
      image = img.copyResize(image, width: 1920);
    }

    final tempDir = await getTemporaryDirectory();
    final tempFile = File(
        '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg'
    );

    // Compression progressive jusqu'à < 1 MB
    int quality = 85;
    List<int> compressedBytes;

    do {
      compressedBytes = img.encodeJpg(image, quality: quality);
      if (compressedBytes.length > 1024 * 1024 && quality > 30) {
        quality -= 10;
      } else {
        break;
      }
    } while (quality > 30);

    await tempFile.writeAsBytes(compressedBytes);

    final fileSizeKB = compressedBytes.length / 1024;
    print('📦 Image compressée: ${fileSizeKB.toStringAsFixed(1)} KB (qualité: $quality)');

    return tempFile;
  }

  // OCR avec ML Kit (hors-ligne, texte imprimé)
  Future<String> _recognizeWithMLKit(File imageFile) async {
    try {
      final processedImage = await _preprocessImage(imageFile);
      final inputImage = InputImage.fromFile(processedImage);

      final recognizedText = await _textRecognizer!.processImage(inputImage);

      print('=== ML Kit - Résultats ===');
      print('Blocs détectés : ${recognizedText.blocks.length}');
      print('Texte : ${recognizedText.text}');

      return recognizedText.text.isEmpty
          ? 'Aucun texte détecté. Assurez-vous que l\'image est nette et bien éclairée.'
          : recognizedText.text;
    } catch (e) {
      throw Exception('Erreur ML Kit: $e');
    }
  }

  // OCR avec OCR.space (en ligne, manuscrit - GRATUIT 25k/mois)
  Future<String> _recognizeWithOCRSpace(File imageFile) async {
    try {
      // Compression de l'image pour respecter la limite de 1 MB
      final compressedImage = await _compressImageForOCRSpace(imageFile);
      final bytes = await compressedImage.readAsBytes();
      final base64Image = base64Encode(bytes);

      print('📤 Envoi de l\'image à OCR.space...');

      final response = await http.post(
        Uri.parse('https://api.ocr.space/parse/image'),
        headers: {
          'apikey': ocrSpaceApiKey,
        },
        body: {
          'base64Image': 'data:image/jpeg;base64,$base64Image',
          'language': 'fre', // Français
          'isOverlayRequired': 'false',
          'detectOrientation': 'true',
          'scale': 'true',
          'OCREngine': '2', // Engine 2 meilleur pour manuscrit
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw Exception('Erreur HTTP ${response.statusCode}');
      }

      final data = json.decode(response.body);

      // Vérification d'erreur
      if (data['IsErroredOnProcessing'] == true) {
        final errorMessage = data['ErrorMessage']?.join(', ') ?? 'Erreur inconnue';
        throw Exception(errorMessage);
      }

      // Extraction du texte
      final parsedResults = data['ParsedResults'] as List?;
      if (parsedResults == null || parsedResults.isEmpty) {
        return 'Aucun texte détecté';
      }

      final extractedText = parsedResults[0]['ParsedText'] ?? '';

      print('=== OCR.space - Résultats ===');
      print('Texte : $extractedText');

      return extractedText.isEmpty ? 'Aucun texte détecté' : extractedText.trim();

    } catch (e) {
      throw Exception('Erreur OCR.space: $e');
    }
  }

  Future<void> _processImage(File image) async {
    setState(() {
      _isProcessing = true;
      _extractedText = null;
    });

    try {
      String text;

      if (_selectedTextType == TextType.printed) {
        // Mode hors-ligne avec ML Kit
        print('🔍 Utilisation de ML Kit (hors-ligne)');
        text = await _recognizeWithMLKit(image);

      } else {
        // Mode manuscrit avec OCR.space
        print('🔍 Utilisation de OCR.space (en ligne)');
        final hasInternet = await _hasInternetConnection();

        if (!hasInternet) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.wifi_off, color: Colors.white),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text('Pas de connexion Internet.\nLe mode manuscrit nécessite une connexion.'),
                    ),
                  ],
                ),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 4),
              ),
            );
          }
          setState(() => _isProcessing = false);
          return;
        }

        text = await _recognizeWithOCRSpace(image);
      }

      print('✅ Texte extrait (${text.length} caractères): $text');

      if (mounted) {
        setState(() {
          _extractedText = text;
          _isProcessing = false;
        });
      }

    } catch (e) {
      print('❌ Erreur: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
        setState(() {
          _extractedText = null;
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(
      source: source,
      imageQuality: 85, // Réduit de 100 à 85 pour éviter les fichiers trop lourds
      maxWidth: 1920, // Réduit de 2048 à 1920
      preferredCameraDevice: CameraDevice.rear,
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
        title: const Text('Lecture de texte'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Sélecteur de type de texte
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Type de texte à analyser :',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextTypeButton(
                          type: TextType.printed,
                          icon: Icons.article,
                          label: 'Imprimé',
                          subtitle: 'Hors-ligne',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextTypeButton(
                          type: TextType.handwritten,
                          icon: Icons.edit,
                          label: 'Manuscrit',
                          subtitle: 'Nécessite Internet',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Informations sur le mode sélectionné
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _selectedTextType == TextType.printed
                    ? Colors.green.shade50
                    : Colors.purple.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _selectedTextType == TextType.printed
                      ? Colors.green.shade200
                      : Colors.purple.shade200,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _selectedTextType == TextType.printed
                        ? Icons.offline_bolt
                        : Icons.cloud,
                    color: _selectedTextType == TextType.printed
                        ? Colors.green.shade700
                        : Colors.purple.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _selectedTextType == TextType.printed
                          ? 'ML Kit • Hors-ligne • Texte imprimé uniquement'
                          : 'OCR.space • En ligne • Manuscrit & imprimé (25k/mois gratuit)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Boutons de capture
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : () => _pickImage(ImageSource.camera),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Prendre une photo'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : () => _pickImage(ImageSource.gallery),
              icon: const Icon(Icons.image),
              label: const Text('Sélectionner une photo'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            const SizedBox(height: 16),

            // Affichage des résultats - avec Expanded pour éviter l'overflow
            Expanded(
              child: _selectedImage != null
                  ? SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(_selectedImage!, fit: BoxFit.contain),
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (_isProcessing)
                      Center(
                        child: Column(
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 12),
                            Text(
                              _selectedTextType == TextType.printed
                                  ? 'Analyse en cours (hors-ligne)...'
                                  : 'Analyse en cours (en ligne)...\nCela peut prendre quelques secondes',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (_extractedText != null) ...[
                      Row(
                        children: [
                          const Text(
                            'Texte détecté :',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _selectedTextType == TextType.printed
                                  ? Colors.green.shade100
                                  : Colors.purple.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _selectedTextType == TextType.printed
                                  ? 'ML Kit'
                                  : 'OCR.space',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _selectedTextType == TextType.printed
                                    ? Colors.green.shade800
                                    : Colors.purple.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey.shade50,
                        ),
                        child: SelectableText(
                          _extractedText!,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              )
                  : Center(
                child: Text(
                  'Aucune image sélectionnée',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextTypeButton({
    required TextType type,
    required IconData icon,
    required String label,
    required String subtitle,
  }) {
    final isSelected = _selectedTextType == type;

    return InkWell(
      onTap: () {
        setState(() => _selectedTextType = type);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade500 : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blue.shade700 : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? Colors.white : Colors.grey.shade700,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? Colors.white70 : Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}