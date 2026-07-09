import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_am.dart';

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
  static const List<Locale> supportedLocales = <Locale>[Locale('am')];

  /// Application title in Amharic
  ///
  /// In am, this message translates to:
  /// **'የአዳብ ሐዲሶች'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In am, this message translates to:
  /// **'ነብያዊ ሐዲሶች የአደብ ዙሪያ'**
  String get appTagline;

  /// No description provided for @splashLoading.
  ///
  /// In am, this message translates to:
  /// **'በመጫን ላይ…'**
  String get splashLoading;

  /// No description provided for @tapToContinue.
  ///
  /// In am, this message translates to:
  /// **'ለመቀጠል ይንኩ'**
  String get tapToContinue;

  /// No description provided for @dialogOk.
  ///
  /// In am, this message translates to:
  /// **'እሺ'**
  String get dialogOk;

  /// No description provided for @onboardingSkip.
  ///
  /// In am, this message translates to:
  /// **'ዝለል'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In am, this message translates to:
  /// **'ቀጣይ'**
  String get onboardingNext;

  /// No description provided for @onboardingStart.
  ///
  /// In am, this message translates to:
  /// **'ጀምር'**
  String get onboardingStart;

  /// No description provided for @onboardingTitle1.
  ///
  /// In am, this message translates to:
  /// **'አሰላሙ አለይኩም ወረህመቱላሂ ወበረካቱህ'**
  String get onboardingTitle1;

  /// No description provided for @onboardingBody1.
  ///
  /// In am, this message translates to:
  /// **'ስለ ኢስላማዊ አዳብ ከትክክለኛ ነብያዊ ሐዲሶች ይማሩ።'**
  String get onboardingBody1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In am, this message translates to:
  /// **'ኢስላም የእውቀት ሃይማኖት ነው'**
  String get onboardingTitle2;

  /// No description provided for @onboardingBody2.
  ///
  /// In am, this message translates to:
  /// **'በእለት ተእለት ሕይወት ውስጥ መተግበር ያለባቸውን አዳብ ማወቅ አስፈላጊ ነው።'**
  String get onboardingBody2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In am, this message translates to:
  /// **'ተመልሰው ወደ መተግበሪያው ሲመጡ ካቆሙበት ይቀጥሉ'**
  String get onboardingTitle3;

  /// No description provided for @onboardingBody3.
  ///
  /// In am, this message translates to:
  /// **'በማንኛውም ሰአት ከመተግባሪያው ወትጠው ሲመለሱ ከዚ በፊት ያቆሙበት ሐዲስ ላይ መጀመር ይችላሉ።'**
  String get onboardingBody3;

  /// No description provided for @navHome.
  ///
  /// In am, this message translates to:
  /// **'መነሻ'**
  String get navHome;

  /// No description provided for @navChapters.
  ///
  /// In am, this message translates to:
  /// **'ምዕራፎች'**
  String get navChapters;

  /// No description provided for @navBookmarks.
  ///
  /// In am, this message translates to:
  /// **'የተወደዱ'**
  String get navBookmarks;

  /// No description provided for @navProfile.
  ///
  /// In am, this message translates to:
  /// **'መለያ'**
  String get navProfile;

  /// No description provided for @homeGreeting.
  ///
  /// In am, this message translates to:
  /// **'የአዳብ ሐዲሶች'**
  String get homeGreeting;

  /// No description provided for @homeSubtitle.
  ///
  /// In am, this message translates to:
  /// **'በኡስታዝ ዚዳን አባ ሀቢሽ የተዘጋጀ'**
  String get homeSubtitle;

  /// No description provided for @continueReading.
  ///
  /// In am, this message translates to:
  /// **'ካቆሙበት ንባብ ይቀጥሉ'**
  String get continueReading;

  /// No description provided for @continueReadingAction.
  ///
  /// In am, this message translates to:
  /// **'ቀጥል'**
  String get continueReadingAction;

  /// No description provided for @continueReadingHadithNumber.
  ///
  /// In am, this message translates to:
  /// **'ሐዲስ ቁጥር {number}'**
  String continueReadingHadithNumber(int number);

  /// No description provided for @continueReadingHadithOfTotal.
  ///
  /// In am, this message translates to:
  /// **'{current}ኛ ሐዲስ ከ {total}'**
  String continueReadingHadithOfTotal(int current, int total);

  /// No description provided for @exploreChapters.
  ///
  /// In am, this message translates to:
  /// **'ምዕራፎችን ይመልከቱ'**
  String get exploreChapters;

  /// No description provided for @chapterHadithsTitle.
  ///
  /// In am, this message translates to:
  /// **'ሐዲሶች'**
  String get chapterHadithsTitle;

  /// No description provided for @chapterHadithsHint.
  ///
  /// In am, this message translates to:
  /// **'ለንባብ ሐዲስ ይምረጡ'**
  String get chapterHadithsHint;

  /// No description provided for @chapterHadithsEmpty.
  ///
  /// In am, this message translates to:
  /// **'በዚህ ምዕራፍ ሐዲስ የለም'**
  String get chapterHadithsEmpty;

  /// No description provided for @viewAll.
  ///
  /// In am, this message translates to:
  /// **'ሁሉንም ይመልከቱ'**
  String get viewAll;

  /// No description provided for @bookDetailsTitle.
  ///
  /// In am, this message translates to:
  /// **'የመጽሐፍ ዝርዝር'**
  String get bookDetailsTitle;

  /// No description provided for @bookReadableAudible.
  ///
  /// In am, this message translates to:
  /// **'ለንባብና ለመስማት'**
  String get bookReadableAudible;

  /// No description provided for @aboutBook.
  ///
  /// In am, this message translates to:
  /// **'ስለ መጽሐፉ'**
  String get aboutBook;

  /// No description provided for @startReading.
  ///
  /// In am, this message translates to:
  /// **'ንባብ ይጀምሩ'**
  String get startReading;

  /// No description provided for @listenNow.
  ///
  /// In am, this message translates to:
  /// **'አሁን ይስሙ'**
  String get listenNow;

  /// No description provided for @chapterIndexPreview.
  ///
  /// In am, this message translates to:
  /// **'የምዕራፍ ዝርዝር (አጭር)'**
  String get chapterIndexPreview;

  /// No description provided for @chaptersTitle.
  ///
  /// In am, this message translates to:
  /// **'ምዕራፎች'**
  String get chaptersTitle;

  /// No description provided for @searchTitle.
  ///
  /// In am, this message translates to:
  /// **'ፍለጋ'**
  String get searchTitle;

  /// No description provided for @searchEmpty.
  ///
  /// In am, this message translates to:
  /// **'ለመፈለግ ይተይቡ'**
  String get searchEmpty;

  /// No description provided for @searchNoResults.
  ///
  /// In am, this message translates to:
  /// **'ምንም ውጤት አልተገኘም'**
  String get searchNoResults;

  /// No description provided for @bookmarksTitle.
  ///
  /// In am, this message translates to:
  /// **'ዕልባቶች'**
  String get bookmarksTitle;

  /// No description provided for @bookmarksEmpty.
  ///
  /// In am, this message translates to:
  /// **'ገና ዕልባት የለም'**
  String get bookmarksEmpty;

  /// No description provided for @profileTitle.
  ///
  /// In am, this message translates to:
  /// **'መለያ'**
  String get profileTitle;

  /// No description provided for @profileBookSection.
  ///
  /// In am, this message translates to:
  /// **'መጽሐፍ'**
  String get profileBookSection;

  /// No description provided for @profileAppSection.
  ///
  /// In am, this message translates to:
  /// **'መተግበሪያ'**
  String get profileAppSection;

  /// No description provided for @profileViewBook.
  ///
  /// In am, this message translates to:
  /// **'የመጽሐፍ ዝርዝር ይመልከቱ'**
  String get profileViewBook;

  /// No description provided for @profileHadithCount.
  ///
  /// In am, this message translates to:
  /// **'{count} ሐዲስ'**
  String profileHadithCount(int count);

  /// No description provided for @settingsClearCacheHint.
  ///
  /// In am, this message translates to:
  /// **'ንባብ እና ቅንብሮች ይመለሳሉ'**
  String get settingsClearCacheHint;

  /// No description provided for @settingsClearCacheConfirmTitle.
  ///
  /// In am, this message translates to:
  /// **'መሸጎጫ ይጽዳ?'**
  String get settingsClearCacheConfirmTitle;

  /// No description provided for @settingsClearCacheConfirmBody.
  ///
  /// In am, this message translates to:
  /// **'የመተግበሪያ ምርጫዎች እና የንባብ ሂደት ይመለሳሉ።'**
  String get settingsClearCacheConfirmBody;

  /// No description provided for @settingsClearCacheDone.
  ///
  /// In am, this message translates to:
  /// **'መሸጎጫ ተጸድቷል'**
  String get settingsClearCacheDone;

  /// No description provided for @settingsTheme.
  ///
  /// In am, this message translates to:
  /// **'ገጽታ'**
  String get settingsTheme;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In am, this message translates to:
  /// **'ሲስተም'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In am, this message translates to:
  /// **'ብርሃን'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In am, this message translates to:
  /// **'ጨለማ'**
  String get settingsThemeDark;

  /// No description provided for @settingsClearCache.
  ///
  /// In am, this message translates to:
  /// **'መሸጎጫ አጽዳ'**
  String get settingsClearCache;

  /// No description provided for @settingsAbout.
  ///
  /// In am, this message translates to:
  /// **'ስለ መተግበሪያው'**
  String get settingsAbout;

  /// No description provided for @settingsAboutBody.
  ///
  /// In am, this message translates to:
  /// **'አሃዲስ አዳብ — የአዳብ ሐዲሶችን ለንባብና ለመስማት።'**
  String get settingsAboutBody;

  /// No description provided for @readerTitle.
  ///
  /// In am, this message translates to:
  /// **'ንባብ'**
  String get readerTitle;

  /// No description provided for @audioPlaceholder.
  ///
  /// In am, this message translates to:
  /// **'ድምጽ በቅርቡ ይጫናል ኢንሻአላህ'**
  String get audioPlaceholder;

  /// No description provided for @play.
  ///
  /// In am, this message translates to:
  /// **'አጫውት'**
  String get play;

  /// No description provided for @pause.
  ///
  /// In am, this message translates to:
  /// **'አቁም'**
  String get pause;

  /// No description provided for @previousHadith.
  ///
  /// In am, this message translates to:
  /// **'ቀዳሚ'**
  String get previousHadith;

  /// No description provided for @nextHadith.
  ///
  /// In am, this message translates to:
  /// **'ቀጣይ'**
  String get nextHadith;

  /// No description provided for @bookmarkAdd.
  ///
  /// In am, this message translates to:
  /// **'ዕልባት አክል'**
  String get bookmarkAdd;

  /// No description provided for @bookmarkRemove.
  ///
  /// In am, this message translates to:
  /// **'ዕልባት አስወግድ'**
  String get bookmarkRemove;

  /// No description provided for @errorGeneric.
  ///
  /// In am, this message translates to:
  /// **'ስህተት ተከስቷል። እንደገና ይሞክሩ።'**
  String get errorGeneric;

  /// No description provided for @errorLoadBook.
  ///
  /// In am, this message translates to:
  /// **'መጽሐፉን መጫን አልተሳካም።'**
  String get errorLoadBook;

  /// No description provided for @pageNotFound.
  ///
  /// In am, this message translates to:
  /// **'ገጹ አልተገኘም'**
  String get pageNotFound;

  /// No description provided for @minutesShort.
  ///
  /// In am, this message translates to:
  /// **'{count} ደቂቃ'**
  String minutesShort(int count);

  /// No description provided for @chaptersCount.
  ///
  /// In am, this message translates to:
  /// **'+{count} ምዕራፍ'**
  String chaptersCount(int count);

  /// No description provided for @audioHours.
  ///
  /// In am, this message translates to:
  /// **'{count} ሰዓት ድምጽ'**
  String audioHours(int count);
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
      <String>['am'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'am':
      return AppLocalizationsAm();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
