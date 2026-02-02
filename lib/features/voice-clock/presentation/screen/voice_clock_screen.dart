import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../common/widget/tts_reader_widget.dart';
import '../viewmodel/voice_clock_viewmodel.dart';
import '../../domain/entities/clock_config.dart';
import '../../../../common/widget/global_appbar.dart';
import '../widget/dys_analog_clock.dart';
import 'package:leodys/common/theme/theme_context_extension.dart';

class VoiceClockScreen extends StatelessWidget {
  static const route = '/voice-clock';

  const VoiceClockScreen({super.key});



  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<VoiceClockViewModel>();


    return Scaffold(
      appBar: GlobalAppBar(title: ("Horloge Vocale")),
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
                  color: context.colorScheme.primary.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                  border: Border.all(color: context.colorScheme.primary, width: 4)
              ),
              child: viewModel.selectedType == ClockType.digital
                  ? Text(
                DateFormat('HH:mm').format(viewModel.currentTime),
                style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold, letterSpacing: 4),
              )
                  :  DysAnalogClock(time: viewModel.currentTime, size: 250),
            ),

            // Bouton de lecture vocale massif
            Semantics(
              label: "Lire l'heure vocalement",
              child:
              TtsReaderWidget(text:"Il est exactement ${DateFormat('HH:mm').format(viewModel.currentTime)}",size:70)
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
      selectedColor: context.colorScheme.primary,
    );
  }
}