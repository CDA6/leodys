import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controllers/notification_controller.dart';
import '../../domain/entities/message_entity.dart';
import '../widgets/history_detail_dialog.dart';
import '../../../../common/widget/global_appbar.dart';

class EmailHistoryPage extends StatefulWidget {
  final NotificationController controller;

  const EmailHistoryPage({required this.controller, super.key});

  @override
  State<EmailHistoryPage> createState() => _EmailHistoryPageState();

}

class _EmailHistoryPageState extends State<EmailHistoryPage> {
  Future<List<MessageEntity>>? _messageHistoryFuture;

  @override
  void initState() {
    super.initState();
    _loadMessageHistory();
  }

  void _loadMessageHistory() {
    _messageHistoryFuture = widget.controller.fetchHistory();
  }

  Future<void> _performSync() async {
    // Afficher un indicateur de chargement
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Synchronisation en cours...")),
    );
    await widget.controller.synchronizeMessageHistory();
    setState(() {
      _loadMessageHistory(); // Recharger les données après synchro
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Synchronisation terminée !")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlobalAppBar(
        title: "Historique des messages",
        actions: [
          IconButton(
            icon: const Icon(Icons.sync, size: 30),
            onPressed: _performSync,
            tooltip: "Synchroniser l'historique",
          ),
        ],
      ),
      body: FutureBuilder<List<MessageEntity>>(
        future: _messageHistoryFuture, // Utilise la variable d'état
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Erreur: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Aucun message envoyé"));
          }

          final history = snapshot.data!;
          return ListView.separated(
            itemCount: history.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final msg = history[index];
              return ListTile(
                title: Text("À : ${msg.referentName}"),
                subtitle: Text("${msg.subject}\n${DateFormat('dd/MM/yyyy HH:mm').format(msg.sentAt)}"),
                isThreeLine: true,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => HistoryDetailDialog(message: msg),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}