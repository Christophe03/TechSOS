import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tech_sos/core/theme/app_theme.dart';
import 'package:tech_sos/features/auth/screens/login_screen.dart';
import 'package:tech_sos/features/auth/screens/register_client_screen.dart';
import 'package:tech_sos/features/auth/screens/register_provider_screen.dart';
import 'package:tech_sos/features/auth/screens/role_selection_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestableWidget(Widget child) {
    return ProviderScope(
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: child,
      ),
    );
  }

  group('Auth Screens UI Tests', () {
    testWidgets('RoleSelectionScreen renders branding, options and login link',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const RoleSelectionScreen()));

      expect(find.text('Bienvenue sur TechSOS'), findsOneWidget);
      expect(
        find.text('La solution d\'urgence pour vos appareils en panne à Bamako'),
        findsOneWidget,
      );
      expect(find.text('J\'ai un appareil en panne'), findsOneWidget);
      expect(find.text('Mode Client'), findsOneWidget);
      expect(find.text('Je suis réparateur / atelier'), findsOneWidget);
      expect(find.text('Mode Prestataire'), findsOneWidget);
      expect(find.text('Se connecter'), findsOneWidget);
    });

    testWidgets('LoginScreen renders fields and submission button',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const LoginScreen()));

      expect(find.text('Connexion'), findsOneWidget);
      expect(find.text('Numéro de téléphone ou Email'), findsOneWidget);
      expect(find.text('Mot de passe'), findsOneWidget);
      expect(find.text('Se connecter'), findsOneWidget);
      expect(find.text('S\'inscrire'), findsOneWidget);
    });

    testWidgets('RegisterClientScreen renders client registration form',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const RegisterClientScreen()));

      expect(find.text('Créer un compte Client'), findsOneWidget);
      expect(find.text('Nom complet *'), findsOneWidget);
      expect(find.text('Numéro de téléphone (+223...) *'), findsOneWidget);
      expect(find.text('Quartier / Zone à Bamako *'), findsOneWidget);
      expect(find.text('Créer mon compte Client'), findsOneWidget);
    });

    testWidgets('RegisterProviderScreen renders provider workshop form',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const RegisterProviderScreen()));

      expect(find.text('Inscription Réparateur'), findsOneWidget);
      expect(find.text('Nom et Prénom du gérant *'), findsOneWidget);
      expect(find.text('Nom de l\'atelier ou boutique *'), findsOneWidget);
      expect(find.text('Quartier à Bamako *'), findsOneWidget);
      expect(find.text('Inscrire mon atelier'), findsOneWidget);
    });
  });
}
