import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';


import 'features/left_right/presentation/pose_viewmodel.dart';
import 'features/left_right/presentation/real_time_yolo_screen.dart';
import 'features/left_right/injection_container.dart' as di;

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Permission.camera.request();

  await di.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => di.sl<PoseViewModel>()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Left/Right Dev',
        debugShowCheckedModeBanner: false,


        home: const MenuTestScreen(),

        routes: {

          RealTimeYoloScreen.route: (context) {
            return RealTimeYoloScreen(
                viewModel: Provider.of<PoseViewModel>(context, listen: false)
            );
          },
        },
      ),
    );
  }
}


class MenuTestScreen extends StatelessWidget {
  const MenuTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Menu Principal (Test)")),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.accessibility_new),
          label: const Text("Lancer Détection G/D"),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(20),
            textStyle: const TextStyle(fontSize: 20),
          ),
          onPressed: () {
            // C'est ça qui teste si ton routing marche !
            Navigator.pushNamed(context, RealTimeYoloScreen.route);
          },
        ),
      ),
    );
  }
}