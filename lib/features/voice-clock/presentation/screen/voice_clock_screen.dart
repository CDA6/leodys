import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../common/widget/tts_reader_widget.dart';
import '../viewmodel/voice_clock_viewmodel.dart';
import '../../domain/entities/clock_config.dart';

class VoiceClockScreen extends StatelessWidget {
  static const route = '/voice-clock';

  const VoiceClockScreen({super.key});



  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<VoiceClockViewModel>();


    return Scaffold(
      appBar: AppBar(title: const Text("Horloge Vocale")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Sélecteur de style (Cibles larges pour DYS)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _styleButton(context, "Digital", ClockType.digital, viewModel),
                const SizedBox(width: 30),
                _styleButton(context, "Aiguilles", ClockType.analog, viewModel),
              ],
            ),

            // Affichage de l'heure
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blue, width: 4)
              ),
              child: viewModel.selectedType == ClockType.digital
                  ? Text(
                DateFormat('HH:mm').format(viewModel.currentTime),
                style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold, letterSpacing: 4),
              )
                  : const Icon(Icons.watch_later, size: 120, color: Colors.blue),
            ),

            // Bouton de lecture vocale massif
            Semantics(
              label: "Lire l'heure vocalement",
              child:

              TtsReaderWidget(text:"Il est exactement ${DateFormat('HH:mm').format(viewModel.currentTime)}")
            ),
          ],
        ),
      ),
    );
  }

  Widget _styleButton(BuildContext context, String label, ClockType type, VoiceClockViewModel vm) {
    bool isSelected = vm.selectedType == type;
    return ChoiceChip(
      label: Text(label, style: const TextStyle(fontSize: 18)),
      selected: isSelected,
      onSelected: (_) => vm.setClockType(type),
      selectedColor: Colors.blue.shade200,
    );
  }
}