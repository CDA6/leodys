import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../notification/notification_injection.dart'; // Pour sl
import '../controllers/notification_controller.dart';
import '../widgets/referent_list_tile.dart';
import '../widgets/add_referent_dialog.dart';
import '../../../../common/widget/global_appbar.dart';
import 'email_compose_page.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  // 1. Injection via GetIt
  final controller = sl<NotificationController>();

  final List<String> categories = ['Mon Référent', 'CAP Emploi', 'AGEFIPH'];
  final _supabase = Supabase.instance.client;
  String get currentUserId => _supabase.auth.currentUser?.id ?? '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadData();
      controller.synchronizeReferents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlobalAppBar(
        title: "Mes Contacts",
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sync en cours...")));
              await controller.synchronizeReferents();
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_circle, size: 30),
            onPressed: () => showDialog(
              context: context,
              builder: (context) => AddReferentDialog(
                categories: categories,
                onAdd: (name, email, cat) async {
                  if (currentUserId.isNotEmpty) {
                    await controller.addReferent(name, email, cat, currentUserId);
                  }
                },
              ),
            ),
          )
        ],
      ),
      // 2. LISTENABLE BUILDER au lieu de Consumer
      body: ListenableBuilder(
        listenable: controller,
        builder: (context, child) {

          if (controller.isLoading && controller.referents.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            children: categories.map((cat) {
              final refsInCategory = controller.referents
                  .where((r) => r.category == cat)
                  .toList();

              if (refsInCategory.isEmpty && cat != 'Mon Référent') {
                return const SizedBox.shrink();
              }

              return ExpansionTile(
                initiallyExpanded: true,
                title: Text(cat, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                children: refsInCategory.map((ref) => ReferentListTile(
                  referent: ref,
                  onDelete: () async => await controller.removeReferent(ref.id),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EmailComposePage(referent: ref, controller: controller),
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