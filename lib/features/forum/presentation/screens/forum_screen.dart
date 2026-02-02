import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leodys/features/forum/presentation/screens/topic_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../provider.dart';

class ForumScreen extends ConsumerWidget {
  const ForumScreen({super.key});
  static final String route = "/forum";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final forumController = ref.read(forumControllerProvider);

    final topicsAsync = ref.watch(topicsProvider); // Watch provider

    return topicsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) {
        debugPrint(err.toString());
        return Center(child: Text("Erreur: $err"));
      },
      data: (topics) {
        return Scaffold(
          appBar: AppBar(title: const Text("Forum")),
          body: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: topics.length,
            itemBuilder: (context, index) {
              final topic = topics[index];
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(
                    topic.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TopicScreen(topic: topic),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () async {
              final titleController = TextEditingController();

              final result = await showDialog<String>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Créer un nouveau sujet"),
                  content: TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      hintText: "Titre du sujet",
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Annuler"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        final title = titleController.text.trim();
                        if (title.isNotEmpty) {
                          Navigator.pop(context, title);
                        }
                      },
                      child: const Text("Créer"),
                    ),
                  ],
                ),
              );

              if (result != null && result.isNotEmpty) {
                final user = Supabase.instance.client.auth.currentUser;
                if (user == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Vous devez être connecté pour créer un sujet")),
                  );
                  return;
                }

                // Add topic
                await forumController.addTopic(result, user.id);

                // Refresh the topics provider so UI updates
                ref.invalidate(topicsProvider);
              }
            },
          ),
        );
      },
    );
  }
}

