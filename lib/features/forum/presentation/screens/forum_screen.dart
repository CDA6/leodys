import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:leodys/features/forum/presentation/providers/message_provider.dart';
import 'package:leodys/features/forum/presentation/controllers/forum_controller.dart';
import 'package:leodys/features/forum/presentation/providers/profile_provider.dart';
import 'package:leodys/features/forum/domain/entities/message.dart';

class ForumScreen extends ConsumerStatefulWidget {
  static const String route = "/forum";

  const ForumScreen({super.key});

  @override
  ConsumerState<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends ConsumerState<ForumScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();

    // Charger les messages après la vérification du profil
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(messagesProvider.notifier).loadMessages();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(messagesProvider);
    final forumController = ref.read(forumControllerProvider);
    final profileCheck = ref.watch(userHasProfileProvider);

    return profileCheck.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        body: Center(child: Text("Échec de la vérification du profil : $err")),
      ),
      data: (hasProfile) {
        if (!hasProfile) {
          return Scaffold(
            appBar: AppBar(title: const Text("Profil requis")),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Vous devez créer un profil avant d'accéder au forum.",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, "/create-profile");
                    },
                    child: const Text("Créer un profil"),
                  ),
                ],
              ),
            ),
          );
        }

        // INTERFACE DU FORUM
        return Scaffold(
          appBar: AppBar(title: const Text('Forum')),
          body: Column(
            children: [
              Expanded(
                child: messages.isEmpty
                    ? const Center(child: Text("Aucun message pour le moment."))
                    : ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final Message message = messages[index];
                    return ListTile(
                      title: Text(message.content),
                      subtitle: Text(
                        "${message.username} : ${DateFormat('dd MM yyyy, HH:mm').format(message.createdAt)}",
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: "Tapez un message...",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () async {
                        final text = _controller.text.trim();
                        if (text.isEmpty) return;

                        try {
                          await forumController.sendMessage(text);
                          _controller.clear();
                        } catch (_) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Vous devez créer un profil avant d'envoyer un message.",
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
