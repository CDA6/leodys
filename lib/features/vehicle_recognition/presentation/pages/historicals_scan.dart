import 'package:flutter/material.dart';
import 'package:leodys/features/vehicle_recognition/presentation/widgets/plate_tile.dart';

import '../../../../common/theme/theme_context_extension.dart';
import '../../injection/vehicle_recognition_injection.dart';
import '../controllers/plate_history_controller.dart';
import '../controllers/plate_tts_controller.dart';

class HistoricalsScan extends StatefulWidget {
  const HistoricalsScan({super.key});

  static const route = '/historique_plaques';

  @override
  State<HistoricalsScan> createState() => _HistoricalScanState();
}

class _HistoricalScanState extends State<HistoricalsScan> {
  late final PlateHistoryController historyController;
  late final PlateTtsController ttsController;

  @override
  void initState() {
    super.initState();
    historyController = createPlateHistoryController();
    ttsController = createPlateTtsController();
    historyController.loadHistory();
  }

  @override
  void dispose() {
    historyController.dispose();
    ttsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        historyController,
        ttsController,
      ]),
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Mes plaques scannées',
              style: TextStyle(
              color: context.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,),
            ),
            backgroundColor:  context.colorScheme.primaryContainer,
          ),
          body: _buildBody(),
        );
      },
    );
  }

  Widget _buildBody() {

    // Montre un CircularProgressIndicator si ca charge
    if (historyController.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Montre le texte 'Aucune plaque si pas d'historique
    if (historyController.history.isEmpty) {
      return const Center(
        child: Text('Aucune plaque scannée'),
      );
    }

    // construire les items et ajouter automatiquement des séparateur
    // contrairement au ListView.builder
    return ListView.separated(
      // Affichage ligne par ligne
      itemCount: historyController.history.length,
      // séparateur avec des parametres ignorés
      // divider représente un ligne de séparation
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        // Contruire les lignes à partir de l'index corespondante
        final scan = historyController.history[index];

        return PlateTile(
          scan: scan,
          isPlaying: ttsController.isPlaying,
          onPlay: () => ttsController.play(scan),
          onStop: ttsController.stop,
          onDelete: () =>
              historyController.deleteByPlate(scan.plate),
        );

      },
    );
  }
}
