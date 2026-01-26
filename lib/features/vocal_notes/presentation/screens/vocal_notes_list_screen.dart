import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:leodys/features/vocal_notes/presentation/viewmodels/vocal_notes_viewmodel.dart';
import 'package:leodys/features/vocal_notes/presentation/widgets/vocal_note_card.dart';
import 'package:leodys/features/vocal_notes/presentation/screens/vocal_note_editor_screen.dart';

class VocalNotesListScreen extends StatefulWidget {
  static const String route = '/vocal_notes_list';

  const VocalNotesListScreen({super.key});

  @override
  State<VocalNotesListScreen> createState() => _VocalNotesListScreenState();
}

class _VocalNotesListScreenState extends State<VocalNotesListScreen> {
  @override
  void initState() {
    super.initState();
    // Charger les notes au démarrage
    Future.microtask(() => context.read<VocalNotesViewModel>().loadNotes());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Notes Vocales'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<VocalNotesViewModel>().loadNotes();
            },
          ),
        ],
      ),
      body: Consumer<VocalNotesViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoadingNotes) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.notes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.note_alt_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucune note vocale',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => _navigateToEditor(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Créer une note'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: viewModel.notes.length,
            itemBuilder: (context, index) {
              final note = viewModel.notes[index];
              return VocalNoteCard(
                note: note,
                onTap: () => _navigateToEditor(context, noteId: note.id),
                onDelete: () => _confirmDelete(context, note.id),
                onPlay: () {
                  // Lecture TTS du contenu
                  viewModel.speak(note.content);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToEditor(context),
        child: const Icon(Icons.mic),
      ),
    );
  }

  void _navigateToEditor(BuildContext context, {String? noteId}) {
    Navigator.pushNamed(
      context,
      VocalNoteEditorScreen.route,
      arguments: noteId,
    );
  }

  Future<void> _confirmDelete(BuildContext context, String noteId) async {
    final curViewModel = context.read<VocalNotesViewModel>();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer ?'),
        content: const Text('Voulez-vous vraiment supprimer cette note ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await curViewModel.deleteNote(noteId);
    }
  }
}
