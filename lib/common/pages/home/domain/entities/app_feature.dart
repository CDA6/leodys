import 'package:flutter/material.dart';

class AppFeature {

  final String name;
  final IconData icon;
  final String route;
  final bool requiresInternet;
  final bool requiresAuth;
  final bool isAvailable;
  final String? description;

  const AppFeature({
    required this.name,
    required this.icon,
    required this.route,
    this.requiresInternet = false,
    this.requiresAuth = false,
    this.isAvailable = true,
    this.description,
  });

  /// Vérifie si la fonctionnalité peut être utilisée dans le contexte actuel.
  ///
  /// [isConnected] Indique si l'appareil a une connexion Internet.
  /// [isAuthenticated] Indique si l'utilisateur est authentifié.
  ///
  /// Retourne `true` si tous les prérequis sont remplis.
  bool canBeUsed({required bool isConnected, required bool isAuthenticated}) {
    if (!isAvailable) return false;
    if (requiresInternet && !isConnected) return false;
    if (requiresAuth && !isAuthenticated) return false;
    return true;
  }
}