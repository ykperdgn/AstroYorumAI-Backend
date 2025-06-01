import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  testWidgets('Simple TextFormField validation test', (WidgetTester tester) async {
    final formKey = GlobalKey<FormState>();
    final controller = TextEditingController();
    
    // Set invalid value
    controller.text = "95";
    
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('tr', 'TR'),
          Locale('en', 'US'),
        ],
        locale: const Locale('tr', 'TR'),
        home: Scaffold(
          body: Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: controller,
                  decoration: InputDecoration(labelText: 'Enlem (Latitude)'),
                  validator: (value) {
                    print('DEBUG: Validator called with value: $value');
                    if (value == null || value.trim().isEmpty) {
                      return 'Lütfen enlem girin';
                    }
                    final lat = double.tryParse(value.trim());
                    if (lat == null) {
                      return 'Geçerli bir sayı girin';
                    }
                    if (lat < -90 || lat > 90) {
                      print('DEBUG: Validation failed - latitude out of range');
                      return 'Enlem -90 ile 90 arasında olmalıdır';
                    }
                    print('DEBUG: Validation passed');
                    return null;
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    print('DEBUG: Button pressed, calling validate');
                    final isValid = formKey.currentState!.validate();
                    print('DEBUG: Validation result: $isValid');
                  },
                  child: Text('Validate'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Find and tap the button
    final button = find.byType(ElevatedButton);
    await tester.tap(button);
    await tester.pump();
    await tester.pump();
    await tester.pumpAndSettle();

    // Look for validation error
    print('=== Looking for validation error ===');
    final errorFinder = find.text('Enlem -90 ile 90 arasında olmalıdır');
    print('Found error messages: ${errorFinder.evaluate().length}');
    
    // Try to find any text that contains "90"
    final anyText90 = find.textContaining('90');
    print('Found text containing "90": ${anyText90.evaluate().length}');
    
    // Print all text widgets
    final allTexts = find.byType(Text);
    print('All text widgets:');
    for (int i = 0; i < allTexts.evaluate().length; i++) {
      final textWidget = tester.widget<Text>(allTexts.at(i));
      print('  $i: "${textWidget.data}"');
    }

    expect(errorFinder, findsOneWidget);
  });
}
