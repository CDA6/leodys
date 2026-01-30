import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import '../viewmodels/calculator_viewmodel.dart';
import '../widgets/calculator_display.dart';
import '../widgets/calculator_keypad.dart';

/// Vue principale (architecture MVVM)
/// Initialisation de la calculatrice
class CalculatorView extends StatefulWidget {
  const CalculatorView({super.key});
  static const route = '/calculator';

  @override
  State<CalculatorView> createState() => _CalculatorViewState();
}

///Initialisation Hive
class _CalculatorViewState extends State<CalculatorView> {
  bool _isBoxInitialized = false;

  //Initialisation Hive
  @override
  void initState() {
    super.initState();
    _initBox();
  }

  // Initialisation Hive
  Future<void> _initBox() async {
    await Hive.openBox<String>('calculator_history');
    if (mounted) {
      setState(() {
        _isBoxInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Afficher un loader pendant l'initialisation de la box (si besoin)
    if (!_isBoxInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return ChangeNotifierProvider(
      create: (_) => CalculatorViewModel(),
      child: const _CalculatorContent(),
    );
  }
}

/// Vue principale
class _CalculatorContent extends StatelessWidget {
  const _CalculatorContent({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CalculatorViewModel>();
    final state = viewModel.state;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculatrice'),
        centerTitle: true,
      ),
      body: SizedBox.expand(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            // Ecran de la calculatrice
            ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: 80,
                maxHeight: 300,
              ),
              child: CalculatorDisplay(
                display: state.display,
              ),
            ),

            // Boutons
            Expanded(
              child: CalculatorKeypad(
                onNumberPressed: viewModel.onNumberPressed,
                onOperatorPressed: viewModel.onOperatorPressed,
                onEqualsPressed: viewModel.onEqualsPressed,
                onClearPressed: viewModel.onClearPressed,
                onBackspacePressed: viewModel.onBackspacePressed,
                onHistoryPressed: () => viewModel.onHistoryPressed(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}