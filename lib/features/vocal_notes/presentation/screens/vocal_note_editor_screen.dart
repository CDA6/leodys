import 'dart:async';
import 'package:flutter/material.dart';
import 'package:leodys/common/theme/state_color_extension.dart';
import 'package:leodys/common/theme/theme_context_extension.dart';
import 'package:provider/provider.dart';
import 'package:leodys/features/vocal_notes/presentation/viewmodels/vocal_notes_viewmodel.dart';
import 'package:leodys/features/vocal_notes/presentation/widgets/status_indicator.dart';

class VocalNoteEditorScreen extends StatefulWidget {
  static const String route = '/vocal_note_editor';

  const VocalNoteEditorScreen({super.key});

  @override
  State<VocalNoteEditorScreen> createState() => _VocalNoteEditorScreenState();
}

class _VocalNoteEditorScreenState extends State<VocalNoteEditorScreen> {
  final _contentController = TextEditingController();
  StreamSubscription<String>? _speechSub;
  String? _noteId;
  bool _isNew = true;
  bool _noteLoaded = false;
  String _textBeforeListening = '';
  int _cursorPositionBeforeListening = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_noteLoaded) return;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String) {
      _noteId = args;
      _isNew = false;
      _loadNoteData();
      _noteLoaded = true;
    }
  }

  void _loadNoteData() {
    final viewModel = context.read<VocalNotesViewModel>();
    try {
      final note = viewModel.notes.firstWhere((n) => n.id == _noteId);
      _contentController.text = note.content;
    } catch (e) {
      // Note non trouvée
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialiser le service vocal et écouter le flux de parole
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<VocalNotesViewModel>();
      viewModel.initialize();
      _speechSub = viewModel.speechText.listen((text) {
        if (mounted) {
          // Ajouter un espace si on insère après du texte existant
          final needsSpace = _cursorPositionBeforeListening > 0 &&
              _textBeforeListening.isNotEmpty &&
              !_textBeforeListening[_cursorPositionBeforeListening - 1].contains(RegExp(r'\s'));
          final prefix = needsSpace ? ' ' : '';

          // Remplacer le texte depuis la position de départ avec le résultat partiel actuel
          final newText = _textBeforeListening.substring(0, _cursorPositionBeforeListening) +
              prefix +
              text +
              _textBeforeListening.substring(_cursorPositionBeforeListening);
          final newCursorPosition = _cursorPositionBeforeListening + prefix.length + text.length;

          _contentController.value = TextEditingValue(
            text: newText,
            selection: TextSelection.collapsed(offset: newCursorPosition),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _speechSub?.cancel();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<VocalNotesViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? 'Nouvelle Note' : 'Modifier Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => _saveNote(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            StatusIndicator(
              icon: Icons.mic,
              label: viewModel.isListening ? 'Écoute...' : 'Micro',
              isActive: viewModel.isListening,
              activeColor: context.stateColors.error,
              inactiveColor: context.colorScheme.primary,
            ),
            const SizedBox(height: 16),

            Expanded(
              child: Stack(
                children: [
                  TextField(
                    controller: _contentController,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: const InputDecoration(
                      labelText: 'Contenu (Dites quelque chose...)',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: FloatingActionButton(
                      heroTag: 'mic_btn',
                      onPressed: () {
                        if (!viewModel.isListening) {
                          // Sauvegarder l'état du texte avant de commencer l'écoute
                          _textBeforeListening = _contentController.text;
                          final selection = _contentController.selection;
                          _cursorPositionBeforeListening = selection.isValid
                              ? selection.start
                              : _contentController.text.length;
                        }
                        viewModel.toggleListening();
                      },
                      backgroundColor: viewModel.isListening
                          ? context.stateColors.error
                          : null,
                      child: Icon(
                        viewModel.isListening ? Icons.mic_off : Icons.mic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveNote(BuildContext context) async {
    final content = _contentController.text.trim();

    final viewModel = context.read<VocalNotesViewModel>();
    await viewModel.saveNote(content, id: _noteId);

    if (context.mounted) {
      Navigator.pop(context);
    }
  }
}
