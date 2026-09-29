import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// État des paramètres et préférences de l'application TechSOS
class SettingsState {
  final bool notifPush;
  final bool notifMessages;
  final bool notifActualites;
  final bool notifRappels;
  final bool notifPromos;
  final String theme; // 'light' | 'dark' | 'auto'
  final String langue;
  final String devise;
  final bool dataSaver;
  final bool autoSync;
  final bool biometricsEnabled;
  final bool isLoading;

  const SettingsState({
    this.notifPush = true,
    this.notifMessages = true,
    this.notifActualites = false,
    this.notifRappels = true,
    this.notifPromos = false,
    this.theme = 'light',
    this.langue = 'Français',
    this.devise = 'FCFA',
    this.dataSaver = false,
    this.autoSync = true,
    this.biometricsEnabled = false,
    this.isLoading = false,
  });

  SettingsState copyWith({
    bool? notifPush,
    bool? notifMessages,
    bool? notifActualites,
    bool? notifRappels,
    bool? notifPromos,
    String? theme,
    String? langue,
    String? devise,
    bool? dataSaver,
    bool? autoSync,
    bool? biometricsEnabled,
    bool? isLoading,
  }) {
    return SettingsState(
      notifPush: notifPush ?? this.notifPush,
      notifMessages: notifMessages ?? this.notifMessages,
      notifActualites: notifActualites ?? this.notifActualites,
      notifRappels: notifRappels ?? this.notifRappels,
      notifPromos: notifPromos ?? this.notifPromos,
      theme: theme ?? this.theme,
      langue: langue ?? this.langue,
      devise: devise ?? this.devise,
      dataSaver: dataSaver ?? this.dataSaver,
      autoSync: autoSync ?? this.autoSync,
      biometricsEnabled: biometricsEnabled ?? this.biometricsEnabled,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Gestionnaire des paramètres persisté via SharedPreferences
class SettingsNotifier extends StateNotifier<SettingsState> {
  static const _push = 'techsos_notif_push';
  static const _messages = 'techsos_notif_messages';
  static const _actualites = 'techsos_notif_actualites';
  static const _rappels = 'techsos_notif_rappels';
  static const _promos = 'techsos_notif_promos';
  static const _theme = 'techsos_theme';
  static const _langue = 'techsos_langue';
  static const _devise = 'techsos_devise';
  static const _dataSaver = 'techsos_data_saver';
  static const _autoSync = 'techsos_auto_sync';
  static const _biometrics = 'techsos_biometrics';

  SettingsNotifier() : super(const SettingsState());

  /// Charge les préférences depuis le stockage local
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    state = state.copyWith(
      notifPush: prefs.getBool(_push) ?? true,
      notifMessages: prefs.getBool(_messages) ?? true,
      notifActualites: prefs.getBool(_actualites) ?? false,
      notifRappels: prefs.getBool(_rappels) ?? true,
      notifPromos: prefs.getBool(_promos) ?? false,
      theme: prefs.getString(_theme) ?? 'light',
      langue: prefs.getString(_langue) ?? 'Français',
      devise: prefs.getString(_devise) ?? 'FCFA',
      dataSaver: prefs.getBool(_dataSaver) ?? false,
      autoSync: prefs.getBool(_autoSync) ?? true,
      biometricsEnabled: prefs.getBool(_biometrics) ?? false,
    );
  }

  Future<void> setNotifPush(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_push, v);
    state = state.copyWith(notifPush: v);
  }

  Future<void> setNotifMessages(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_messages, v);
    state = state.copyWith(notifMessages: v);
  }

  Future<void> setNotifActualites(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_actualites, v);
    state = state.copyWith(notifActualites: v);
  }

  Future<void> setNotifRappels(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rappels, v);
    state = state.copyWith(notifRappels: v);
  }

  Future<void> setNotifPromos(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_promos, v);
    state = state.copyWith(notifPromos: v);
  }

  Future<void> setTheme(String t) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_theme, t);
    state = state.copyWith(theme: t);
  }

  Future<void> setDataSaver(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dataSaver, v);
    state = state.copyWith(dataSaver: v);
  }

  Future<void> setAutoSync(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoSync, v);
    state = state.copyWith(autoSync: v);
  }

  Future<void> setBiometrics(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometrics, v);
    state = state.copyWith(biometricsEnabled: v);
  }

  /// Vide uniquement les clés de données temporaires (préfixe techsos_data_)
  Future<void> clearCache() async {
    state = state.copyWith(isLoading: true);
    final prefs = await SharedPreferences.getInstance();
    final keys =
        prefs.getKeys().where((k) => k.startsWith('techsos_data_')).toList();
    for (final k in keys) {
      await prefs.remove(k);
    }
    state = state.copyWith(isLoading: false);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) => SettingsNotifier(),
);
