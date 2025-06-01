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
    
    // Print the widget tree
    print('=== WIDGET TREE ===');
    print(tester.binding.renderView.toStringDeep());
    
    // Print all widgets with keys
    print('=== WIDGETS WITH KEYS ===');
    final elements = tester.allElements.where((element) => element.widget.key != null);
    for (final element in elements) {
      print('Key: ${element.widget.key}, Widget: ${element.widget.runtimeType}');
    }
    
    // Print all ElevatedButton widgets
    print('=== ELEVATED BUTTONS ===');
    final buttons = tester.allWidgets.whereType<ElevatedButton>();
    for (final button in buttons) {
      print('Button key: ${button.key}, onPressed: ${button.onPressed != null ? "not null" : "null"}');
    }
  });
}
