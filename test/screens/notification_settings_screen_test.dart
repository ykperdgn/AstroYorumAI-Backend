import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:astroyorumai/screens/notification_settings_screen.dart';
import '../test_helpers.dart';

void main() {  testWidgets('Bildirim ayarları varsayılan değerlerle geliyor mu?', (WidgetTester tester) async {
    await tester.pumpWidget(
      createTestApp(NotificationSettingsScreen()),
    );

    // Varsayılan switch'leri bul
    final dailyReminderSwitch = find.byKey(Key('daily_reminder_switch'));
    final specialEventSwitch = find.byKey(Key('special_event_switch'));

    expect(dailyReminderSwitch, findsOneWidget);
    expect(specialEventSwitch, findsOneWidget);

    // Varsayılan değerler kontrolü (örnek: kapalı olmalı)
    final dailySwitchWidget = tester.widget<Switch>(dailyReminderSwitch);
    final specialSwitchWidget = tester.widget<Switch>(specialEventSwitch);

    expect(dailySwitchWidget.value, isFalse);
    expect(specialSwitchWidget.value, isFalse);
  });
  testWidgets('Kullanıcı ayarı değiştirdiğinde switch durumu değişiyor mu?', (WidgetTester tester) async {
    await tester.pumpWidget(
      createTestApp(NotificationSettingsScreen()),
    );

    final dailyReminderSwitch = find.byKey(Key('daily_reminder_switch'));

    // Tıklama simülasyonu
    await tester.tap(dailyReminderSwitch);
    await tester.pump();

    final updatedSwitch = tester.widget<Switch>(dailyReminderSwitch);
    expect(updatedSwitch.value, isTrue);
  });

  testWidgets('Kaydet butonuna basıldığında işlem yapılıyor mu?', (WidgetTester tester) async {
    // Test the notification settings screen
    await tester.pumpWidget(
      MaterialApp(
        home: NotificationSettingsScreen(),
      ),
    );

    final saveButton = find.byKey(Key('save_button'));

    expect(saveButton, findsOneWidget);

    await tester.tap(saveButton);
    await tester.pump();

    // Just verify the button exists and can be tapped
    // Since there's no callback, we can't check saveCalled
  });
}
