import 'package:flutter/material.dart';
import 'birth_info_screen.dart';
import 'profile_management_screen.dart';
import 'notification_settings_screen.dart';
import 'astrology_calendar_screen.dart';
import 'settings_screen.dart';
import '../services/profile_management_service.dart';
import '../models/user_profile.dart';

class HomeScreen extends StatefulWidget {
  final ProfileManagementService? profileService;

  const HomeScreen({Key? key, this.profileService}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserProfile? _activeProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActiveProfile();
  }

  Future<void> _loadActiveProfile() async {
    try {
      UserProfile? profile;      if (widget.profileService != null) {
        // Use injected service for testing
        profile = await widget.profileService!.getActiveProfile();
      } else {        // Use instance method for consistency
        final service = await ProfileManagementService.getInstance();
        profile = await service.getActiveProfile();
      }
      
      if (mounted) {
        setState(() {
          _activeProfile = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToProfileManagementScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfileManagementScreen()),
    );
    if (result == true && mounted) {
      _loadActiveProfile();
    }
  }

  void _navigateToSettingsScreen() {
     Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SettingsScreen()),
    );
  }

  void _navigateToBirthInfoScreen({UserProfile? profile}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BirthInfoScreen(prefilledProfile: profile)),
    );
  }
  
  void _navigateToAstrologyCalendarScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AstrologyCalendarScreen()),
    );
  }

  void _navigateToNotificationSettingsScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NotificationSettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Astroloji Master'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: _navigateToProfileManagementScreen,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _navigateToSettingsScreen,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_activeProfile != null) ...[
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
                            Text(
                              _activeProfile!.name,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            Text(
                              '${_activeProfile!.birthDate.day}/${_activeProfile!.birthDate.month}/${_activeProfile!.birthDate.year}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            if (_activeProfile!.birthPlace != null && _activeProfile!.birthPlace!.isNotEmpty)
                              Text(
                                _activeProfile!.birthPlace!,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text('Natal Haritamı Gör'),
                      onPressed: () => _navigateToBirthInfoScreen(profile: _activeProfile),
                    ),
                  ],
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Yeni Doğum Bilgisi Gir'),
                    onPressed: () => _navigateToBirthInfoScreen(),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.people),
                    label: const Text('Profil Yönetimi'),
                    onPressed: _navigateToProfileManagementScreen,
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_month),
                    label: const Text('Astroloji Takvimi'),
                    onPressed: _navigateToAstrologyCalendarScreen,
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.notifications),
                    label: const Text('Bildirim Ayarları'),
                    onPressed: _navigateToNotificationSettingsScreen,
                  ),
                ],
              ),
            ),
    );
  }
}
