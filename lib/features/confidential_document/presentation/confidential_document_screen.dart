import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:leodys/common/theme/theme_context_extension.dart';
import 'package:leodys/features/confidential_document/presentation/utils/no_accents_input_formater.dart';
import 'package:provider/provider.dart';

import 'confidential_document_viewmodel.dart';

class ConfidentialDocumentScreen extends StatelessWidget {
  static const String route = '/document_confidentiel';
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
          //LISTENER UI (SnackBars)
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;

            //TODO ajout de paramètres pour ne pas être caché par le bouton de paramètre
            if (vm.infoSaveImg != null) {
              _showCustomSnackBar(context, vm.infoSaveImg!);
              // ScaffoldMessenger.of(
              //   context,
              // ).showSnackBar(SnackBar(
              //     elevation: 6.0,
              //     behavior: SnackBarBehavior.floating,
              //     content: Text(vm.infoSaveImg!)));
              vm.clearInfoSave();
            }

            if (vm.alerteSync != null) {
              _showCustomSnackBar(context, vm.alerteSync!);
              // ScaffoldMessenger.of(
              //   context,
              // ).showSnackBar(SnackBar(content: Text(vm.alerteSync!)));
              vm.clearAlerte();
            }
            if (vm.infoDeleteImg != null) {
              _showCustomSnackBar(context, vm.infoDeleteImg!);
              // ScaffoldMessenger.of(
              //   context,
              // ).showSnackBar(SnackBar(content: Text(vm.infoDeleteImg!)));
              vm.clearInfoDelete();
            }
          });

          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ActionButtons(),
                _NewImage(),
                _ShowGallery(),
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

  void _showCustomSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(left: 15, right: 15, bottom: 80),
        content: Text(message, selectionColor:  context.colorScheme.primary,),
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
    // On utilise watch pour que le widget se redessine quand isLoading ou hasConnection changent
    final vm = context.watch<ConfidentialDocumentViewmodel>();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        spacing: 12, // Un peu plus d'espace pour respirer
        runSpacing: 10, // Espace entre les lignes si le Wrap passe à la ligne
        alignment: WrapAlignment.center,
        children: [
          // --- BOUTON SYNCHRONISATION (Nouveau) ---
          ElevatedButton.icon(
            onPressed: (vm.isLoading || !vm.hasConnection)
                ? null
                : () => vm.sync(),
            style: _buttonStyle(context.colorScheme.surfaceContainerHighest, context.colorScheme.primary),
            icon: vm.isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync),
            label: const Text("Synchro"),
          ),

          // --- BOUTON PHOTO ---
          if (!kIsWeb)
            ElevatedButton.icon(
              onPressed: vm.isLoading ? null : vm.takePicture,
              style: _buttonStyle(context.colorScheme.surfaceContainerHighest, context.colorScheme.primary),
              icon: const Icon(Icons.camera_alt),
              label: const Text("Photo"),
            ),

          // --- BOUTON TÉLÉCHARGER ---
          ElevatedButton.icon(
            onPressed: vm.isLoading ? null : vm.getPicture,
            style: _buttonStyle(context.colorScheme.surfaceContainerHighest, context.colorScheme.primary),
            icon: const Icon(Icons.file_upload),
            label: const Text("Télécharger"),
          ),

          // --- BOUTON GALERIE ---
          ElevatedButton.icon(
            onPressed: vm.isLoading
                ? null
                : () async => _handleGalleryAccess(context, vm),
            style: _buttonStyle(context.colorScheme.surfaceContainerHighest, context.colorScheme.primary),
            icon: const Icon(Icons.collections),
            label: const Text("Ma Galerie"),
          ),
        ],
      ),
    );
  }

  // --- STYLE GÉNÉRIQUE POUR LA COHÉRENCE ---
  ButtonStyle _buttonStyle(Color color, Color font) {
    return ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: font,
      side: BorderSide(
        color: font, // Ou une autre couleur de votre choix
        width: 1.5,   // L'épaisseur de la bordure
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    );
  }

  // --- LOGIQUE EXTRAITE (Plus lisible) ---
  Future<void> _handleGalleryAccess(
    BuildContext context,
    ConfidentialDocumentViewmodel vm,
  ) async {
    if (vm.session.isLocked) {
      final String? password = await showDialog<String>(
        context: context,
        builder: (context) => const _Alerte(),
      );

      if (password == null || password.isEmpty) return;
      bool success = await vm.saveKey(password);
      if (!success) return;
    }

    if (!vm.session.isLocked) {
      vm.maskGallery(false);
      await vm.getAllPicture();
    }
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
        // Preview de l'image sélectionnée (si présente)
        if (vm.imageFile != null)
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                SizedBox(
                  child: ClipRRect(
                    // Optionnel: bords arrondis pour le style
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(vm.imageFile!, fit: BoxFit.scaleDown),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
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
          inputFormatters: [
            NoAccentsInputFormatter(), // Applique le filtre
          ],
        ),
        ElevatedButton.icon(
          onPressed: vm.isSaving
              ? null
              : () async {
                  if (vm.session.isLocked) {
                    final String? password = await showDialog<String>(
                      context: context,
                      builder: (context) => const _Alerte(),
                    );
                    if (password != null && password.isNotEmpty) {
                      bool success = await vm.saveKey(password);
                      if (!success) return;
                    } else {
                      return;
                    }
                  }
                  await vm.saveImage();
                },
          icon: vm.isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save),
          label: Text(vm.isSaving ? "Enregistrement..." : "Enregistrer"),
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
    double width = MediaQuery.of(context).size.width;
    int columns;
    if (width < 600) {
      columns = 1; // Téléphone
    } else if (width < 1000) {
      columns = 2; // Tablette / Medium
    } else {
      columns = 3; // Grand écran / Web
    }
    final vm = context.watch<ConfidentialDocumentViewmodel>();
    double screenWidth = MediaQuery.of(context).size.width;
    bool isLargerScreen = screenWidth > 800;
    if (vm.hideGallery) return const SizedBox.shrink();
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
            height: 600,
            child: GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisSpacing: 10,
                childAspectRatio: 1.5,
              ),
              itemCount: vm.pictures!.length,
              itemBuilder: (context, index) {
                return Card(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: context.colorScheme.primary, // La couleur de la bordure
                      width: 1.0,         // L'épaisseur
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onDoubleTap: () {
                          showDialog(
                            context: context,
                            barrierColor: Colors.red,
                            builder: (_) => GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Dialog(
                                backgroundColor: Colors.transparent,
                                insetPadding: EdgeInsets.zero,
                                child: InteractiveViewer(
                                  child: Image.memory(
                                    vm.pictures![index].byte,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        child: SizedBox(
                          width: double.infinity,
                          height: 180,
                          child: Image.memory(
                            vm.pictures![index].byte,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                                child: Text(
                                  vm.pictures![index].title,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: context.colorScheme.primary,),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                                    contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                                    actionsPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    buttonPadding: EdgeInsets.zero,
                                    insetPadding: const EdgeInsets.all(24),
                                    title: const Text("Suppression"),
                                    content: Text(
                                      'Etes-vous sûr de vouloir supprimer ${vm.pictures![index].title} ?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Annuler'),
                                      ),
                                      TextButton(
                                        style : TextButton.styleFrom(backgroundColor: context.colorScheme.primaryContainer,
                                          foregroundColor: context.colorScheme.onPrimary, ),
                                        onPressed: () {
                                          vm.deletePicture(vm.pictures![index].title);
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Oui'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          )
        else if (!vm
            .lookingForPicture) // On affiche "aucun" seulement si on ne charge pas
          const SizedBox(
            height: 200,
            child: Center(child: Text("Aucun fichier enregistré")),
          ),
      ],
    );
  }
}
