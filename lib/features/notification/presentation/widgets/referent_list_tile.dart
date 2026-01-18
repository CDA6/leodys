import 'package:flutter/material.dart';
import '../../domain/entities/referent_entity.dart';

class ReferentListTile extends StatelessWidget {
  final ReferentEntity referent;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const ReferentListTile({
    super.key,
    required this.referent,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(referent.name, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(referent.email),
      leading: IconButton(
        icon: const Icon(Icons.delete_outline, color: Colors.red),
        onPressed: onDelete,
      ),
      trailing: const Icon(Icons.send, color: Colors.blue),
      onTap: onTap,
    );
  }
}