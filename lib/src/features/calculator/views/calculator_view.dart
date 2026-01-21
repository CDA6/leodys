import 'package:flutter/material.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:provider/provider.dart';
import '../viewmodels/calculator_viewmodel.dart';
import 'calculator_display.dart';
import 'calculator_keypad.dart';

/// Vue principale de la calculatrice (architecture MVVM)
/// Cette classe ne contient que l'UI et délègue toute la logique au ViewModel
class CalculatorView extends StatefulWidget {
  const CalculatorView({Key? key}) : super(key: key);

  @override
  State<CalculatorView> createState() => _CalculatorViewState();
}

class _CalculatorViewState extends State<CalculatorView> {
  bool _isBoxInitialized = false;

  @override
  void initState() {
    super.initState();
    _initBox();
  }

  /// Initialise la box Hive au démarrage
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
    // Afficher un loader pendant l'initialisation de la box
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

class _CalculatorContent extends StatelessWidget {
  const _CalculatorContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CalculatorViewModel>();
    final state = viewModel.state;

    return SizedBox.expand(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          // Zone d'affichage (écran de la calculatrice)
          Expanded(
            flex: 2,
            child: CalculatorDisplay(
              display: state.display,
            ),
          ),

          // Pavé de boutons
          Expanded(
            flex: 5,
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
    );
  }
}