import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controllers/notification_controller.dart';
import '../../../notification/notification_injection.dart'; // Pour accéder à sl
import '../widgets/history_detail_dialog.dart';
import '../../../../common/widget/global_appbar.dart';

class EmailHistoryPage extends StatefulWidget {
  const EmailHistoryPage({super.key});

  @override
  State<EmailHistoryPage> createState() => _EmailHistoryPageState();
}

class _EmailHistoryPageState extends State<EmailHistoryPage> {
  // 1. On récupère le contrôleur via GetIt directement
  final controller = sl<NotificationController>();

  @override
  void initState() {
    super.initState();
    // 2. On lance le chargement
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadData();
      controller.synchronizeMessageHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlobalAppBar(
        title: "Historique des messages",
        actions: [
          // On écoute le controller juste pour le bouton de sync (optionnel)
          ListenableBuilder(
              listenable: controller,
              builder: (context, _) {
                if (controller.isLoading) {
                  return const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(color: Colors.white));
                }
                return IconButton(
                  icon: const Icon(Icons.sync, size: 30),
                  onPressed: () async {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sync en cours...")));
                    await controller.synchronizeMessageHistory();
                  },
                );
              }
          )
        ],
      ),
      // 3. REMPLACEMENT DE CONSUMER PAR LISTENABLEBUILDER
      body: ListenableBuilder(
        listenable: controller, // On dit : "Surveille cet objet GetIt"
        builder: (context, child) {

          if (controller.messages.isEmpty) {
            return controller.isLoading
                ? const Center(child: CircularProgressIndicator())
                : const Center(child: Text("Aucun message envoyé"));
          }

          return ListView.separated(
            itemCount: controller.messages.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final msg = controller.messages[index];
              return ListTile(
                title: Text("À : ${msg.referentName}"),
                subtitle: Text("${msg.subject}\n${DateFormat('dd/MM/yyyy HH:mm').format(msg.sentAt)}"),
                isThreeLine: true,
                onTap: () => showDialog(
                  context: context,
                  builder: (context) => HistoryDetailDialog(message: msg),
                ),
              );
            },
          );
        },
      ),
    );
  }
}