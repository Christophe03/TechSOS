import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tech_sos/core/constants/colors.dart';
import 'package:tech_sos/core/widgets/status_badge.dart';

void main() {
  group('StatusBadge Widget Tests', () {
    testWidgets('displays "En attente" with amber color for PENDING',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(status: 'PENDING'),
          ),
        ),
      );

      final labelFinder = find.text('En attente');
      expect(labelFinder, findsOneWidget);

      final textWidget = tester.widget<Text>(labelFinder);
      expect(textWidget.style?.color, TechSosColors.alert);
    });

    testWidgets('displays "Prise en charge" with orange color for IN_PROGRESS',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(status: 'IN_PROGRESS'),
          ),
        ),
      );

      final labelFinder = find.text('Prise en charge');
      expect(labelFinder, findsOneWidget);

      final textWidget = tester.widget<Text>(labelFinder);
      expect(textWidget.style?.color, TechSosColors.accent);
    });

    testWidgets('displays "Terminée" with green color for COMPLETED',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(status: 'COMPLETED'),
          ),
        ),
      );

      final labelFinder = find.text('Terminée');
      expect(labelFinder, findsOneWidget);

      final textWidget = tester.widget<Text>(labelFinder);
      expect(textWidget.style?.color, TechSosColors.success);
    });
  });
}
