import 'dart:io';
import 'package:Leodys/features/left_right/presentation/pose_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';

import 'skeleton_painter.dart';

class RealTimeYoloScreen extends StatefulWidget {
  static const String route = '/left_right';

  final PoseViewModel viewModel;

  const RealTimeYoloScreen({super.key, required this.viewModel});

  @override
  State<RealTimeYoloScreen> createState() => _RealTimeYoloScreenState();
}

class _RealTimeYoloScreenState extends State<RealTimeYoloScreen> {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;
  bool _isFrontCamera = true;
  int _camSensorOrientation = 0;
  int _frameCounter = 0;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {

    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    _cameras = await availableCameras();

    if (_cameras.isNotEmpty) {
      int index = _cameras.indexWhere((c) => c.lensDirection == CameraLensDirection.front);
      if (index == -1) index = 0;
      _startCamera(index);
    }
  }

  Future<void> _startCamera(int index) async {
    if (_controller != null) {
      await _controller!.stopImageStream();
      await _controller!.dispose();
    }

    _selectedCameraIndex = index;
    final description = _cameras[index];
    _isFrontCamera = description.lensDirection == CameraLensDirection.front;
    _camSensorOrientation = description.sensorOrientation; // On récupère l'angle hardware

    _controller = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.yuv420 : ImageFormatGroup.bgra8888,
    );

    try {
      await _controller!.initialize();
      // Fix focus pour éviter le flou en arrière plan
      try {
        await _controller!.setFocusMode(FocusMode.auto);
      } catch (_) {}

      if (mounted) setState(() {});

      _controller!.startImageStream((image) {
        _frameCounter++;
        // On traite 1 image sur 3 pour la fluidité
        if (_frameCounter % 3 == 0) {
          // On passe l'orientation réelle au ViewModel
          widget.viewModel.onFrameReceived(image, _camSensorOrientation);
        }
      });
    } catch (e) {
      print("Erreur camera: $e");
    }
  }

  void _switchCamera() {
    if (_cameras.length < 2) return;
    widget.viewModel.reset();
    int newIndex = (_selectedCameraIndex + 1) % _cameras.length;
    _startCamera(newIndex);
  }

  @override
  void dispose() {
    _controller?.dispose();
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
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
          backgroundColor: Colors.black,
          body: Center(child: CircularProgressIndicator())
      );
    }

    return AnimatedBuilder(
      animation: widget.viewModel,
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
                      return CustomPaint(
                        size: Size(constraints.maxWidth, constraints.maxHeight),
                        painter: SkeletonPainter(
                          points: widget.viewModel.points,
                          isFrontCamera: _isFrontCamera, // Sert juste pour l'effet miroir visuel
                        ),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                top: 50, left: 20,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.black54,
                  child: Text(
                    widget.viewModel.debugText,
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