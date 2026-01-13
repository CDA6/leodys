import 'package:Leodys/utils/internet_util.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'nav_widget.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //Init our internet listener and current status
  await InternetUtil.init();

  // Initialisation de Supabase avec l'URL du projet et la clé anonyme
  await Supabase.initialize(
    url: 'https://vkhlvzfvmzqcmrkxxaaf.supabase.co', // ⚠️ Remplacez par votre URL
    anonKey: 'sb_publishable_mRFGHPKaqF6sAoLeWKHmYw_R-xMnVCX', // ⚠️ Remplacez par votre API Key
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Leodys',
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
      routes: {
        HomePage.route: (context) => const HomePage(),

      },
      //initialRoute: LoginPage.route,
    );
  }
}