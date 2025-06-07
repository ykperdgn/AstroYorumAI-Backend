import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:astroyorumai/screens/notification_settings_screen.dart';
import 'package:astroyorumai/models/user_profile.dart';
import 'package:astroyorumai/services/profile_management_service.dart';
import 'package:flutter/services.dart';
import '../test_helpers.dart';

void main() {
  group('NotificationSettingsScreen Debug', () {
    setUp(() async {
      // Set up mock SharedPreferences with initial values
      SharedPreferences.setMockInitialValues({
        'daily_horoscope_enabled': false,
        'weekly_horoscope_enabled': false,
        'celestial_events_enabled': false,
        'daily_notification_hour': 9,
        'daily_notification_minute': 0,
        'weekly_notification_day': 1,
        'weekly_notification_hour': 9,
        'weekly_notification_minute': 0,
      });

      // Mock the NotificationService methods
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('dexterous.com/flutter/local_notifications'),
        (MethodCall methodCall) async {
          switch (methodCall.method) {
            case 'initialize':
              return true;
            case 'requestNotificationsPermission':
              return true;
            case 'requestPermissions':
              return true;
            default:
              return null;
          }
        },
      );

      // Create a mock active profile
      final testProfile = UserProfile(
        id: 'test-profile-id',
        name: 'Test User',
        birthDate: DateTime(1990, 5, 15),
        birthTime: '12:00',
        birthPlace: 'İstanbul',
        latitude: 41.0082,
        longitude: 28.9784,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save the test profile as active
      final service = await ProfileManagementService.getInstance();
      await service.saveProfile(testProfile);
      await service.setActiveProfile(testProfile.id);
    });

    testWidgets('Debug widget tree', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const NotificationSettingsScreen()),
      );

      // Wait for async operations
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Print the entire widget tree
      print("=== WIDGET TREE DEBUG ===");
      final allWidgets = tester.allWidgets.toList();
      for (int i = 0; i < allWidgets.length; i++) {
        final widget = allWidgets[i];
        print("[$i] ${widget.runtimeType}: ${widget.toString()}");
      }

      // Print specific widget types
      print("\n=== SWITCH LIST TILES ===");
      final switches = find.byType(SwitchListTile);
      print("Found ${switches.evaluate().length} SwitchListTiles");
      for (final element in switches.evaluate()) {
        final widget = element.widget as SwitchListTile;
        print("Switch: key=${widget.key}, title=${widget.title}, value=${widget.value}");
      }

      // Print buttons
      print("\n=== ELEVATED BUTTONS ===");
      final buttons = find.byType(ElevatedButton);
      print("Found ${buttons.evaluate().length} ElevatedButtons");
      for (final element in buttons.evaluate()) {
        final widget = element.widget as ElevatedButton;
        print("Button: key=${widget.key}, child=${widget.child}");
      }

      // Check for specific texts that might indicate state
      print("\n=== IMPORTANT TEXTS ===");
      final loadingText = find.text('Yükleniyor...');
      final permissionText = find.text('Bildirim İzni Gerekli');
      final profileMissingText = find.text('Bildirimleri etkinleştirmek için\nönce bir profil oluşturun.');
      
      print("Loading indicator: ${loadingText.evaluate().isNotEmpty}");
      print("Permission needed: ${permissionText.evaluate().isNotEmpty}");
      print("Profile missing: ${profileMissingText.evaluate().isNotEmpty}");

      // Print CircularProgressIndicator
      final progressIndicator = find.byType(CircularProgressIndicator);
      print("Progress indicator: ${progressIndicator.evaluate().isNotEmpty}");
    });
  });
}
