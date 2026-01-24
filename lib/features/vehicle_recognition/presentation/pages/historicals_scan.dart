import 'package:flutter/material.dart';

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
            title: const Text('Mes plaques scannées'),
          ),
          body: _buildBody(),
        );
      },
    );
  }

  Widget _buildBody() {
    if (historyController.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (historyController.history.isEmpty) {
      return const Center(
        child: Text('Aucune plaque scannée'),
      );
    }

    return ListView.separated(
      itemCount: historyController.history.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final scan = historyController.history[index];

        return ListTile(
          title: Text(scan.plate),
          subtitle: Text(scan.vehicleLabel),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  ttsController.isPlaying
                      ? Icons.stop
                      : Icons.volume_up,
                ),
                onPressed: () {
                  if (ttsController.isPlaying) {
                    ttsController.stop();
                  } else {
                    ttsController.play(scan);
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () =>
                    historyController.deleteByPlate(scan.plate),
              ),
            ],
          ),
        );
      },
    );
  }
}
