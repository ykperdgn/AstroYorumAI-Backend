// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'test_setup.dart';

import 'package:astroyorumai/main.dart';

void main() {
  setUpAll(() async {
    await setupFirebaseForTest();
  });

  testWidgets('App launches and shows main screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(AstrolojiMasterApp());
    
    // Verify that our app loads (should show some basic UI)
    expect(find.byType(MaterialApp), findsOneWidget);
    
    // Wait for initial frames and splash screen to appear
    await tester.pump();
    
    // Check if splash screen elements are present
    expect(find.text('AstroYorum AI'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    
    // Wait for the splash screen timer to complete (2 seconds + buffer)
    await tester.pump(Duration(seconds: 3));
    await tester.pumpAndSettle();
  });
}
