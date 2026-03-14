import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_zh.dart';

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
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('pt'),
    Locale('ru'),
    Locale('tr'),
    Locale('zh')
  ];

  /// The app title displayed in the app bar
  ///
  /// In en, this message translates to:
  /// **'Motiva'**
  String get appTitle;

  /// Button text to view the meaning of a quote
  ///
  /// In en, this message translates to:
  /// **'View Meaning'**
  String get viewMeaning;

  /// Button text to share a quote
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// Button text to retry a failed operation
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Button text to save settings
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Button text to cancel an action
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Button text to apply a selection
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// Settings screen title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Language setting label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Widget customization screen title
  ///
  /// In en, this message translates to:
  /// **'Widget Appearance'**
  String get widgetAppearance;

  /// Quote detail screen title
  ///
  /// In en, this message translates to:
  /// **'Quote Meaning'**
  String get quoteMeaning;

  /// Section title for quote meaning explanation
  ///
  /// In en, this message translates to:
  /// **'What This Means'**
  String get whatThisMeans;

  /// Toggle title for glass effect on widget
  ///
  /// In en, this message translates to:
  /// **'Frosted Glass Effect'**
  String get frostedGlassEffect;

  /// Description for frosted glass effect toggle
  ///
  /// In en, this message translates to:
  /// **'Use a crystallized glass-like background'**
  String get frostedGlassDescription;

  /// Background color picker title
  ///
  /// In en, this message translates to:
  /// **'Background Color'**
  String get backgroundColor;

  /// Text color picker title
  ///
  /// In en, this message translates to:
  /// **'Text Color'**
  String get textColor;

  /// Subtitle indicating color picker can be tapped
  ///
  /// In en, this message translates to:
  /// **'Tap to change'**
  String get tapToChange;

  /// Subtitle when background color is disabled
  ///
  /// In en, this message translates to:
  /// **'Disabled when glass effect is on'**
  String get disabledWhenGlassOn;

  /// Snackbar message after widget settings are saved
  ///
  /// In en, this message translates to:
  /// **'Widget updated successfully'**
  String get widgetUpdatedSuccessfully;

  /// Info message about widget updates
  ///
  /// In en, this message translates to:
  /// **'After saving, you may need to remove and re-add the widget on your home screen to see the changes.'**
  String get widgetInfoMessage;

  /// Share bottom sheet title
  ///
  /// In en, this message translates to:
  /// **'Share Quote'**
  String get shareQuote;

  /// Instagram share option label
  ///
  /// In en, this message translates to:
  /// **'Instagram'**
  String get instagram;

  /// Twitter share option label
  ///
  /// In en, this message translates to:
  /// **'Twitter'**
  String get twitter;

  /// WhatsApp share option label
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get whatsapp;

  /// More share options label
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// Color picker sheet title
  ///
  /// In en, this message translates to:
  /// **'Select Color'**
  String get selectColor;

  /// English language name
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Turkish language name
  ///
  /// In en, this message translates to:
  /// **'Türkçe'**
  String get turkish;

  /// German language name
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get german;

  /// Russian language name
  ///
  /// In en, this message translates to:
  /// **'Русский'**
  String get russian;

  /// Spanish language name
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get spanish;

  /// French language name
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get french;

  /// Portuguese language name
  ///
  /// In en, this message translates to:
  /// **'Português'**
  String get portuguese;

  /// Italian language name
  ///
  /// In en, this message translates to:
  /// **'Italiano'**
  String get italian;

  /// Arabic language name
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// Chinese language name
  ///
  /// In en, this message translates to:
  /// **'中文'**
  String get chinese;

  /// Japanese language name
  ///
  /// In en, this message translates to:
  /// **'日本語'**
  String get japanese;

  /// Korean language name
  ///
  /// In en, this message translates to:
  /// **'한국어'**
  String get korean;

  /// Hindi language name
  ///
  /// In en, this message translates to:
  /// **'हिन्दी'**
  String get hindi;

  /// Subject text when sharing a quote
  ///
  /// In en, this message translates to:
  /// **'Daily Stoic Quote'**
  String get dailyStoicQuote;

  /// Languages tab title
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get languages;

  /// Notifications tab title
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Appearance tab title
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// Toggle label for enabling notifications
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get enableNotifications;

  /// Label for notification time picker
  ///
  /// In en, this message translates to:
  /// **'Notification Time'**
  String get notificationTime;

  /// Section title for daily notification settings
  ///
  /// In en, this message translates to:
  /// **'Daily Reminder'**
  String get dailyReminder;

  /// Subtitle for notification toggle
  ///
  /// In en, this message translates to:
  /// **'Receive a stoic quote every day'**
  String get receiveQuoteDaily;

  /// Section title for theme settings
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeMode;

  /// System theme option
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemTheme;

  /// Light theme option
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightTheme;

  /// Dark theme option
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkTheme;

  /// Onboarding page 1 title
  ///
  /// In en, this message translates to:
  /// **'Welcome to Motiva'**
  String get onboardingWelcomeTitle;

  /// Onboarding page 1 description
  ///
  /// In en, this message translates to:
  /// **'Your daily source of stoic wisdom to inspire and guide you through life\'s journey.'**
  String get onboardingWelcomeDescription;

  /// Onboarding page 2 title
  ///
  /// In en, this message translates to:
  /// **'Choose Your Language'**
  String get onboardingLanguageTitle;

  /// Onboarding page 2 description
  ///
  /// In en, this message translates to:
  /// **'Select your preferred language for quotes and the app interface.'**
  String get onboardingLanguageDescription;

  /// Onboarding page 3 title
  ///
  /// In en, this message translates to:
  /// **'You\'re All Set!'**
  String get onboardingReadyTitle;

  /// Onboarding page 3 description
  ///
  /// In en, this message translates to:
  /// **'Start receiving daily stoic quotes to inspire your journey.'**
  String get onboardingReadyDescription;

  /// Onboarding get started button text
  ///
  /// In en, this message translates to:
  /// **'Start Your Journey'**
  String get onboardingGetStarted;

  /// Onboarding next button text
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// Favorites screen title
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// Empty favorites title
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get noFavorites;

  /// Empty favorites description
  ///
  /// In en, this message translates to:
  /// **'Tap the heart icon on a quote to save it here.'**
  String get noFavoritesDescription;

  /// Snackbar message when a quote is favorited
  ///
  /// In en, this message translates to:
  /// **'Added to favorites'**
  String get addedToFavorites;

  /// Snackbar message when a quote is unfavorited
  ///
  /// In en, this message translates to:
  /// **'Removed from favorites'**
  String get removedFromFavorites;

  /// Font section title in settings
  ///
  /// In en, this message translates to:
  /// **'Font'**
  String get font;

  /// Widget font picker title
  ///
  /// In en, this message translates to:
  /// **'Widget Font'**
  String get widgetFont;

  /// Font picker sheet title
  ///
  /// In en, this message translates to:
  /// **'Select Font'**
  String get selectFont;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'ar',
        'de',
        'en',
        'es',
        'fr',
        'hi',
        'it',
        'ja',
        'ko',
        'pt',
        'ru',
        'tr',
        'zh'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'tr':
      return AppLocalizationsTr();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
