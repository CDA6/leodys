import 'package:flutter/material.dart';
import 'package:leodys/features/vehicle_recognition/presentation/widgets/audio_control_button.dart';
import 'package:leodys/features/vehicle_recognition/presentation/widgets/scan_plate_button.dart';
import 'package:leodys/features/vehicle_recognition/presentation/widgets/vehicle_label_preview.dart';

class ScanImmatriculationScreen extends StatefulWidget {

  const ScanImmatriculationScreen({super.key});

  static const route = '/immatriculation';

  @override
  State<ScanImmatriculationScreen> createState() => _ScanImmatriculationScreenState();
}

class _ScanImmatriculationScreenState extends State<ScanImmatriculationScreen> {
  @override
  Widget build(BuildContext context) {
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
                leading: const Icon(Icons.directions_car),
                title: const Text('Scanner la plaque'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/immatriculation');
                },
              ),
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Historiques de scans'),
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
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(
                children: [
                  ScanPlateButton(
                    isLoading: false,
                    onPressed: () {

                    },
                  ),

                  const SizedBox(height: 12),

                  VehicleLabelPreview(text: 'Pas encore implémenter'),

                  const SizedBox(height: 12),

                  AudioControlButton(
                    onPlay: () {

                    },

                    onStop: () {

                    },
                  ),
                ],
              ),
            ),
          ),
        );
  }


}