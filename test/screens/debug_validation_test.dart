import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  testWidgets('Debug Form Validation', (WidgetTester tester) async {
    final formKey = GlobalKey<FormState>();
    
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
              children: [                TextFormField(
                  decoration: InputDecoration(labelText: 'Test Field'),
                  validator: (value) {
                    print('VALIDATOR CALLED with value: "$value"');
                    if (value == null || value.isEmpty) {
                      print('VALIDATOR RETURNING: "Bu alan gerekli"');
                      return 'Bu alan gerekli';
                    }
                    final num = double.tryParse(value);
                    if (num == null) {
                      print('VALIDATOR RETURNING: "Geçerli bir sayı girin"');
                      return 'Geçerli bir sayı girin';
                    }
                    if (num < -90 || num > 90) {
                      print('VALIDATOR RETURNING: "Enlem -90 ile 90 arasında olmalıdır"');
                      return 'Enlem -90 ile 90 arasında olmalıdır';
                    }
                    print('VALIDATOR RETURNING: null (valid)');
                    return null;
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    print('BUTTON PRESSED - calling validate()');
                    final isValid = formKey.currentState!.validate();
                    print('BUTTON PRESSED - validate() returned: $isValid');
                  },
                  child: Text('Validate'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Enter invalid value
    await tester.enterText(find.byType(TextFormField), '95');
    await tester.pump();

    // Trigger validation by tapping button
    await tester.tap(find.text('Validate'));
    await tester.pump(); // Important: pump after validation
    
    // Debug: Print all text widgets
    print('=== All Text Widgets ===');
    final allTexts = find.byType(Text);
    for (int i = 0; i < allTexts.evaluate().length; i++) {
      final textWidget = tester.widget<Text>(allTexts.at(i));
      print('Text $i: "${textWidget.data}"');
    }

    // Look for error message
    expect(find.text('Enlem -90 ile 90 arasında olmalıdır'), findsOneWidget);
  });
}
