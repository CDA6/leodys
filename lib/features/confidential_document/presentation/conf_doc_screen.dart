import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:leodys/features/confidential_document/presentation/widget/photo_card.dart';
import 'package:provider/provider.dart';

import 'confidential_document_viewmodel.dart';

class _ConfidentialDocumentContent extends StatelessWidget {
  const _ConfidentialDocumentContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Document confidentiel")),
      body: Consumer<ConfidentialDocumentViewmodel>(
        builder: (context, vm, child) {
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _ActionButtons(), // Extraction 1
                if (vm.lookingForPicture) const CircularProgressIndicator(),
                const _GallerySection(), // Extraction 2
                const _ImageEditSection(), // Extraction 3
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons();

  @override
  Widget build(BuildContext context) {
    final vm = context.read<ConfidentialDocumentViewmodel>();

    return Wrap(
      spacing: 10,
      children: [
        if (!kIsWeb)
          ElevatedButton.icon(
            onPressed: () {}, // TODO
            icon: const Icon(Icons.camera_alt),
            label: const Text("Photo"),
          ),
        ElevatedButton.icon(
          onPressed: vm.getPicture,
          icon: const Icon(Icons.file_upload),
          label: const Text("Télécharger"),
        ),
        ElevatedButton.icon(
          onPressed: () async {
            // Logique de verrouillage centralisée
            if (vm.session.isLocked) {
              final password = await _showPasswordDialog(context);
              if (password == null || password.isEmpty) return;
              if (!(await vm.saveKey(password))) return;
            }

            // Déclenchement automatique de la SnackBar après le chargement
            await vm.getAllPicture();
            if (vm.errorCount > 0 && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${vm.errorCount} fichiers illisibles (clé incorrecte)')),
              );
            }
          },
          icon: const Icon(Icons.picture_in_picture),
          label: const Text("Voir ma galerie"),
        ),
      ],
    );
  }

  Future<String?> _showPasswordDialog(BuildContext context) async {
    TextEditingController passwordController = TextEditingController();
    return showDialog<String>(
      context: context,
      barrierDismissible:
      false, // L'utilisateur doit cliquer sur un bouton pour fermer
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sécuriser l\'image'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Entrez votre mot de passe de chiffrement pour continuer :',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true, // Cache le texte (petits points)
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Mot de passe',
                  hintText: 'Ne le perdez pas !',
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler'),
              onPressed: () => Navigator.of(context).pop(null), // Renvoie null
            ),
            ElevatedButton(
              child: const Text('Confirmer'),
              onPressed: () {
                // On renvoie le texte saisi
                Navigator.of(context).pop(passwordController.text);
              },
            ),
          ],
        );
      },
    );
  }
}


class _GallerySection extends StatelessWidget {
  const _GallerySection();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ConfidentialDocumentViewmodel>();

    if (vm.pictures == null || vm.pictures!.isEmpty) {
      return const SizedBox(
        height: 400,
        child: Center(child: Text("Aucun fichier enregistré")),
      );
    }

    // Calcul des colonnes simplifié
    double width = MediaQuery.of(context).size.width;
    int columns = width < 600 ? 1 : (width < 1000 ? 2 : 3);

    return SizedBox(
      height: 400,
      child: GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisSpacing: 10,
          childAspectRatio: 1.2,
        ),
        itemCount: vm.pictures!.length,
        itemBuilder: (context, index) => PhotoCard(image: vm.pictures![index]),
      ),
    );
  }
}

class _ImageEditSection extends StatelessWidget {
  const _ImageEditSection();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ConfidentialDocumentViewmodel>();
    if (vm.imageFile == null) return const SizedBox.shrink();

    double screenWidth = MediaQuery.of(context).size.width;
    bool isLarge = screenWidth > 800;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Image.memory(
            vm.imageFile!,
            width: isLarge ? screenWidth * 0.7 : screenWidth * 0.9,
            height: isLarge ? 400 : 250,
            fit: BoxFit.scaleDown,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: vm.titleController,
            decoration: InputDecoration(
              labelText: "Titre du document",
              border: const OutlineInputBorder(),
              errorText: vm.titleError,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  // Réutiliser la même logique de mot de passe ici
                  await vm.saveImage();
                },
                icon: const Icon(Icons.save),
                label: const Text("Enregistrer"),
              ),
              const SizedBox(width: 10),
              TextButton.icon(
                onPressed: vm.cancelImageFile,
                icon: const Icon(Icons.clear),
                label: const Text("Quitter"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}