
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:leodys/features/vehicle_recognition/presentation/widgets/plate_tile.dart';

class HistoricalsScan extends StatefulWidget{

  const HistoricalsScan({super.key});

  static const route = '/historique_plaques';

  @override
  State<HistoricalsScan> createState() => _HistoricalScanState();
}

class _HistoricalScanState extends State<HistoricalsScan> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes plaques scannées'),
      ),
      body: Text('En Attente d\'implémentation'),
    );
  }
}