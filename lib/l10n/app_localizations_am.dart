// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Amharic (`am`).
class AppLocalizationsAm extends AppLocalizations {
  AppLocalizationsAm([String locale = 'am']) : super(locale);

  @override
  String get appName => 'የአዳብ ሐዲሶች';

  @override
  String get appTagline => 'ነብያዊ ሐዲሶች የአደብ ዙሪያ';

  @override
  String get splashLoading => 'በመጫን ላይ…';

  @override
  String get tapToContinue => 'ለመቀጠል ይንኩ';

  @override
  String get dialogOk => 'እሺ';

  @override
  String get onboardingSkip => 'ዝለል';

  @override
  String get onboardingNext => 'ቀጣይ';

  @override
  String get onboardingStart => 'ጀምር';

  @override
  String get onboardingTitle1 => 'አሰላሙ አለይኩም ወረህመቱላሂ ወበረካቱህ';

  @override
  String get onboardingBody1 => 'ስለ ኢስላማዊ አዳብ ከትክክለኛ ነብያዊ ሐዲሶች ይማሩ።';

  @override
  String get onboardingTitle2 => 'ኢስላም የእውቀት ሃይማኖት ነው';

  @override
  String get onboardingBody2 =>
      'በእለት ተእለት ሕይወት ውስጥ መተግበር ያለባቸውን አዳብ ማወቅ አስፈላጊ ነው።';

  @override
  String get onboardingTitle3 => 'ተመልሰው ወደ መተግበሪያው ሲመጡ ካቆሙበት ይቀጥሉ';

  @override
  String get onboardingBody3 =>
      'በማንኛውም ሰአት ከመተግባሪያው ወትጠው ሲመለሱ ከዚ በፊት ያቆሙበት ሐዲስ ላይ መጀመር ይችላሉ።';

  @override
  String get navHome => 'መነሻ';

  @override
  String get navChapters => 'ምዕራፎች';

  @override
  String get navBookmarks => 'የተወደዱ';

  @override
  String get navProfile => 'መለያ';

  @override
  String get homeGreeting => 'የአዳብ ሐዲሶች';

  @override
  String get homeSubtitle => 'በኡስታዝ ዚዳን አባ ሀቢሽ የተዘጋጀ';

  @override
  String get continueReading => 'ካቆሙበት ንባብ ይቀጥሉ';

  @override
  String get continueReadingAction => 'ቀጥል';

  @override
  String continueReadingHadithNumber(int number) {
    return 'ሐዲስ ቁጥር $number';
  }

  @override
  String continueReadingHadithOfTotal(int current, int total) {
    return '$currentኛ ሐዲስ ከ $total';
  }

  @override
  String get exploreChapters => 'ምዕራፎችን ይመልከቱ';

  @override
  String get chapterHadithsTitle => 'ሐዲሶች';

  @override
  String get chapterHadithsHint => 'ለንባብ ሐዲስ ይምረጡ';

  @override
  String get chapterHadithsEmpty => 'በዚህ ምዕራፍ ሐዲስ የለም';

  @override
  String get viewAll => 'ሁሉንም ይመልከቱ';

  @override
  String get bookDetailsTitle => 'የመጽሐፍ ዝርዝር';

  @override
  String get bookReadableAudible => 'ለንባብና ለመስማት';

  @override
  String get aboutBook => 'ስለ መጽሐፉ';

  @override
  String get startReading => 'ንባብ ይጀምሩ';

  @override
  String get listenNow => 'አሁን ይስሙ';

  @override
  String get chapterIndexPreview => 'የምዕራፍ ዝርዝር (አጭር)';

  @override
  String get chaptersTitle => 'ምዕራፎች';

  @override
  String get searchTitle => 'ፍለጋ';

  @override
  String get searchEmpty => 'ለመፈለግ ይተይቡ';

  @override
  String get searchNoResults => 'ምንም ውጤት አልተገኘም';

  @override
  String get bookmarksTitle => 'ዕልባቶች';

  @override
  String get bookmarksEmpty => 'ገና ዕልባት የለም';

  @override
  String get profileTitle => 'መለያ';

  @override
  String get profileBookSection => 'መጽሐፍ';

  @override
  String get profileAppSection => 'መተግበሪያ';

  @override
  String get profileViewBook => 'የመጽሐፍ ዝርዝር ይመልከቱ';

  @override
  String profileHadithCount(int count) {
    return '$count ሐዲስ';
  }

  @override
  String get settingsClearCacheHint => 'ንባብ እና ቅንብሮች ይመለሳሉ';

  @override
  String get settingsClearCacheConfirmTitle => 'መሸጎጫ ይጽዳ?';

  @override
  String get settingsClearCacheConfirmBody =>
      'የመተግበሪያ ምርጫዎች እና የንባብ ሂደት ይመለሳሉ።';

  @override
  String get settingsClearCacheDone => 'መሸጎጫ ተጸድቷል';

  @override
  String get settingsTheme => 'ገጽታ';

  @override
  String get settingsThemeSystem => 'ሲስተም';

  @override
  String get settingsThemeLight => 'ብርሃን';

  @override
  String get settingsThemeDark => 'ጨለማ';

  @override
  String get settingsClearCache => 'መሸጎጫ አጽዳ';

  @override
  String get settingsAbout => 'ስለ መተግበሪያው';

  @override
  String get settingsAboutBody => 'አሃዲስ አዳብ — የአዳብ ሐዲሶችን ለንባብና ለመስማት።';

  @override
  String get readerTitle => 'ንባብ';

  @override
  String get audioPlaceholder => 'ድምጽ በቅርቡ ይጫናል ኢንሻአላህ';

  @override
  String get play => 'አጫውት';

  @override
  String get pause => 'አቁም';

  @override
  String get previousHadith => 'ቀዳሚ';

  @override
  String get nextHadith => 'ቀጣይ';

  @override
  String get bookmarkAdd => 'ዕልባት አክል';

  @override
  String get bookmarkRemove => 'ዕልባት አስወግድ';

  @override
  String get errorGeneric => 'ስህተት ተከስቷል። እንደገና ይሞክሩ።';

  @override
  String get errorLoadBook => 'መጽሐፉን መጫን አልተሳካም።';

  @override
  String get pageNotFound => 'ገጹ አልተገኘም';

  @override
  String minutesShort(int count) {
    return '$count ደቂቃ';
  }

  @override
  String chaptersCount(int count) {
    return '+$count ምዕራፍ';
  }

  @override
  String audioHours(int count) {
    return '$count ሰዓት ድምጽ';
  }
}
