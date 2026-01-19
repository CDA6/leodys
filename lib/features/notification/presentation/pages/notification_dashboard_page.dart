import 'package:flutter/material.dart';
import 'package:leodys/common/utils/internet_util.dart';
import 'notification_page.dart';
import 'email_history_page.dart';
import '../controllers/notification_controller.dart';
import '../../../notification/notification_injection.dart';

class NotificationDashboard extends StatefulWidget {
  const NotificationDashboard({super.key});

  static const route = '/messagerie';

  @override
  State<NotificationDashboard> createState() => _NotificationDashboardState();
}

class _NotificationDashboardState extends State<NotificationDashboard> {
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    final connected = InternetUtil.isConnected;
    if (mounted) setState(() => _isConnected = connected);
  }

  @override
  Widget build(BuildContext context) {
    final controller = sl<NotificationController>();

    return Scaffold(
      appBar: AppBar(title: const Text("Ma Messagerie")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            if (!_isConnected)
              const Card(
                color: Colors.orangeAccent,
                child: ListTile(
                  leading: Icon(Icons.wifi_off, color: Colors.white),
                  title: Text(
                    "Mode Hors-ligne",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    "L'envoi d'e-mails est désactivé.",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 1,
                // 1 colonne pour de très grandes cibles (Accessibilité DYS)
                childAspectRatio: 2.5,
                mainAxisSpacing: 20,
                children: [
                  _buildDashCard(
                    context,
                    "Contacter un Référent",
                    Icons.person_search,
                    _isConnected ? Colors.blue.shade100 : Colors.grey.shade300,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotificationPage(),
                      ),
                    ),
                    showWarning: !_isConnected,
                  ),
                  _buildDashCard(
                    context,
                    "Historique des Envois",
                    Icons.history,
                    Colors.green.shade100,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            EmailHistoryPage(controller: controller),
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

  Widget _buildDashCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap, {
    bool showWarning = false,
  }) {
    return Semantics(
      label: title,
      hint: showWarning
          ? 'Indisponible car vous êtes hors-ligne'
          : 'Appuyez pour voir vos contacts',
      enabled: !showWarning,
      // Indique au système si le bouton est actif
      child: Card(
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
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (showWarning) ...[
                const SizedBox(width: 10),
                const Icon(Icons.cloud_off, color: Colors.red),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
