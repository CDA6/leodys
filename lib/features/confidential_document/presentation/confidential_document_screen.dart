import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:leodys/features/confidential_document/presentation/widget/photo_card.dart';
import 'package:provider/provider.dart';

import '../domain/entity/picture_download.dart';
import 'confidential_document_viewmodel.dart';

class ConfidentialDocumentScreen extends StatelessWidget {
  const ConfidentialDocumentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ConfidentialDocumentViewmodel()..i65nit(),
      child: _ConfidentialDocumentContent(),
    );
  }
}

class _ConfidentialDocumentContent extends StatelessWidget {
  const _ConfidentialDocumentContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Document confidentiel")),
      body: Consumer<ConfidentialDocumentViewmodel>(
        builder: (context, vm, child) {
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ActionButtons(),
                _ShowGallery(),
                _NewImage(),
                if (vm.emailUser != null)
                  Text("Connecté avec : ${vm.emailUser}")
                else
                  const Text("Utilisateur non détecté"),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Alerte extends StatefulWidget {
  const _Alerte();

  @override
  State<_Alerte> createState() => _AlerteState();
}

class _AlerteState extends State<_Alerte> {
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose(); // Toujours libérer le controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sécuriser l\'image'),
      content: TextField(
        controller: _passwordController,
        obscureText: true,
        decoration: const InputDecoration(labelText: 'Mot de passe'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null), // Annuler
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(
            context,
            _passwordController.text,
          ), // Envoyer le texte
          child: const Text('Confirmer'),
        ),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = context.read<ConfidentialDocumentViewmodel>();
    return Wrap(
      spacing: 10,
      children: [
        if (!kIsWeb)
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.camera_alt),
            label: const Text(
              "Prendre une photo",
            ), //TODO à developper après téléchargement
          ),
        ElevatedButton.icon(
          onPressed: vm.getPicture,
          icon: const Icon(Icons.file_upload),
          label: const Text("Télécharger"),
        ),
        ElevatedButton.icon(
          onPressed: () async {
            if (vm.session.isLocked) {
              final String? password = await showDialog<String>(
                context: context,
                builder: (context) => const _Alerte(),
              );

              if (password != null && password.isNotEmpty) {
                bool success = await vm.saveKey(password);
                if (!success) {
                  // Gérer l'erreur si la génération échoue
                  return;
                }
              } else {
                return; // L'utilisateur a annulé
              }
            }
            if (!vm.session.isLocked) {
              vm.maskGallery(false);
              await vm.getAllPicture();
              if (vm.errorCount > 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${vm.errorCount} sont impossible à charger'),
                  ),
                );
              }
            }
          },
          icon: const Icon(Icons.picture_in_picture),
          label: const Text("Voir ma galerie"),
        ),
      ],
    );
  }
}

class _NewImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = context.read<ConfidentialDocumentViewmodel>();
    if (vm.imageFile == null) return const SizedBox.shrink();
    return Wrap(
      spacing: 10,
      children: [
        TextField(
          controller: vm.titleController,
          decoration: InputDecoration(
            labelText: "Titre du document",
            hintText: "Ex: Carte_ID",
            border: const OutlineInputBorder(),
            errorText: vm.titleError,
            focusedErrorBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
            ),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () async {
            if (vm.session.isLocked) {
              final String? password = await showDialog<String>(
                context: context,
                builder: (context) => const _Alerte(),
              );
              if (password != null && password.isNotEmpty) {
                bool success = await vm.saveKey(password);
                if (!success) {
                  // Gérer l'erreur si la génération échoue
                  return;
                }
              } else {
                return; // L'utilisateur a annulé
              }
            }
            if (!vm.session.isLocked) {
              await vm.saveImage();
            }
          },
          icon: const Icon(Icons.save),
          label: const Text("Enregistrer"),
        ),
        ElevatedButton.icon(
          onPressed: vm.cancelImageFile,
          icon: const Icon(Icons.clear),
          label: const Text("Quitter"),
        ),
      ],
    );
  }
}

class _ShowGallery extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ConfidentialDocumentViewmodel>();
    double screenWidth = MediaQuery.of(context).size.width;
    bool isLargerScreen = screenWidth > 800;
    if(vm.hideGallery) return const SizedBox.shrink();
    return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (vm.lookingForPicture)
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            ),
          // Affichage de la galerie
          if (vm.pictures != null && vm.pictures!.isNotEmpty)
            SizedBox(
              height: 400,
              child: _buildGallery(context, vm.pictures!), // Appel de ta méthode de grille
            )
          else if (!vm.lookingForPicture) // On affiche "aucun" seulement si on ne charge pas
            const SizedBox(
              height: 400,
              child: Center(child: Text("Aucun fichier enregistré")),
            ),

          // Preview de l'image sélectionnée (si présente)
          if (vm.imageFile != null)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  SizedBox(
                    width: isLargerScreen ? screenWidth * 0.7 : screenWidth * 0.9,
                    height: isLargerScreen ? 400 : 250,
                    child: ClipRRect( // Optionnel: bords arrondis pour le style
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        vm.imageFile!,
                        fit: BoxFit.scaleDown,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ]
    );
  }

  //TODO widget afficher galerie d'image
  Widget _buildGallery(BuildContext context, List<PictureDownload> pictures) {
    double width = MediaQuery.of(context).size.width;

    // 2. On définit le nombre de colonnes selon la largeur
    int columns;
    if (width < 600) {
      columns = 1; // Téléphone
    } else if (width < 1000) {
      columns = 2; // Tablette / Medium
    } else {
      columns = 3; // Grand écran / Web
    }
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      // shrinkWrap: true, // IMPORTANT : permet au GridView de ne prendre que l'espace nécessaire
      // physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 10,
        childAspectRatio: 1.2,
      ),
      itemCount: pictures.length,
      itemBuilder: (context, index) {
        return PhotoCard(image: pictures[index]);
      },
    );
  }
}
