import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_refined_kit/ui/spring_segmented_control.dart';

void main() {
  group('SpringSegmentedControl<T>', () {
    testWidgets('renders a label per item', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SpringSegmentedControl<String>(
              items: const ['Day', 'Week', 'Month'],
              selectedItem: 'Week',
              labelBuilder: (item) => item,
              onSelected: (_) {},
              trackColor: Colors.grey.shade200,
              trackBorderColor: Colors.grey,
              selectedPillColor: Colors.blue,
              selectedTextColor: Colors.white,
              unselectedTextColor: Colors.black,
            ),
          ),
        ),
      );

      expect(find.text('Day'), findsOneWidget);
      expect(find.text('Week'), findsOneWidget);
      expect(find.text('Month'), findsOneWidget);
    });

    testWidgets('tapping a segment calls onSelected with that item', (tester) async {
      String? selected;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SpringSegmentedControl<String>(
              items: const ['Day', 'Week', 'Month'],
              selectedItem: 'Week',
              labelBuilder: (item) => item,
              onSelected: (item) => selected = item,
              trackColor: Colors.grey.shade200,
              trackBorderColor: Colors.grey,
              selectedPillColor: Colors.blue,
              selectedTextColor: Colors.white,
              unselectedTextColor: Colors.black,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Month'));
      await tester.pump();

      expect(selected, equals('Month'));
    });

    testWidgets('a single-item list does not throw a division by zero', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SpringSegmentedControl<String>(
              items: const ['Only'],
              selectedItem: 'Only',
              labelBuilder: (item) => item,
              onSelected: (_) {},
              trackColor: Colors.grey.shade200,
              trackBorderColor: Colors.grey,
              selectedPillColor: Colors.blue,
              selectedTextColor: Colors.white,
              unselectedTextColor: Colors.black,
            ),
          ),
        ),
      );

      expect(find.text('Only'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('an empty item list renders without throwing', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SpringSegmentedControl<String>(
              items: const [],
              selectedItem: 'anything',
              labelBuilder: (item) => item,
              onSelected: (_) {},
              trackColor: Colors.grey.shade200,
              trackBorderColor: Colors.grey,
              selectedPillColor: Colors.blue,
              selectedTextColor: Colors.white,
              unselectedTextColor: Colors.black,
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
