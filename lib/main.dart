import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'src/features/calculator/calculator.dart';

void main() {
  // Pour cacher la barre de statut et la barre de navigation
  WidgetsFlutterBinding.ensureInitialized();

  // Cache status + navigation bar
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,  // Barre cache auto après swipe
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const Scaffold(
        body: CalculatorView(),
      ),
    );
  }
}