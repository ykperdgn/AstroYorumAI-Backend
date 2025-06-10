import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  testWidgets('Simple TextFormField validation test',
      (WidgetTester tester) async {
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
                  decoration:
                      const InputDecoration(labelText: 'Enlem (Latitude)'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Lütfen enlem girin';
                    }
                    final lat = double.tryParse(value.trim());
                    if (lat == null) {
                      return 'Geçerli bir sayı girin';
                    }
                    if (lat < -90 || lat > 90) {
                      return 'Enlem -90 ile 90 arasında olmalıdır';
                    }
                    return null;
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    formKey.currentState!.validate();
                  },
                  child: const Text('Validate'),
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
    final errorFinder = find.text('Enlem -90 ile 90 arasında olmalıdır');

    expect(errorFinder, findsOneWidget);
  });
}
