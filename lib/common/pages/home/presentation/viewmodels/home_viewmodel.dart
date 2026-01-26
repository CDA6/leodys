import 'dart:async';

import 'package:flutter/material.dart';
import 'package:leodys/common/mixins/connectivity_mixin.dart';
import '../../domain/entities/app_feature.dart';

/// ViewModel gérant l'état de la page d'accueil.
///
/// Responsabilités :
/// - Déterminer si une feature est accessible selon le contexte
class HomeViewModel extends ChangeNotifier with ConnectivityMixin {
  bool _isAuthenticated = false;
  bool _isCheckingConnectivity = true;

  bool get isConnected => hasConnection;
  bool get isAuthenticated => _isAuthenticated;
  bool get isCheckingConnectivity => _isCheckingConnectivity;

  HomeViewModel() {
    _initialize();
  }

  Future<void> _initialize() async {
    initConnectivity();
    _isCheckingConnectivity = false;

    // TODO: Vérifier l'authentification
    _isAuthenticated = false;
    notifyListeners();
  }

  /// Vérifie si une fonctionnalité peut être utilisée dans le contexte actuel.
  bool canUseFeature(AppFeature feature) {
    return feature.canBeUsed(
      isConnected: isConnected,
      isAuthenticated: _isAuthenticated,
    );
  }
}