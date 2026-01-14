import 'package:flutter/material.dart';
import 'package:leodys/constants/auth_constants.dart';
import 'package:leodys/features/authentication/presentation/pages/auth/home_page.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'features/authentication/domain/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: AuthConstants.projectUrl,
    anonKey: AuthConstants.apiKey,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthService(),
      child: MaterialApp(
        title: 'Leodys',
        home: const HomePage(),
      ),
    );
  }
}
