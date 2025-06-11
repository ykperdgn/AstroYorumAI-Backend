import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:astroyorumai/screens/birth_info_screen.dart';
import 'package:astroyorumai/models/user_profile.dart';
import 'test/test_helpers.dart';

void main() {
  testWidgets('Debug widget tree', (WidgetTester tester) async {
    final profile = UserProfile(
      id: 'test-debug',
      name: '', // Empty name to trigger validation
      birthDate: DateTime(1990, 1, 15),
      birthTime: '12:00',
      birthPlace: 'Test City',
      latitude: 40.0,
      longitude: 30.0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await tester.pumpWidget(
      createTestApp(
        BirthInfoScreen(
          prefilledProfile: profile,
          alwaysAutoValidate: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Debug widget tree analysis (prints removed for production)
    // Widget tree, keys, and button states are analyzed internally
    final elements =
        tester.allElements.where((element) => element.widget.key != null);
    final buttons = tester.allWidgets.whereType<ElevatedButton>();

    // Verify that widgets are properly rendered
    expect(elements.length, greaterThan(0));
    expect(buttons.length, greaterThan(0));
  });
}
