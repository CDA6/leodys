import 'package:flutter/material.dart';
import 'notification_page.dart';
import 'email_history_page.dart';
import '../controllers/notification_controller.dart';
import '../../data/repositories/notification_repository_impl.dart';

class NotificationDashboard extends StatelessWidget {
  const NotificationDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    // Injection du controller (Singleton ou instance partagée recommandée en prod)
    final controller = NotificationController(NotificationRepositoryImpl());

    return Scaffold(
      appBar: AppBar(title: const Text("Ma Messagerie")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: GridView.count(
          crossAxisCount: 1, // 1 colonne pour de très grandes cibles (Accessibilité DYS)
          childAspectRatio: 2.5,
          mainAxisSpacing: 20,
          children: [
            _buildDashCard(
                context,
                "Contacter un Référent",
                Icons.person_search,
                Colors.blue.shade100,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationPage()))
            ),
            _buildDashCard(
                context,
                "Historique des Envois",
                Icons.history,
                Colors.green.shade100,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => EmailHistoryPage(controller: controller)))
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.black87),
            const SizedBox(width: 20),
            Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}