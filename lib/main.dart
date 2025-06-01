import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/splash_screen.dart';
import 'services/localization_service.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase for mobile and web platforms
  if (!kIsWeb) {
    // Mobile platforms (Android/iOS)
    try {
      await Firebase.initializeApp();
    } catch (e) {
      print('Firebase initialization failed: $e');
    }
  } else {
    // Web platform
    try {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "your-web-api-key",
          authDomain: "your-project.firebaseapp.com",
          projectId: "your-project-id",
          storageBucket: "your-project.appspot.com",
          messagingSenderId: "123456789",
          appId: "your-web-app-id",
        ),
      );
    } catch (e) {
      print('Firebase web initialization failed: $e');
    }
  }
  
  runApp(AstrolojiMasterApp());
}

class AstrolojiMasterApp extends StatefulWidget {
  @override
  _AstrolojiMasterAppState createState() => _AstrolojiMasterAppState();
}

class _AstrolojiMasterAppState extends State<AstrolojiMasterApp> {
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
      title: 'Astroloji Master',
      locale: _locale,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en', ''),
        Locale('tr', ''),
      ],
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.deepPurple).copyWith(secondary: Colors.amber),
        textTheme: TextTheme(
          headlineSmall: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
          titleMedium: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(fontSize: 14.0),
        )
      ),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(onLocaleChange: _setLocale),
    );
  }
}
