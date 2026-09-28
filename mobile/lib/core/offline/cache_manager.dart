import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Gestionnaire de persistance locale et de cache hors-ligne
class CacheManager {
  static const String _tokenKey = 'techsos_auth_token';
  static const String _userKey = 'techsos_auth_user';
  static const String _categoriesKey = 'techsos_cache_categories';
  static const String _prefixDataKey = 'techsos_data_';

  final SharedPreferences? _prefs;

  CacheManager([this._prefs]);

  Future<SharedPreferences> _getPrefs() async {
    return _prefs ?? await SharedPreferences.getInstance();
  }

  /// Sauvegarde du token JWT d'authentification
  Future<void> saveToken(String token) async {
    final prefs = await _getPrefs();
    await prefs.setString(_tokenKey, token);
  }

  /// Récupère le token JWT d'authentification actuel
  Future<String?> getToken() async {
    final prefs = await _getPrefs();
    return prefs.getString(_tokenKey);
  }

  /// Sauvegarde des informations du profil utilisateur
  Future<void> saveUser(Map<String, dynamic> userMap) async {
    final prefs = await _getPrefs();
    await prefs.setString(_userKey, jsonEncode(userMap));
  }

  /// Récupère les informations utilisateur enregistrées en cache
  Future<Map<String, dynamic>?> getUser() async {
    final prefs = await _getPrefs();
    final userJson = prefs.getString(_userKey);
    if (userJson == null) return null;
    try {
      final decoded = jsonDecode(userJson);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Sauvegarde de la liste des catégories d'appareils pour le mode hors-ligne
  Future<void> saveCategories(List<Map<String, dynamic>> categories) async {
    final prefs = await _getPrefs();
    await prefs.setString(_categoriesKey, jsonEncode(categories));
  }

  /// Récupère la liste des catégories d'appareils depuis le cache
  Future<List<Map<String, dynamic>>?> getCategories() async {
    final prefs = await _getPrefs();
    final categoriesJson = prefs.getString(_categoriesKey);
    if (categoriesJson == null) return null;
    try {
      final decoded = jsonDecode(categoriesJson);
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .toList();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Sauvegarde des données JSON arbitraires dans le cache
  Future<void> saveData(String key, dynamic data) async {
    final prefs = await _getPrefs();
    await prefs.setString('$_prefixDataKey$key', jsonEncode(data));
  }

  /// Récupère des données JSON arbitraires depuis le cache
  Future<dynamic> getData(String key) async {
    final prefs = await _getPrefs();
    final dataJson = prefs.getString('$_prefixDataKey$key');
    if (dataJson == null) return null;
    try {
      return jsonDecode(dataJson);
    } catch (_) {
      return null;
    }
  }

  /// Supprime tous les éléments du cache local (déconnexion)
  Future<void> clear() async {
    final prefs = await _getPrefs();
    await prefs.clear();
  }
}
