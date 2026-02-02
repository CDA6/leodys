import 'package:flutter/material.dart';
import 'package:leodys/common/utils/internet_util.dart';
import 'package:leodys/common/theme/theme_context_extension.dart';
import 'notification_page.dart';
import 'email_history_page.dart';
import '../../../../common/widget/global_appbar.dart';

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
    // Ajoutez 'await' si isConnected est asynchrone
    final connected = InternetUtil.isConnected;
    if (mounted) setState(() => _isConnected = connected);
  }

  @override
  Widget build(BuildContext context) {
    // PLUS BESOIN de 'final controller = sl<...>' ici.

    return Scaffold(
      appBar: GlobalAppBar(
        title: "Ma Messagerie",
        showAuthActions: false,
      ),
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
                    "L'envoi d'e-mails est désactivé, mais vous pouvez consulter vos données.",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 1,
                childAspectRatio: 2.5,
                mainAxisSpacing: 20,
                children: [
                  _buildDashCard(
                    context,
                    "Contacter un Référent",
                    Icons.person_search,
                        () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        // MODIFICATION : Plus de paramètre, la page se débrouille
                        builder: (_) => const NotificationPage(),
                      ),
                    ),
                    // Note : Grâce à Hive, vous pourriez autoriser l'accès même hors ligne !
                    // Si vous voulez tester, mettez : showWarning: false
                    showWarning: !_isConnected,
                  ),
                  _buildDashCard(
                    context,
                    "Historique des Envois",
                    Icons.history,
                        () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        // MODIFICATION : Plus de paramètre 'controller'
                        builder: (_) => const EmailHistoryPage(),
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
      VoidCallback onTap, {
        bool showWarning = false,
      }) {
    // Si on est en "warning" (hors ligne), le bouton est désactivé
    final bool isEnabled = !showWarning;

    return Semantics(
      label: title,
      hint: showWarning
          ? 'Indisponible car vous êtes hors-ligne'
          : 'Appuyez pour voir vos contacts',
      enabled: isEnabled,
      child: Card(
        color: isEnabled
            ? context.colorScheme.surfaceContainerHighest
            : Colors.grey.withOpacity(0.2), // Correction compatibilité version
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: isEnabled ? 4 : 0,
        child: InkWell(
          onTap: isEnabled ? onTap : null,
          borderRadius: BorderRadius.circular(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                  icon,
                  size: 50,
                  color: isEnabled ? context.colorScheme.primary : Colors.grey
              ),
              const SizedBox(width: 20),
              Text(
                title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isEnabled ? Colors.black : Colors.grey,
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