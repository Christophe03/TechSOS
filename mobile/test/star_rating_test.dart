import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tech_sos/core/widgets/star_rating.dart';

void main() {
  group('StarRating Widget Tests', () {
    testWidgets('renders 5 stars', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StarRating(rating: 3.0),
          ),
        ),
      );

      final iconFinder = find.byType(Icon);
      expect(iconFinder, findsNWidgets(5));
    });

    testWidgets('interactive StarRating triggers onRatingChanged on tap',
        (WidgetTester tester) async {
      int? selectedRating;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StarRating(
              rating: 2.0,
              isInteractive: true,
              onRatingChanged: (rating) {
                selectedRating = rating;
              },
            ),
          ),
        ),
      );

      final fourthStarFinder = find.byKey(const ValueKey('star_3'));
      expect(fourthStarFinder, findsOneWidget);

      await tester.tap(fourthStarFinder);
      await tester.pump();

      expect(selectedRating, 4);
    });
  });
}
