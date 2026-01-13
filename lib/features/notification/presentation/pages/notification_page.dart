import 'package:flutter/material.dart';
import '../controllers/notification_controller.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../domain/entities/referent_entity.dart';
import 'email_compose_page.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final controller = NotificationController(NotificationRepositoryImpl());
  final List<String> categories = ['Mon Référent', 'CAP Emploi', 'AGEFIPH'];

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes Contacts Référents"),
        actions: [IconButton(icon: const Icon(Icons.add), onPressed: _showAddDialog)],
      ),
      body: FutureBuilder<List<Referent>>(
        future: controller.fetchReferents(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final data = snapshot.data!;

          return ListView(
            children: categories.map((cat) {
              final refsInCategory = data.where((r) => r.category == cat).toList();
              return ExpansionTile(
                initiallyExpanded: true,
                title: Text(cat, style: const TextStyle(fontWeight: FontWeight.bold)),
                children: refsInCategory.map((ref) => ListTile(
                  title: Text(ref.name),
                  subtitle: Text(ref.email),
                  leading: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await controller.removeReferent(ref.id);
                      _refresh();
                    },
                  ),
                  trailing: const Icon(Icons.send, color: Colors.blue),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EmailComposePage(
                          referent: ref,
                          controller: controller
                      ),
                    ),
                  ),
                )).toList(),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  void _showAddDialog() {
    // Implémentation d'un simple Dialog avec TextFields pour appeler controller.addReferent
    // et faire un _refresh() après l'ajout.
  }
}