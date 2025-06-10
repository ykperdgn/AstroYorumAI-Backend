import 'package:flutter/material.dart';
import 'birth_info_screen.dart';
import 'profile_management_screen.dart';
import 'notification_settings_screen.dart';
import 'astrology_calendar_screen.dart';
import 'settings_screen.dart';
import 'partner_management_screen.dart';
import 'horary_question_pro_screen.dart';
import '../services/profile_management_service.dart';
import '../services/daily_astrology_service.dart';
import '../models/user_profile.dart';
import '../models/daily_astrology_reading.dart';

class HomeScreen extends StatefulWidget {
  final ProfileManagementService? profileService;

  const HomeScreen({super.key, this.profileService});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserProfile? _activeProfile;
  bool _isLoading = true;
  DailyAstrologyReading? _todaysReading;

  @override
  void initState() {
    super.initState();
    _loadActiveProfile();
    _loadTodaysReading();
  }

  Future<void> _loadActiveProfile() async {
    try {
      UserProfile? profile;
      if (widget.profileService != null) {
        // Use injected service for testing
        profile = await widget.profileService!.getActiveProfile();
      } else {
        // Use instance method for consistency
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

  Future<void> _loadTodaysReading() async {
    if (_activeProfile != null) {
      try {
        // Mock zodiac sign - in real app this would come from the user's natal chart
        const mockZodiacSign =
            'Aries'; // This should be calculated from birth data
        final reading = await DailyAstrologyService.generateDailyReading(
          zodiacSign: mockZodiacSign,
          date: DateTime.now(),
        );

        if (mounted) {
          setState(() {
            _todaysReading = reading;
          });
        }
      } catch (e) {
        // Error loading daily reading - handled silently in production
      }
    }
  }

  void _navigateToProfileManagementScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileManagementScreen()),
    );
    if (result == true && mounted) {
      _loadActiveProfile();
    }
  }

  void _navigateToSettingsScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  void _navigateToBirthInfoScreen({UserProfile? profile}) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => BirthInfoScreen(prefilledProfile: profile)),
    );
  }

  void _navigateToAstrologyCalendarScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AstrologyCalendarScreen()),
    );
  }

  void _navigateToNotificationSettingsScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => const NotificationSettingsScreen()),
    );
  }

  void _navigateToPartnerManagementScreen() {
    if (_activeProfile != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              PartnerManagementScreen(userId: _activeProfile!.id),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Önce bir profil oluşturun'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _navigateToHoraryQuestionScreen() {
    if (_activeProfile != null) {
      if (_activeProfile!.isPro) {
        // Navigate to Pro Horary screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HoraryQuestionProScreen(
              userId: _activeProfile!.id,
              isPremiumUser: true,
            ),
          ),
        );
      } else {
        // Show Pro upgrade dialog for free users
        _showProUpgradeDialog();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Önce bir profil oluşturun'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _showProUpgradeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: Colors.amber),
            SizedBox(width: 8),
            Text('Pro Özellik 💎'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🔮 Horary Astroloji - Saat Astrolojisi',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            const Text(
              'Zihninizde bir soru var mı?\n'
              '• "Seviyor mu?"\n'
              '• "Bu iş doğru mu?"\n'
              '• "Kayıp eşyam nerede?"\n\n'
              'Gökyüzü o an size ne söylüyor öğrenin!',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple.shade100, Colors.amber.shade100],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '✨ Pro ile Sınırsız Soru Sorma\n'
                '🎯 Anında Mistik Cevaplar\n'
                '📜 Özel Horary Yorumları',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Şimdi Değil'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToProUpgradeScreen();
            },
            icon: const Icon(Icons.diamond),
            label: const Text('Pro\'ya Geç'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToProUpgradeScreen() {
    // TODO: Pro upgrade ekranına yönlendirme
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pro upgrade ekranı geliştirilme aşamasında...'),
        backgroundColor: Colors.deepPurple,
      ),
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
          : SingleChildScrollView(
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
                            if (_activeProfile!.birthPlace != null &&
                                _activeProfile!.birthPlace!.isNotEmpty)
                              Text(
                                _activeProfile!.birthPlace!,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Daily Astrology Reading Card
                    if (_todaysReading != null) ...[
                      Card(
                        elevation: 4,
                        shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12))),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(12)),
                            gradient: LinearGradient(
                              colors: [
                                Colors.deepPurple.shade400,
                                Colors.deepPurple.shade600
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.star,
                                      color: Colors.white, size: 24),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Günlük Astroloji',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    _todaysReading!.luckEmoji,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _todaysReading!.dailyMessage,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _todaysReading!.mood,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    ElevatedButton.icon(
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text('Natal Haritamı Gör'),
                      onPressed: () =>
                          _navigateToBirthInfoScreen(profile: _activeProfile),
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
                    icon: const Icon(Icons.favorite),
                    label: const Text('Partner Yönetimi'),
                    onPressed: _navigateToPartnerManagementScreen,
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
                  const SizedBox(height: 10),
                  // Pro Horary Astrology Button
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _activeProfile?.isPro == true
                            ? [
                                Colors.deepPurple.shade400,
                                Colors.deepPurple.shade600
                              ]
                            : [Colors.grey.shade300, Colors.grey.shade400],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: OutlinedButton.icon(
                      icon: Icon(
                        Icons.auto_awesome,
                        color: _activeProfile?.isPro == true
                            ? Colors.white
                            : Colors.grey.shade600,
                      ),
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Horary Astroloji',
                            style: TextStyle(
                              color: _activeProfile?.isPro == true
                                  ? Colors.white
                                  : Colors.grey.shade600,
                            ),
                          ),
                          if (_activeProfile?.isPro != true) ...[
                            const SizedBox(width: 4),
                            Icon(
                              Icons.lock,
                              size: 16,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'PRO',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ] else ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'PRO',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      onPressed: _navigateToHoraryQuestionScreen,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide.none,
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
