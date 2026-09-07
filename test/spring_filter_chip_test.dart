import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_refined_kit/flutter_refined_kit.dart';

const _selectedDecoration = BoxDecoration(
  color: Colors.blue,
  borderRadius: BorderRadius.all(Radius.circular(999)),
);
const _unselectedDecoration = BoxDecoration(
  color: Colors.transparent,
  borderRadius: BorderRadius.all(Radius.circular(999)),
  border: Border.fromBorderSide(BorderSide(color: Colors.grey)),
);

void main() {
  group('SpringFilterChip', () {
    testWidgets('renders its label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SpringFilterChip(
              label: 'Action',
              isSelected: false,
              onTap: () {},
              selectedDecoration: _selectedDecoration,
              unselectedDecoration: _unselectedDecoration,
              selectedTextColor: Colors.white,
              unselectedTextColor: Colors.black,
            ),
          ),
        ),
      );

      expect(find.text('Action'), findsOneWidget);
    });

    testWidgets('tapping calls onTap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SpringFilterChip(
              label: 'Action',
              isSelected: false,
              onTap: () => tapped = true,
              selectedDecoration: _selectedDecoration,
              unselectedDecoration: _unselectedDecoration,
              selectedTextColor: Colors.white,
              unselectedTextColor: Colors.black,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(SpringFilterChip));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets(
        'applies selectedDecoration and selectedTextColor when isSelected',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SpringFilterChip(
              label: 'Action',
              isSelected: true,
              onTap: () {},
              selectedDecoration: _selectedDecoration,
              unselectedDecoration: _unselectedDecoration,
              selectedTextColor: Colors.white,
              unselectedTextColor: Colors.black,
            ),
          ),
        ),
      );

      final container =
          tester.widget<AnimatedContainer>(find.byType(AnimatedContainer));
      expect(container.decoration, equals(_selectedDecoration));

      final text = tester.widget<Text>(find.text('Action'));
      expect(text.style!.color, equals(Colors.white));
      expect(text.style!.fontWeight, equals(FontWeight.w600));
    });

    testWidgets(
        'applies unselectedDecoration and unselectedTextColor when not selected',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SpringFilterChip(
              label: 'Action',
              isSelected: false,
              onTap: () {},
              selectedDecoration: _selectedDecoration,
              unselectedDecoration: _unselectedDecoration,
              selectedTextColor: Colors.white,
              unselectedTextColor: Colors.black,
            ),
          ),
        ),
      );

      final container =
          tester.widget<AnimatedContainer>(find.byType(AnimatedContainer));
      expect(container.decoration, equals(_unselectedDecoration));

      final text = tester.widget<Text>(find.text('Action'));
      expect(text.style!.color, equals(Colors.black));
      expect(text.style!.fontWeight, equals(FontWeight.w400));
    });

    testWidgets('a null onTap disables the tap without throwing',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SpringFilterChip(
              label: 'Action',
              isSelected: false,
              onTap: null,
              selectedDecoration: _selectedDecoration,
              unselectedDecoration: _unselectedDecoration,
              selectedTextColor: Colors.white,
              unselectedTextColor: Colors.black,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(SpringFilterChip));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });
}
