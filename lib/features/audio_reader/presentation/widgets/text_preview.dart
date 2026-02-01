import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TextPreview extends StatelessWidget {
  final String text;

  const TextPreview({
    super.key,
    required this.text,
  });


  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) {
      return const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
              'Aucun texte scanné',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              )
          )
      );
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView( // rendre le contenu scrollable
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18, // taille des lettres
            height: 1.5, // l'espace entrer les lignes
          )
        )
      ),

    );
  }
}