import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tech_sos/core/constants/colors.dart';
import 'package:tech_sos/core/theme/app_theme.dart';
import 'package:tech_sos/features/auth/models/user_model.dart';
import 'package:tech_sos/features/auth/providers/auth_provider.dart';
import 'package:tech_sos/features/settings/providers/settings_provider.dart';
import 'package:tech_sos/features/settings/screens/settings_screen.dart';

class _FakeAuthNotifier extends StateNotifier<AuthState> implements AuthNotifier {
  _FakeAuthNotifier()
      : super(const AuthState(
          isAuthenticated: true,
          user: UserModel(
            id: 'user-client-1',
            phone: '+22370000001',
            fullName: 'Mamadou Diarra',
            role: 'CLIENT',
            city: 'Bamako',
          ),
          isLoading: false,
        ));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<void> logout() async {
    state = AuthState.unauthenticated();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'techsos_theme': 'light',
    });
  });

  group('AppTheme Configuration Tests', () {
    test('lightTheme has light brightness and TechSos primary colors', () {
      final theme = AppTheme.lightTheme;
      expect(theme.brightness, equals(Brightness.light));
      expect(theme.scaffoldBackgroundColor, equals(TechSosColors.background));
      expect(theme.colorScheme.primary, equals(TechSosColors.primary));
      expect(theme.colorScheme.secondary, equals(TechSosColors.accent));
    });

    test('darkTheme has dark brightness and dark slate background', () {
      final theme = AppTheme.darkTheme;
      expect(theme.brightness, equals(Brightness.dark));
      expect(theme.scaffoldBackgroundColor, equals(TechSosColors.backgroundDark));
      expect(theme.colorScheme.surface, equals(TechSosColors.cardBackgroundDark));
      expect(theme.colorScheme.secondary, equals(TechSosColors.accent));
    });
  });

  group('Theme Switching in SettingsScreen Widget Tests', () {
    testWidgets('allows switching between Light, Dark, and Auto themes', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.light,
            home: const SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Vérifie que les 3 options sont présentes
      expect(find.text('Thème clair'), findsOneWidget);
      expect(find.text('Thème sombre'), findsOneWidget);
      expect(find.text('Thème automatique'), findsOneWidget);

      // Clic sur Thème sombre
      final darkOption = find.text('Thème sombre');
      await tester.ensureVisible(darkOption);
      await tester.tap(darkOption);
      await tester.pump();

      expect(container.read(settingsProvider).theme, equals('dark'));

      // Clic sur Thème automatique
      final autoOption = find.text('Thème automatique');
      await tester.ensureVisible(autoOption);
      await tester.tap(autoOption);
      await tester.pump();

      expect(container.read(settingsProvider).theme, equals('auto'));

      // Clic sur Thème clair
      final lightOption = find.text('Thème clair');
      await tester.ensureVisible(lightOption);
      await tester.tap(lightOption);
      await tester.pump();

      expect(container.read(settingsProvider).theme, equals('light'));
    });
  });
}
