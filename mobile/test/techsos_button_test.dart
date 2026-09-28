import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tech_sos/core/widgets/techsos_button.dart';

void main() {
  group('TechSosButton Widget Tests', () {
    testWidgets('renders primary button with label and calls onPressed',
        (WidgetTester tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TechSosButton(
              label: 'Continuer',
              onPressed: () {
                pressed = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Continuer'), findsOneWidget);
      await tester.tap(find.text('Continuer'));
      await tester.pump();

      expect(pressed, isTrue);
    });

    testWidgets('renders secondary button with border and primary text color',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TechSosButton(
              label: 'Annuler',
              isSecondary: true,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Annuler'), findsOneWidget);
      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('shows CircularProgressIndicator when isLoading is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TechSosButton(
              label: 'Chargement...',
              isLoading: true,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Chargement...'), findsNothing);
    });
  });
}
