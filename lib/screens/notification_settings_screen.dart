import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../services/profile_management_service.dart';
import '../models/user_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});
  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _dailyHoroscopeEnabled = false;
  bool _weeklyHoroscopeEnabled = false;
  bool _celestialEventsEnabled = false;
  TimeOfDay _dailyTime = const TimeOfDay(hour: 9, minute: 0);
  int _weeklyDay = 1; // Monday
  TimeOfDay _weeklyTime = const TimeOfDay(hour: 9, minute: 0);

  UserProfile? _activeProfile;
  bool _isLoading = true;
  bool _permissionGranted = false;

  final List<String> _weekdays = [
    'Pazartesi',
    'Salı',
    'Çarşamba',
    'Perşembe',
    'Cuma',
    'Cumartesi',
    'Pazar'
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    await NotificationService.initialize();

    final service = await ProfileManagementService.getInstance();
    final profile = await service.getActiveProfile();
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _activeProfile = profile;
      _dailyHoroscopeEnabled =
          prefs.getBool('daily_horoscope_enabled') ?? false;
      _weeklyHoroscopeEnabled =
          prefs.getBool('weekly_horoscope_enabled') ?? false;
      _celestialEventsEnabled =
          prefs.getBool('celestial_events_enabled') ?? false;

      final dailyHour = prefs.getInt('daily_notification_hour') ?? 9;
      final dailyMinute = prefs.getInt('daily_notification_minute') ?? 0;
      _dailyTime = TimeOfDay(hour: dailyHour, minute: dailyMinute);

      _weeklyDay = prefs.getInt('weekly_notification_day') ?? 1;
      final weeklyHour = prefs.getInt('weekly_notification_hour') ?? 9;
      final weeklyMinute = prefs.getInt('weekly_notification_minute') ?? 0;
      _weeklyTime = TimeOfDay(hour: weeklyHour, minute: weeklyMinute);

      _isLoading = false;
    });

    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final hasPermission = await NotificationService.requestPermissions();
    setState(() {
      _permissionGranted = hasPermission;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('daily_horoscope_enabled', _dailyHoroscopeEnabled);
    await prefs.setBool('weekly_horoscope_enabled', _weeklyHoroscopeEnabled);
    await prefs.setBool('celestial_events_enabled', _celestialEventsEnabled);

    await prefs.setInt('daily_notification_hour', _dailyTime.hour);
    await prefs.setInt('daily_notification_minute', _dailyTime.minute);

    await prefs.setInt('weekly_notification_day', _weeklyDay);
    await prefs.setInt('weekly_notification_hour', _weeklyTime.hour);
    await prefs.setInt('weekly_notification_minute', _weeklyTime.minute);

    // Schedule or cancel notifications based on settings
    if (_activeProfile != null) {
      if (_dailyHoroscopeEnabled) {
        await NotificationService.scheduleDailyHoroscope(
          profile: _activeProfile!,
          hour: _dailyTime.hour,
          minute: _dailyTime.minute,
        );
      }

      if (_weeklyHoroscopeEnabled) {
        await NotificationService.scheduleWeeklyHoroscope(
          profile: _activeProfile!,
          weekday: _weeklyDay,
          hour: _weeklyTime.hour,
          minute: _weeklyTime.minute,
        );
      }

      if (!_dailyHoroscopeEnabled || !_weeklyHoroscopeEnabled) {
        if (!_dailyHoroscopeEnabled && !_weeklyHoroscopeEnabled) {
          await NotificationService.cancelProfileNotifications(
              _activeProfile!.id);
        }
      }
    }
  }

  Future<void> _selectTime(BuildContext context, bool isDaily) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isDaily ? _dailyTime : _weeklyTime,
      helpText: isDaily ? 'Günlük Bildirim Saati' : 'Haftalık Bildirim Saati',
    );

    if (picked != null) {
      setState(() {
        if (isDaily) {
          _dailyTime = picked;
        } else {
          _weeklyTime = picked;
        }
      });
      await _saveSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Bildirim Ayarları')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_activeProfile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Bildirim Ayarları')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_off, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'Bildirimleri etkinleştirmek için\nönce bir profil oluşturun.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirim Ayarları'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showPermissionInfo(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          if (!_permissionGranted)
            Card(
              color: Colors.orange[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(Icons.notifications_off, color: Colors.orange),
                    const SizedBox(height: 8),
                    const Text(
                      'Bildirim İzni Gerekli',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Bildirimleri almak için izin vermeniz gerekiyor.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _checkPermissions,
                      child: const Text('İzin Ver'),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Aktif Profil',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      CircleAvatar(
                        child: Text(_activeProfile!.name[0].toUpperCase()),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _activeProfile!.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${_activeProfile!.birthDate.day}/${_activeProfile!.birthDate.month}/${_activeProfile!.birthDate.year}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Daily Horoscope Settings
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.today, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        'Günlük Burç Yorumu',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Her gün belirlediğiniz saatte günlük burç yorumunuzu alın.',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    key: const Key('daily_reminder_switch'),
                    title: const Text('Günlük Bildirimleri Etkinleştir'),
                    value: _dailyHoroscopeEnabled,
                    onChanged: _permissionGranted
                        ? (value) {
                            setState(() {
                              _dailyHoroscopeEnabled = value;
                            });
                            _saveSettings();
                          }
                        : null,
                  ),
                  if (_dailyHoroscopeEnabled) ...[
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.schedule),
                      title: const Text('Bildirim Saati'),
                      subtitle: Text(_dailyTime.format(context)),
                      trailing: const Icon(Icons.edit),
                      onTap: () => _selectTime(context, true),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16), // Weekly Horoscope Settings
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_view_week,
                          color: Theme.of(context).primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        'Haftalık Burç Yorumu',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Haftanın belirlediğiniz gününde haftalık burç yorumunuzu alın.',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    key: const Key('weekly_reminder_switch'),
                    title: const Text('Haftalık Bildirimleri Etkinleştir'),
                    value: _weeklyHoroscopeEnabled,
                    onChanged: _permissionGranted
                        ? (value) {
                            setState(() {
                              _weeklyHoroscopeEnabled = value;
                            });
                            _saveSettings();
                          }
                        : null,
                  ),
                  if (_weeklyHoroscopeEnabled) ...[
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.date_range),
                      title: const Text('Bildirim Günü'),
                      subtitle: Text(_weekdays[_weeklyDay - 1]),
                      trailing: const Icon(Icons.edit),
                      onTap: () => _selectWeekday(),
                    ),
                    ListTile(
                      leading: const Icon(Icons.schedule),
                      title: const Text('Bildirim Saati'),
                      subtitle: Text(_weeklyTime.format(context)),
                      trailing: const Icon(Icons.edit),
                      onTap: () => _selectTime(context, false),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Celestial Events Settings
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome,
                          color: Theme.of(context).primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        'Göksel Olaylar',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Önemli göksel olaylar (tutulmalar, retrogradlar vb.) hakkında bildirim alın.',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    key: const Key('special_event_switch'),
                    title: const Text('Göksel Olay Bildirimleri'),
                    value: _celestialEventsEnabled,
                    onChanged: _permissionGranted
                        ? (value) {
                            setState(() {
                              _celestialEventsEnabled = value;
                            });
                            _saveSettings();
                          }
                        : null,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Save button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              key: const Key('save_button'),
              icon: const Icon(Icons.save),
              label: const Text('Ayarları Kaydet'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                await _saveSettings();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ayarlar başarıyla kaydedildi!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Test Notification Button
          if (_permissionGranted)
            ElevatedButton.icon(
              icon: const Icon(Icons.notification_add),
              label: const Text('Test Bildirimi Gönder'),
              onPressed: () => _sendTestNotification(),
            ),
        ],
      ),
    );
  }

  Future<void> _selectWeekday() async {
    final int? selected = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bildirim Günü Seçin'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(7, (index) {
            return RadioListTile<int>(
              title: Text(_weekdays[index]),
              value: index + 1,
              groupValue: _weeklyDay,
              onChanged: (value) {
                Navigator.pop(context, value);
              },
            );
          }),
        ),
      ),
    );

    if (selected != null) {
      setState(() {
        _weeklyDay = selected;
      });
      await _saveSettings();
    }
  }

  Future<void> _sendTestNotification() async {
    await NotificationService.showNotification(
      id: 999,
      title: 'Test Bildirimi ✨',
      body:
          'Bildirimleriniz başarıyla çalışıyor! Astroloji Master\'dan selamlar.',
      payload: 'test',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test bildirimi gönderildi!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showPermissionInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bildirim İzinleri Hakkında'),
        content: const Text('Bildirimleri etkinleştirmek için:\n\n'
            '1. Cihazınızın bildirim izinlerini kontrol edin\n'
            '2. Astroloji Master uygulamasına bildirim gönderme izni verin\n'
            '3. Bildirimlerin engellenmediğinden emin olun\n\n'
            'iOS: Ayarlar > Bildirimler > Astroloji Master\n'
            'Android: Ayarlar > Uygulamalar > Astroloji Master > Bildirimler'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }
}
