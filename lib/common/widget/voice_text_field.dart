import 'package:flutter/material.dart';
import '../../features/notification/presentation/controllers/voice_controller.dart';

class VoiceTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final int maxLines;

  const VoiceTextField({
    required this.controller,
    required this.label,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    super.key,
  });

  @override
  State<VoiceTextField> createState() => _VoiceTextFieldState();
}

class _VoiceTextFieldState extends State<VoiceTextField> {
  final VoiceController _voiceController = VoiceController();
  bool _speechEnabled = false;

  @override
  void initState() {
    super.initState();
    _initVoice();
  }

  void _initVoice() async {
    _speechEnabled = await _voiceController.initSpeech();
    if (mounted) setState(() {});
  }

  void _toggleListening() {
    if (_voiceController.isListening) {
      _voiceController.stopListening();
    } else {
      _voiceController.startListening((text) {
        setState(() => widget.controller.text = text);
      });
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      maxLines: widget.maxLines,
      decoration: InputDecoration(
        labelText: widget.label,
        suffixIcon: _speechEnabled
            ? IconButton(
          icon: Icon(_voiceController.isListening ? Icons.mic : Icons.mic_none),
          color: _voiceController.isListening ? Colors.red : Colors.blue,
          onPressed: _toggleListening,
        )
            : null,
      ),
    );
  }
}