import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:leodys/src/features/audio_reader/domain/usecases/scan_and_read_text_usecase.dart';
import 'package:leodys/src/features/audio_reader/presentation/widgets/audio_controls.dart';
import 'package:leodys/src/features/audio_reader/presentation/widgets/scan_button.dart';
import 'package:leodys/src/features/audio_reader/presentation/widgets/text_preview.dart';

class ReaderScreen extends StatefulWidget {
  const ReaderScreen({super.key});

  @override
  State<ReaderScreen> createState() => _ReaderScreen();
}

class _ReaderScreen extends State<ReaderScreen> {
  bool _isScanning = false;

  String _textPreview = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(

        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Image.asset('assets/images/logo.jpeg',
            height: 32
            ),
            const SizedBox(width:5,),
            Text('LeoDys')
          ]
        ),

        backgroundColor: Colors.green.shade400,

      ),


      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Text('Menu'),
              decoration: BoxDecoration(color: Colors.green),
            ),
            ListTile(
              leading: Icon(Icons.scanner),
              title: Text('Scanner un document'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.photo_camera),
              title: Text('Reconnaissance immatriculation'),

              onTap: () {},
            ),
          ],
        ),
      ),

      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: ListView(
            // crossAxisAlignment: CrossAxisAlignment.stretch,

            children: [

              ScanButton(
                isLoading: _isScanning,
                onPressed: () {
                  setState(() {
                    _isScanning = true;
                  });

                  // Simulation visuelle uniquement
                  Future.delayed(const Duration(seconds: 2), () {
                    setState(() {
                      _isScanning = false;
                      // _textPreview = 'Simule un texte scanné';
                    });
                  });
                },
              ),
              const SizedBox(height: 12),
              TextPreview(text: _textPreview),
              const SizedBox(height: 12),
              AudioControls(
                onPlay: (){},
                onPause: (){},
                onResume: (){},
                onStop: (){},
              ),


            ],
          ),
        ),
      ),
    );
  }
}
