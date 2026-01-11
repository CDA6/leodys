import 'package:flutter/material.dart';
import 'package:leodys/features/ocr-reader/presentation/reader_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Launcher',
      home: const ReaderScreen(),
      debugShowCheckedModeBanner: false,
      routes: {
        ReaderScreen.route: (context) => const ReaderScreen(),
      },
      initialRoute: ReaderScreen.route,
    );
  }
}