import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Astrology Master'**
  String get appTitle;

  /// Home screen title
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Birth chart screen title
  ///
  /// In en, this message translates to:
  /// **'Birth Chart'**
  String get birthChart;

  /// Natal chart title
  ///
  /// In en, this message translates to:
  /// **'Natal Chart'**
  String get natalChart;

  /// Profile management screen title
  ///
  /// In en, this message translates to:
  /// **'Profile Management'**
  String get profileManagement;

  /// Astrology calendar screen title
  ///
  /// In en, this message translates to:
  /// **'Astrology Calendar'**
  String get astrologyCalendar;

  /// Notification settings screen title
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// Name field label
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// Birth date field label
  ///
  /// In en, this message translates to:
  /// **'Birth Date'**
  String get birthDate;

  /// Birth time field label
  ///
  /// In en, this message translates to:
  /// **'Birth Time'**
  String get birthTime;

  /// Birth place field label
  ///
  /// In en, this message translates to:
  /// **'Birth Place'**
  String get birthPlace;

  /// Sun sign label
  ///
  /// In en, this message translates to:
  /// **'Sun Sign'**
  String get sunSign;

  /// Ascendant sign label
  ///
  /// In en, this message translates to:
  /// **'Ascendant'**
  String get ascendant;

  /// Planet positions section title
  ///
  /// In en, this message translates to:
  /// **'Planet Positions'**
  String get planetPositions;

  /// Daily horoscope section title
  ///
  /// In en, this message translates to:
  /// **'Daily Horoscope'**
  String get dailyHoroscope;

  /// Weekly horoscope section title
  ///
  /// In en, this message translates to:
  /// **'Weekly Horoscope'**
  String get weeklyHoroscope;

  /// Monthly horoscope section title
  ///
  /// In en, this message translates to:
  /// **'Monthly Horoscope'**
  String get monthlyHoroscope;

  /// Compatibility label
  ///
  /// In en, this message translates to:
  /// **'Compatibility'**
  String get compatibility;

  /// Mood label
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get mood;

  /// Lucky color label
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// Lucky number label
  ///
  /// In en, this message translates to:
  /// **'Lucky Number'**
  String get luckyNumber;

  /// Lucky time label
  ///
  /// In en, this message translates to:
  /// **'Lucky Time'**
  String get luckyTime;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Delete button text
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Edit button text
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Add button text
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// Loading indicator text
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Error message title
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Retry button text
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Share button text
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// Export button text
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// Share as text option
  ///
  /// In en, this message translates to:
  /// **'Share as Text'**
  String get shareAsText;

  /// Share as PDF option
  ///
  /// In en, this message translates to:
  /// **'Share as PDF'**
  String get shareAsPdf;

  /// Share to social media option
  ///
  /// In en, this message translates to:
  /// **'Social Media'**
  String get shareToSocialMedia;

  /// Download PDF option
  ///
  /// In en, this message translates to:
  /// **'Download PDF'**
  String get downloadPdf;

  /// Notification permission required message
  ///
  /// In en, this message translates to:
  /// **'Notification permission is required'**
  String get notificationPermissionRequired;

  /// Enable notifications button text
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get enableNotifications;

  /// Daily horoscope notification setting
  ///
  /// In en, this message translates to:
  /// **'Daily Horoscope Notification'**
  String get dailyHoroscopeNotification;

  /// Weekly horoscope notification setting
  ///
  /// In en, this message translates to:
  /// **'Weekly Horoscope Notification'**
  String get weeklyHoroscopeNotification;

  /// Celestial events notification setting
  ///
  /// In en, this message translates to:
  /// **'Celestial Events Notification'**
  String get celestialEventsNotification;

  /// Transit analysis button text
  ///
  /// In en, this message translates to:
  /// **'Transit Analysis'**
  String get transitAnalysis;

  /// Coordinates label
  ///
  /// In en, this message translates to:
  /// **'Coordinates'**
  String get coordinates;

  /// Unknown value text
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// Active profile label
  ///
  /// In en, this message translates to:
  /// **'Active Profile'**
  String get activeProfile;

  /// No active profile message
  ///
  /// In en, this message translates to:
  /// **'No Active Profile'**
  String get noActiveProfile;

  /// Create profile button text
  ///
  /// In en, this message translates to:
  /// **'Create Profile'**
  String get createProfile;

  /// Language setting label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Turkish language option
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get turkish;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Cloud sync feature title
  ///
  /// In en, this message translates to:
  /// **'Cloud Sync'**
  String get cloudSync;

  /// Sign in button text
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// Sign out button text
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Backup data button text
  ///
  /// In en, this message translates to:
  /// **'Backup Data'**
  String get backupData;

  /// Restore data button text
  ///
  /// In en, this message translates to:
  /// **'Restore Data'**
  String get restoreData;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
