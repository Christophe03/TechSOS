import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tech_sos/features/auth/models/user_model.dart';
import 'package:tech_sos/features/auth/providers/auth_provider.dart';
import 'package:tech_sos/features/settings/providers/settings_provider.dart';
import 'package:tech_sos/features/settings/screens/settings_screen.dart';

class _FakeAuthNotifier extends StateNotifier<AuthState> implements AuthNotifier {
  _FakeAuthNotifier(UserModel user)
      : super(AuthState(isAuthenticated: true, user: user, isLoading: false));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<void> logout() async {
    state = AuthState.unauthenticated();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const mockClientUser = UserModel(
    id: 'user-client-1',
    phone: '+22370000001',
    fullName: 'Mamadou Diarra',
    role: 'CLIENT',
    city: 'Bamako',
  );

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'techsos_notif_push': true,
      'techsos_notif_messages': true,
      'techsos_theme': 'light',
      'techsos_data_temp_1': 'cached_info',
    });
  });

  group('SettingsNotifier Unit Tests', () {
    test('init loads saved values from SharedPreferences', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(settingsProvider.notifier);
      await notifier.init();

      final state = container.read(settingsProvider);
      expect(state.notifPush, isTrue);
      expect(state.notifMessages, isTrue);
      expect(state.theme, equals('light'));
      expect(state.langue, equals('Français'));
      expect(state.devise, equals('FCFA'));
    });

    test('toggles update state correctly', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(settingsProvider.notifier);
      await notifier.init();

      await notifier.setNotifPush(false);
      expect(container.read(settingsProvider).notifPush, isFalse);

      await notifier.setNotifPromos(true);
      expect(container.read(settingsProvider).notifPromos, isTrue);

      await notifier.setDataSaver(true);
      expect(container.read(settingsProvider).dataSaver, isTrue);
    });

    test('clearCache removes only techsos_data_ keys', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(settingsProvider.notifier);
      await notifier.init();
      await notifier.clearCache();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey('techsos_data_temp_1'), isFalse);
      expect(prefs.containsKey('techsos_notif_push'), isTrue);
    });
  });

  group('SettingsScreen Widget Tests', () {
    testWidgets('renders all major sections and client information', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith((ref) => _FakeAuthNotifier(mockClientUser)),
          ],
          child: const MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Paramètres'), findsOneWidget);
      expect(find.text('Mamadou Diarra'), findsOneWidget);
      expect(find.text('Compte Client Bamako'), findsOneWidget);

      expect(find.text('MON COMPTE'), findsOneWidget);
      expect(find.text('NOTIFICATIONS'), findsOneWidget);
      expect(find.text('APPARENCE'), findsOneWidget);
      expect(find.text('LANGUE ET PRÉFÉRENCES'), findsOneWidget);
      expect(find.text('SÉCURITÉ ET CONFIDENTIALITÉ'), findsOneWidget);
      expect(find.text('DONNÉES ET STOCKAGE'), findsOneWidget);
      expect(find.text('AIDE ET SUPPORT'), findsOneWidget);
      expect(find.text('À PROPOS'), findsOneWidget);
      expect(find.text('GESTION DU COMPTE'), findsOneWidget);

      expect(find.text('Se déconnecter'), findsOneWidget);
      expect(find.text('Supprimer mon compte définitivement'), findsOneWidget);
    });

    testWidgets('shows confirmation dialog on logout button click', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith((ref) => _FakeAuthNotifier(mockClientUser)),
          ],
          child: const MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final logoutButton = find.text('Se déconnecter');
      await tester.ensureVisible(logoutButton);
      await tester.tap(logoutButton);
      await tester.pumpAndSettle();

      expect(find.text('Se déconnecter ?'), findsOneWidget);
      expect(find.text('Annuler'), findsOneWidget);
      expect(find.text('Déconnexion'), findsOneWidget);

      // Annuler
      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();
      expect(find.text('Se déconnecter ?'), findsNothing);
    });

    testWidgets('shows confirmation dialog on delete account click', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith((ref) => _FakeAuthNotifier(mockClientUser)),
          ],
          child: const MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final deleteButton = find.text('Supprimer mon compte définitivement');
      await tester.ensureVisible(deleteButton);
      await tester.tap(deleteButton);
      await tester.pumpAndSettle();

      expect(find.text('Supprimer mon compte ?'), findsOneWidget);
      expect(find.text('Confirmer la suppression'), findsOneWidget);

      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();
      expect(find.text('Supprimer mon compte ?'), findsNothing);
    });
  });
}
