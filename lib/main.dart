import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/splash_screen.dart';
import 'services/localization_service.dart';
import 'l10n/app_localizations.dart';
import 'utils/platform_utils.dart';
import 'dart:developer' as developer;
import 'config/firebase_config_production.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Use safe platform detection
  bool isTestEnvironment = PlatformUtils.isTestEnvironment;

  if (!isTestEnvironment) {
    // Initialize Firebase with environment-specific configuration
    try {
      await Firebase.initializeApp(
        options: FirebaseConfigProduction.currentPlatform,
      );

      developer.log('✅ Firebase initialized for production environment');
      developer.log('🌐 Backend URL: ${AppEnvironment.backendUrl}');
      developer
          .log('🌍 Platform: ${PlatformUtils.platformName} deployment ready');

      if (PlatformUtils.isWeb) {
        developer.log('🖥️  Web platform detected - CORS handling enabled');
        developer.log('🔧 Dev port: ${PlatformUtils.webDevPort}');
      }
    } catch (e) {
      developer.log('❌ Firebase initialization failed: $e');
      // Continue app execution even if Firebase fails
    }

    developer.log('🚀 Starting AstroYorum AI with Firebase...');
    developer.log('✨ Production mode active - Full features ready!');
    developer.log('📱 Platform: ${PlatformUtils.platformName}');
  } else {
    developer
        .log('🧪 Test environment detected - skipping Firebase initialization');
  }

  runApp(const AstroYorumAIApp());
}

class AstroYorumAIApp extends StatefulWidget {
  const AstroYorumAIApp({super.key});
  @override
  AstroYorumAIAppState createState() => AstroYorumAIAppState();
}

class AstroYorumAIAppState extends State<AstroYorumAIApp> {
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final locale = await LocalizationService.getCurrentLocale();
    setState(() {
      _locale = locale;
    });
  }

  void _setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AstroYorumAI',
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('tr', ''),
      ],
      theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          scaffoldBackgroundColor: Colors.white,
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.deepPurple)
              .copyWith(secondary: Colors.amber),
          textTheme: const TextTheme(
            headlineSmall:
                TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
            titleMedium: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            bodyMedium: TextStyle(fontSize: 14.0),
          )),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(onLocaleChange: _setLocale),
    );
  }
}
