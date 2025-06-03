import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'birth_info_screen.dart';
import 'natal_chart_screen.dart';
import 'api_test_screen.dart';
import '../services/user_preferences_service.dart';
import '../models/user_birth_info.dart';

class SplashScreen extends StatefulWidget {
  final Function(Locale)? onLocaleChange;
  final UserPreferencesService? preferencesService;
  
  const SplashScreen({
    Key? key, 
    this.onLocaleChange,
    this.preferencesService,
  }) : super(key: key);
  
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final UserPreferencesService _prefsService;

  @override
  void initState() {
    super.initState();
    _prefsService = widget.preferencesService ?? UserPreferencesService();
    _checkSavedInfoAndNavigate();
  }
  Future<void> _checkSavedInfoAndNavigate() async {
    // Wait for a couple of seconds for the splash screen to be visible
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return; // Check if the widget is still in the tree

    UserBirthInfo? savedInfo = await _prefsService.loadUserBirthInfo();

    if (!mounted) return; // Check again after await

    if (savedInfo != null &&
        savedInfo.name != null && // Ensure essential data is present
        savedInfo.birthDate != null &&
        savedInfo.latitude != null &&
        savedInfo.longitude != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => NatalChartScreen(
            name: savedInfo.name!,
            birthDate: savedInfo.birthDate!,
            birthTime: savedInfo.birthTime,
            birthPlace: savedInfo.birthPlace,
            latitude: savedInfo.latitude!,
            longitude: savedInfo.longitude!,
          ),
        ),
      );
    } else {
      // If no valid info, or some essential parts are missing, go to BirthInfoScreen
      // Pass the potentially partially loaded info so user can complete/correct it
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BirthInfoScreen(initialBirthInfo: savedInfo)),
      );
      // Or, if HomeScreen is a necessary intermediate step before BirthInfoScreen:
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => HomeScreen()),
      // );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star_border_purple500_outlined, size: 120, color: Colors.deepPurpleAccent),
            const SizedBox(height: 24),
            const Text(              'AstroYorum AI', // Updated App Name
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.deepPurple),
            ),
            const SizedBox(height: 12),
            Text(
              'Gökyüzü Rehberiniz', // Subtitle
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
            const SizedBox(height: 30),
            const CircularProgressIndicator(color: Colors.deepPurpleAccent),
          ],
        ),
      ),      // Debug: API Test Button (only in debug mode)
      floatingActionButton: kDebugMode 
        ? FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ApiTestScreen()),
              );
            },
            backgroundColor: Colors.orange,
            tooltip: 'Test Production API',
            child: const Icon(Icons.api),
          )
        : null,
    );
  }
}
