import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'features/money_manager/domain/models/payment_transaction.dart';
import 'features/money_manager/presentation/views/money_manager_view.dart';
import 'features/money_manager/presentation/views/payment_history_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser les données de locale pour le français
  await initializeDateFormatting('fr_FR', null);

  // Initialiser Hive
  await Hive.initFlutter();

  // Enregistrer l'adapteur pour PaymentTransaction
  Hive.registerAdapter(PaymentTransactionAdapter());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Leodys Payment',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MoneyManagerView(),
      routes: {
        MoneyManagerView.route: (context) => const MoneyManagerView(),
        PaymentHistoryView.route: (context) => const PaymentHistoryView(),
      },
    );
  }
}