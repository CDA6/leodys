import 'package:flutter/material.dart';
import '../../../notification/notification_injection.dart';
import '../controllers/notification_controller.dart';
import '../widgets/referent_list_tile.dart';
import '../widgets/add_referent_dialog.dart';
import '../../domain/entities/referent_entity.dart';

import 'email_compose_page.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {

  final TextEditingController _bodyController = TextEditingController();
  bool _speechEnabled = false;

  final controller = sl<NotificationController>();
  final List<String> categories = ['Mon Référent', 'CAP Emploi', 'AGEFIPH'];

  @override
  void initState() {
    super.initState();
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes Contacts Référents"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, size: 30),
            onPressed: () =>
                showDialog(
                  context: context,
                  builder: (context) =>
                      AddReferentDialog(
                        categories: categories,
                        onAdd: (name, email, cat) async {
                          await controller.addReferent(name, email, cat);
                          _refresh();
                        },
                      ),
                ),
          )
        ],
      ),
      body: FutureBuilder<List<ReferentEntity>>(
        future: controller.fetchReferents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data ?? [];

          return ListView(
            children: categories.map((cat) {
              final refsInCategory = data
                  .where((r) => r.category == cat)
                  .toList();
              if (refsInCategory.isEmpty && cat != 'Mon Référent')
                return const SizedBox.shrink();

              return ExpansionTile(
                initiallyExpanded: true,
                title: Text(cat, style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 18)),
                children: refsInCategory.map((ref) =>
                    ReferentListTile(
                      referent: ref,
                      onDelete: () async {
                        await controller.removeReferent(ref.id);
                        _refresh();
                      },
                      onTap: () =>
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EmailComposePage(
                                      referent: ref, controller: controller),
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
}