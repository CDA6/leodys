import 'dart:async';

import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import '../utils/internet_util.dart';

mixin ConnectivityMixin on ChangeNotifier {
  bool _hasConnection = true;
  StreamSubscription<InternetConnectionStatus>? _connectivitySubscription;

  void initConnectivity() {
    _hasConnection = InternetUtil.isConnected;

    _connectivitySubscription = InternetUtil.onStatusChange.listen((status) {
      _hasConnection = status == InternetConnectionStatus.connected;
      notifyListeners();
    });
  }

  /// Retourne l'état actuel de la connexion
  bool get hasConnection => _hasConnection;

  /// Vérifie si la connexion est disponible
  bool checkConnection() => _hasConnection;

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}
