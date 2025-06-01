// Direct validation test to understand Flutter validation behavior
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:astroyorumai/screens/birth_info_screen.dart';
import 'package:astroyorumai/services/user_preferences_service.dart';
import 'package:astroyorumai/services/geocoding_service.dart';
import 'package:astroyorumai/widgets/loading_indicator.dart';

import 'birth_info_screen_test.mocks.dart';

void main() {
  group('BirthInfoScreen Direct Validation Tests', () {
    late MockUserPreferencesService mockPreferencesService;
    late MockGeocodingService mockGeocodingService;

    setUp(() {
      mockPreferencesService = MockUserPreferencesService();
      mockGeocodingService = MockGeocodingService();
    });

    Widget createTestWidget(Widget child) {
      return MaterialApp(
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
        home: child,
      );
    }

    testWidgets('DEBUG: Force validation with Form.validate()', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          BirthInfoScreen(
            preferencesService: mockPreferencesService,
            geocodingService: mockGeocodingService,
          ),
        ),
      );

      // Enter invalid latitude
      final latField = find.byType(TextFormField).at(2);
      await tester.enterText(latField, '95.0'); // Invalid latitude
      await tester.pump();
      
      // Force form validation by accessing the form directly
      final formFinder = find.byType(Form);
      expect(formFinder, findsOneWidget);
      final formElement = tester.element(formFinder);
      final formWidget = formElement.widget as Form;
      final formState = formWidget.key as GlobalKey<FormState>;
      
      print('=== FORCING VALIDATION ===');
      final isValid = formState.currentState!.validate();
      print('Form validation result: $isValid');
      
      await tester.pump(); // Allow validation to complete
      
      print('=== AFTER FORCED VALIDATION ===');
      print('All text widgets:');
      for (var element in find.byType(Text).evaluate()) {
        final widget = element.widget as Text;
        if (widget.data != null) {
          print('  Text: "${widget.data}"');
        }
      }
      
      // Check for validation error message
      final validationMessage = find.text('Enlem -90 ile 90 arasında olmalıdır');
      print('Exact validation message found: ${validationMessage.evaluate().length}');
      
      expect(isValid, isFalse, reason: 'Form should be invalid with latitude 95.0');
    });

    testWidgets('DEBUG: Check autovalidate behavior', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          BirthInfoScreen(
            preferencesService: mockPreferencesService,
            geocodingService: mockGeocodingService,
          ),
        ),
      );

      // Get the Form widget and check its autovalidate mode
      final formFinder = find.byType(Form);
      final formElement = tester.element(formFinder);
      final formWidget = formElement.widget as Form;
      
      print('=== FORM STATE ANALYSIS ===');
      print('Initial autovalidate mode: ${formWidget.autovalidateMode}');
      
      // Enter invalid data and trigger field changes
      await tester.enterText(find.byType(TextFormField).at(2), '95.0');
      await tester.pump();
      
      // Check if the form autovalidate mode has changed
      final formElement2 = tester.element(formFinder);
      final formWidget2 = formElement2.widget as Form;
      print('After text entry autovalidate mode: ${formWidget2.autovalidateMode}');
    });
  });
}
