import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:leodys/features/left_right/presentation/pose_viewmodel.dart';

import '../injection_container.dart' as pose_detection;

import 'skeleton_painter.dart';

class RealTimeYoloScreen extends StatefulWidget {
  static const String route = '/left_right';

  const RealTimeYoloScreen({super.key});

  @override
  State<RealTimeYoloScreen> createState() => _RealTimeYoloScreenState();
}

class _RealTimeYoloScreenState extends State<RealTimeYoloScreen> {
  late final PoseViewModel viewModel;

  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;
  bool _isFrontCamera = true;
  int _camSensorOrientation = 0;
  int _frameCounter = 0;

  @override
  void initState() {
    super.initState();
    // on recup le viewmodel via l'injection, comme ca on a une instance neuve
    viewModel = pose_detection.sl<PoseViewModel>();

    _initCamera();
  }

  Future<void> _initCamera() async {
    // force le mode portrait sinon c galere avec les repères x,y
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _cameras = await availableCameras();
    if (_cameras.isNotEmpty) {
      // on cherche la cam selfie par defaut
      int index = _cameras.indexWhere((c) => c.lensDirection == CameraLensDirection.front);
      if (index == -1) index = 0;
      _startCamera(index);
    }
  }

  Future<void> _startCamera(int index) async {
    // nettoyage : si un controller existe deja faut le tuer proprement
    if (_controller != null) {
      await _controller!.stopImageStream();
      await _controller!.dispose();
    }

    _selectedCameraIndex = index;
    final description = _cameras[index];
    _isFrontCamera = description.lensDirection == CameraLensDirection.front;
    // important pour savoir dans quel sens est l'image brute
    _camSensorOrientation = description.sensorOrientation;

    _controller = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: false,
      // format different selon l'os, yuv pr android et bgra pr ios
      imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.yuv420 : ImageFormatGroup.bgra8888,
    );

    try {
      await _controller!.initialize();
      try {
        // tente l'autofocus mais plante sur certains tels donc try catch vide
        await _controller!.setFocusMode(FocusMode.auto);
      } catch (_) {}

      if (mounted) setState(() {});

      _controller!.startImageStream((image) {
        _frameCounter++;
        // opti : on traite que 1 frame sur 3 pour pas faire ramer le tel
        if (_frameCounter % 3 == 0) {
          viewModel.onFrameReceived(image, _camSensorOrientation);
        }
      });
    } catch (e) {
      print("Erreur camera: $e");
    }
  }

  void _switchCamera() {
    if (_cameras.length < 2) return;
    // vide les points pour pas avoir un squelette fantome pdt le switch
    viewModel.reset();

    int newIndex;
    // boucle sur les cameras dispos
    if (_selectedCameraIndex == _cameras.length - 1) {
      newIndex = 0;
    } else {
      newIndex = _selectedCameraIndex + 1;
    }
    _startCamera(newIndex);
  }

  @override
  void dispose() {
    _controller?.dispose();
    // tres important : on remet l'orientation normale qd on quitte l'ecran
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ecran noir de chargement tant que la cam est pas prete
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
          backgroundColor: Colors.black,
          body: Center(child: CircularProgressIndicator())
      );
    }

    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              Center(
                child: CameraPreview(
                  _controller!,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // le painter qui dessine les points par dessus la video
                      return CustomPaint(
                        size: Size(constraints.maxWidth, constraints.maxHeight),
                        painter: SkeletonPainter(
                          points: viewModel.points,
                          isFrontCamera: _isFrontCamera,
                        ),
                      );
                    },
                  ),
                ),
              ),
              // petit encart de debug pour voir les fps/infos
              Positioned(
                top: 50, left: 20,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.black54,
                  child: Text(
                    viewModel.debugText,
                    style: const TextStyle(color: Colors.greenAccent, fontSize: 18),
                  ),
                ),
              ),
              Positioned(
                bottom: 30, right: 30,
                child: FloatingActionButton(
                  backgroundColor: Colors.white,
                  onPressed: _switchCamera,
                  child: const Icon(Icons.cameraswitch, color: Colors.black),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}