import 'package:Leodys/utils/internet_util.dart';
import 'package:Leodys/utils/platform_util.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:url_launcher/url_launcher.dart';

/// Page d'accueil
class HomePage extends StatefulWidget {
  static const route = '/home';
  final String? email;

  const HomePage({super.key, this.email});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //final AuthentificationService _authService = AuthentificationService();



  static final List<Widget> _widgetOptions = <Widget>[

    const Center(),


  ];


  List data = [
    {
      "name": "Lequipe",
      "url": "https://lequipe.fr",
      "icon": Icons.web,
      "checkInternet": true, // Vérification nécessaire
    },
    {
      "name": "Agenda",
      "url": "content://com.android.calendar/time/",
      "icon": Icons.calendar_month,
      "checkInternet": false,
    },
    {
      "name": "Email",
      "url": "mailto:contact@greta.fr",
      "icon": Icons.email,
      "checkInternet": true, // Vérification nécessaire
    },
    {
      "name": "Telephone",
      "url": "tel:0512234534",
      "icon": Icons.phone,
      "checkInternet": false,
    },
    {
      "name": "SMS",
      "url": "sms:0750101234",
      "icon": Icons.sms,
      "checkInternet": false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        title: buildTitleText("Leadys - Bienvenue ${widget.email ?? ''}"),
      ),
      body: Center(
          child: ListView(
            children: data.map((item) {
              return Card(
                child: ListTile(
                  onTap: () => _launchURL(item['url'], item['checkInternet'] ?? false),
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey.shade100,

                    child: Icon(
                      item['icon'],
                      color: item['color'],
                      size: 25,
                    ),
                  ),
                  title: Text(
                    item['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  subtitle: Text(item['url']),
                  onLongPress: () => _launchURL(item['url'], item['checkInternet'] ?? false),

                ),
              );
            }).toList(),
          )),
      drawer: buildDrawer(),
    );
  }

  Drawer buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue[800],
            ),
            child: const Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            title: const Text('Mon Compte'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, "/mon_compte");

            },
          ),
          ListTile(
            title: const Text('Messagerie'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, "/messagerie");

            },
          ),
          ListTile(
            title: const Text('Agenda'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, "/agenda");
            },
          ),
          ListTile(
            title: const Text('Déconnexion'),
            onTap: () async{
              //await _authService.logout();
              //Navigator.pushReplacementNamed(context, '/login');

            },
          ),

          if (PlatformUtil.isAndroid)
            ListTile(
              leading: const Icon(Icons.map),
              title: StreamBuilder<InternetConnectionStatus>(
                initialData: InternetUtil.lastKnownStatus,
                stream: InternetUtil.onStatusChange,
                builder: (context, snapshot){
                  final isOnline = snapshot.data == InternetConnectionStatus.connected;
                  return Text(isOnline ? 'Carte (En ligne)' : 'Carte (Mode hors-ligne)');
                },
              ),
              onTap: () async{
                Navigator.pop(context);
                Navigator.pushNamed(context, "");
              },
            ),
        ],
      ),
    );
  }

  /// Méthode pour lancer les URLs avec vérification Internet
  void _launchURL(String url, bool needsInternet) async {
    // Vérifier la connexion Internet si nécessaire
    if (needsInternet) {
      bool hasInternet = InternetUtil.isConnected;
      if (!hasInternet) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Problème de connexion Internet.'),
            backgroundColor: Colors.red,
          ),
        );
        return; // Arrête l'exécution
      }
    }

    try {
      await launchUrl(Uri.parse(url));
    } catch (e) {
      debugPrint(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du lancement: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Méthode pour créer le titre
  Widget buildTitleText(text) => Center(child: Text(text));
}
