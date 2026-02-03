import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/topic.dart';
import '../../provider.dart';

class TopicScreen extends ConsumerStatefulWidget {
  final Topic topic;
  const TopicScreen({required this.topic, super.key});

  static const String route = "/forum/topic";

  @override
  ConsumerState<TopicScreen> createState() => _TopicScreenState();
}

class _TopicScreenState extends ConsumerState<TopicScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Watch messages for this topic
    final messages = ref.watch(topicMessagesProvider(widget.topic.id));
    final messagesNotifier = ref.read(topicMessagesProvider(widget.topic.id).notifier);

    return Scaffold(
      appBar: AppBar(title: Text(widget.topic.title)),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: messages.isEmpty
                ? const Center(child: Text("Aucun message pour le moment."))
                : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final m = messages[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  elevation: 2,
                  child: ListTile(
                    title: Text(m.content),
                    subtitle: Text(
                      "${m.username} • ${DateFormat('dd/MM/yyyy HH:mm').format(m.createdAt)}",
                    ),
                  ),
                );
              },
            ),
          ),

          // Message input
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

                    final user = Supabase.instance.client.auth.currentUser;
                    if (user == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Vous devez être connecté pour envoyer un message."),
                        ),
                      );
                      return;
                    }

                    final username = user.email ?? "Anonymous";

                    // Send message via notifier
                    await messagesNotifier.addMessage(text, user.id, username);

                    _controller.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
