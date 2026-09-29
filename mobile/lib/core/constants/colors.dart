import 'package:flutter/material.dart';

/// TechSOS Official Design System Colors
class TechSosColors {
  TechSosColors._();

  /// Bleu nuit / Indigo (Couleur d'identité et de structure)
  static const Color primary = Color(0xFF1F3A5F);

  /// Orange technique (Urgence / Action principale / CTA)
  static const Color accent = Color(0xFFE8641C);

  /// Vert (Succès / Réparation terminée)
  static const Color success = Color(0xFF2E8B57);

  /// Ambre (Alerte / Panne en attente)
  static const Color alert = Color(0xFFD9A441);

  /// Blanc cassé (Fond d'écran - mode clair)
  static const Color background = Color(0xFFF7F8FA);

  /// Blanc pur (Fond de carte - mode clair)
  static const Color cardBackground = Colors.white;

  /// Gris anthracite (Texte principal - mode clair)
  static const Color textPrimary = Color(0xFF1A1A1A);

  /// Gris moyen (Texte secondaire - mode clair)
  static const Color textSecondary = Color(0xFF595959);

  /// Bordure standard (mode clair)
  static const Color border = Color(0xFFE2E8F0);

  // ── Palette Thème Sombre (Dark Mode) ──

  /// Fond d'écran bleu nuit profond (mode sombre)
  static const Color backgroundDark = Color(0xFF0F172A);

  /// Fond de carte ardoise foncée (mode sombre)
  static const Color cardBackgroundDark = Color(0xFF1E293B);

  /// Couleur d'AppBar en mode sombre
  static const Color appBarDark = Color(0xFF0D1B2A);

  /// Texte principal clair (mode sombre)
  static const Color textPrimaryDark = Color(0xFFF8FAFC);

  /// Texte secondaire atténué (mode sombre)
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  /// Bordure subtile (mode sombre)
  static const Color borderDark = Color(0xFF334155);
}
