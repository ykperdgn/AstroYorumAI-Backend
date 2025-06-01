import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  testWidgets('Basic form validation test', (WidgetTester tester) async {
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
              children: [
                TextFormField(
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Bu alan boş olamaz';
                    }
                    final num = double.tryParse(value.trim());
                    if (num == null) {
                      return 'Geçerli bir sayı girin';
                    }
                    if (num < -90 || num > 90) {
                      return 'Enlem -90 ile 90 arasında olmalıdır';
                    }
                    return null;
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    formKey.currentState!.validate();
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

    // Enter invalid value
    await tester.enterText(find.byType(TextFormField), '100');
    await tester.pump();

    // Trigger validation
    await tester.tap(find.text('Validate'));
    await tester.pumpAndSettle();

    // Check if validation error appears
    final errorText = find.text('Enlem -90 ile 90 arasında olmalıdır');
    print('Validation error found: ${errorText.evaluate().length > 0}');
    
    expect(errorText, findsOneWidget);
  });
}
