import 'package:Leodys/src/features/left_right/data/datasource/pose_datasource.dart';
import 'package:Leodys/src/features/left_right/presentation/pose_viewmodel.dart';
import 'package:Leodys/src/features/left_right/presentation/real_time_yolo_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'injection_factory.dart' as di;


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await Permission.camera.request();

  await di.init();
  await di.sl<PoseDataSource>().loadModel();

  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RealTimeYoloScreen(
        viewModel: di.sl<PoseViewModel>()
    );
  }
}