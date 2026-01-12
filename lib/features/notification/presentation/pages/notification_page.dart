import 'package:flutter/material.dart';
import '../controllers/notification_controller.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../domain/entities/referent.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final controller = NotificationController(NotificationRepositoryImpl());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Contacter un Référent")),
      body: FutureBuilder<List<Referent>>(
        future: controller.fetchReferents(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final ref = snapshot.data![index];
              return ListTile(
                title: Text(ref.name),
                subtitle: Text(ref.role),
                trailing: const Icon(Icons.send),
                onTap: () => controller.notify(ref),
              );
            },
          );
        },
      ),
    );
  }
}