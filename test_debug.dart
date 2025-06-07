import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:astroyorumai/screens/birth_info_screen.dart';
import 'package:astroyorumai/services/geocoding_service.dart';
import 'package:astroyorumai/services/user_preferences_service.dart';
import 'test/test_helpers.dart'; // Import shared test helpers

import 'test/screens/birth_info_screen_test.mocks.dart';

// Create a test widget that mimics BirthInfoScreen behavior
class TestFormWidget extends StatefulWidget {
  const TestFormWidget({super.key});

  @override
  _TestFormWidgetState createState() => _TestFormWidgetState();
}

class _TestFormWidgetState extends State<TestFormWidget> {
  final _nameController = TextEditingController();
  
  void _handleSubmission() {
    print('_handleSubmission called');
    if (_nameController.text.trim().isEmpty) {
      print('Name is empty, showing SnackBar');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name required'))
      );
      return;
    }
    print('Name is not empty: ${_nameController.text}');
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          ElevatedButton(
            key: const Key('test_button'),
            onPressed: _handleSubmission,
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}

// Generate mocks for the services
@GenerateMocks([GeocodingService, UserPreferencesService])
void main() {
  testWidgets('Debug simple button logic', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: TestFormWidget(),
      ),
    );
    
    print('Tapping test button...');
    await tester.tap(find.byKey(const Key('test_button')));
    await tester.pump();
    
    print('SnackBar count: ${tester.widgetList(find.byType(SnackBar)).length}');
    await tester.pump(const Duration(milliseconds: 100));
    print('SnackBar count after delay: ${tester.widgetList(find.byType(SnackBar)).length}');
  });
  testWidgets('Debug actual BirthInfoScreen method call', (WidgetTester tester) async {
    final mockGeocodingService = SharedMockGeocodingService();
    final mockPreferencesService = MockUserPreferencesService();
    
    // Set up preferences service mock behavior
    when(mockPreferencesService.saveUserBirthInfo(any)).thenAnswer((_) async {});

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        locale: const Locale('tr', 'TR'),
        home: BirthInfoScreen(
          geocodingService: mockGeocodingService,
          preferencesService: mockPreferencesService,
          alwaysAutoValidate: false,
        ),
      ),
    );
    
    print('Getting name controller text...');
    final nameField = find.byKey(const Key('name_field'));
    final nameWidget = tester.widget<TextFormField>(nameField);
    print('Name controller text: "${nameWidget.controller?.text}"');
    print('Name controller text empty: ${nameWidget.controller?.text.trim().isEmpty}');
    
    print('Tapping actual submit button...');
    try {
      await tester.tap(find.byKey(const Key('submit_button')));
      await tester.pump();
      print('Button tap completed successfully');
    } catch (e) {
      print('Error during button tap: $e');
    }
    
    print('SnackBar count: ${tester.widgetList(find.byType(SnackBar)).length}');
  });
}
