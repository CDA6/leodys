import 'package:flutter/material.dart';
import '../../domain/entities/referent_entity.dart';

class ReferentListTile extends StatelessWidget {
  final ReferentEntity referent;
  final VoidCallback onDelete;
  final VoidCallback onTap;
  final bool isOffline;

  const ReferentListTile({
    super.key,
    required this.referent,
    required this.onDelete,
    required this.onTap,
    this.isOffline = false, // Par défaut à false
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        referent.name,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(referent.email),
      leading: Semantics(
        label: 'Supprimer le référent ${referent.name}',
        button: true,
        child: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
      trailing: Semantics(
        label: isOffline
            ? 'Envoi impossible hors-ligne'
            : 'Envoyer un message à ${referent.name}',
        button: !isOffline,
        child: Icon(
          Icons.send,
          color: isOffline ? Colors.grey : Colors.blue, // Condition de couleur
        ),
      ),
      onTap: isOffline ? null : onTap, // Désactivation du clic si hors-ligne
    );
  }
}
