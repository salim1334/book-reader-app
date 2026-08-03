/// Source of truth for all user-visible UI text.
abstract final class AppTexts {
  static const String appName = 'የሳዳት ከማል ኪታቦች';

  // --- app text constants ---

  // Main navigation
  static const String navHome = 'ዋና ገጽ';
  static const String navFavorites = 'የተወደዱ';
  static const String navSettings = 'ማስተካከያዎች';
  // Common dialog actions
  static const String dialogOk = 'እሺ';
  static const String dialogClose = 'ዝጋ';

  // Settings screen
  static const String settingsAppBarTitle = 'ቅንብሮች';
  static const String settingsSectionAppearance = 'ገጽታ';
  static const String settingsSectionReading = 'የንባብ ምርጫዎች';
  static const String settingsSectionAudio = 'የድምጽ ቅንብሮች';
  static const String settingsSectionLibrary = 'ቤተ-መጻሕፍት';
  static const String settingsSectionNotifications = 'ማሳወቂያዎች';
  static const String settingsSectionDataManagement = 'የመረጃ አስተዳደር';
  static const String settingsSectionAbout = 'ስለ መተግበሪያው';
  static const String settingsDarkThemeTitle = 'ጨለማ ገጽታ';
  static const String settingsDarkThemeActive = 'ጨለማ ገጽታ በርቷል';
  static const String settingsLightThemeActive = 'ብሩህ ገጽታ በርቷል';
  static const String settingsFontSizeForPagesTitle = 'የፊደል መጠን ለገጾች';
  static const String settingsAutoScrollTitle = 'በራሱ ማንሸራተት (Auto-Scroll)';
  static const String settingsAutoScrollSubtitle = 'ገጾችን በራሱ ያንሸራትት';
  static const String settingsPageScrollDirectionTitle = 'የገጽ መሸጋገሪያ አቅጣጫ';
  static const String settingsPageScrollVertical = 'ወደላይ ማንሸራተት (Vertical)';
  static const String settingsPageScrollHorizontal = 'አግድም ማንሸራተት (Horizontal)';
  static const String settingsAudioPlayerSpeedTitle = 'የድምጽ ማጫወቻ ፍጥነት';
  static const String settingsAutoPlayNextTitle = 'ቀጣዩን ምዕራፍ በራሱ አጫውት';
  static const String settingsAutoPlayNextSubtitle = 'ቀጣዩን ምዕራፍ በራሱ ያጫውታል';
  static const String settingsOfflineModeTitle = 'ከኢንተርኔት ውጭ (Offline)';
  static const String settingsOfflineModeSubtitle = 'የወረዱትን ብቻ አሳይ';
  static const String settingsAutoDownloadTitle = 'በራሱ አውርድ';
  static const String settingsAutoDownloadSubtitle = 'አዳዲስ ምዕራፎችን በራሱ ያወርዳል';
  static const String settingsStorageTitle = 'ማከማቻ';
  static const String settingsStorageSubtitle = 'የወረዱትን ያስተዳድሩ';
  static const String settingsNotifyNewBooksTitle = 'አዳዲስ መጻሕፍት';
  static const String settingsNotifyNewBooksSubtitle = 'አዳዲስ መጻሕፍት ሲጫኑ አሳውቀኝ';
  static const String settingsNotifyUpdatesTitle = 'ማሻሻያዎች';
  static const String settingsNotifyUpdatesSubtitle = 'ማሻሻያዎች ሲኖሩ አሳውቀኝ';
  static const String settingsResetReadingProgressTitle = 'የንባብ ሂደትን ሰርዝ';
  static const String settingsResetReadingProgressSubtitle = 'የሁሉንም መጻሕፍት እና ምዕራፎች የንባብ ሂደት ያጠፋል።';
  static const String settingsAboutAppTitle = 'ስለዚህ መተግበሪያ';
  static const String settingsAppVersion = 'Version 1.0.1';
  static const String settingsFontSizeDialogTitle = 'የፊደል መጠን';
  static const String settingsPlayerSpeedDialogTitle = 'የመጫወቻ ፍጥነት';
  static const String settingsUsedStorageTitle = 'ያገለገለ ማከማቻ';
  static const String settingsStorageUsed = '245 MB';
  static const String settingsClearAllDownloadsTitle = 'የወረዱትን በሙሉ አጥፋ';
  static String settingsFontSizePercent(int percent) => '$percent%';
  static String settingsFontSizeSample(int percent) => 'የናሙና ጽሑፍ መጠን: $percent%';
  static String playerSpeedValue(double speed) => '${speed}x';
  
  // Settings controller
  static const String settingsFontSizeSmall = 'ትንሽ';
  static const String settingsFontSizeMedium = 'መካከለኛ';
  static const String settingsFontSizeLarge = 'ትልቅ';
  static const String settingsTestNotificationMessage =
      'የሙከራ ማሳወቂያ ተልኳል። ማሳወቂያዎችዎን ያረጋግጡ።';
  static const String settingsResetProgressDialogTitle =
      'የንባብ ሂደት እንደ አዲስ ይጀመር?';
  static const String settingsResetProgressDialogBody =
      'ይህ ሁሉንም የንባብ ሂደቶች ያጠፋል፤ አንዴ ከተሰረዘም መመለስ አይቻልም።';
  static const String dialogCancel = 'ሰርዝ';
  static const String dialogReset = 'እንደ አዲስ ጀምር';
  static const String settingsReadingProgressResetMessage =
      'የንባብ ሂደት እንደ አዲስ ተጀምሯል።';
  static const String settingsClearDownloadsDialogTitle = 'የወረዱ ፋይሎች ይሰረዙ?';
  static const String settingsClearDownloadsDialogBody =
      'ይህ ሁሉንም የወረዱ መጽሐፍት እና የሚዲያ ፋይሎችን ያጠፋል።';
  static const String dialogClear = 'አጥፋ';
  static const String settingsDownloadsClearedMessage =
      'የወረዱ ይዘቶች ጠፍተዋል።';
  static const String settingsCacheClearedMessage = 'መሸጎጫው (Cache) ጸድቷል።';

  // About screen
  static const String aboutAppBarTitle = 'ስለ አፕሊኬሽኑ';
  static const String aboutAppName = 'የሳዳት ከማል መጽሐፍት';
  static const String aboutAppTagline =
      'የሳዳት ከማል (አቡ መርየም) ኪታቦች (ደርሶች) የሚለቀቁበት የሞባይል መተግበሪያ';
  static const String aboutSectionAboutApp = 'ስለ አፕሊኬሽኑ';
  static const String aboutFeatureOffline =
      'የተለያዩ ኪታቦችን ከድምጽ ጋረ ከኢንተርኔት ውጭ የሚሰራ አፕልኬሽን።';
  static const String aboutFeatureReadListenTrack =
      'መጽሐፍትን በቀላሉ ያንብቡ፣ ያዳምጡ እና የደረሱበትን ደረጃ ይከታተሉ';
  static const String aboutFeatureIslamicCollection =
      'በኡስታዝ ሳዳት ከማል የተዘጋጁ የኢስላማዊ ጽሑፎች ስብስብ።';
  static const String aboutFeatureAudio =
      'ከጽሁፉ ጋር አንድላይ የሚገኝ የድምጽ ቅጂ';
  static const String aboutFeatureAutoPage =
      'እጅ ሳይጠቀሙ ለማንበብ የሚረዳ የራስ-ሰር ገጽ የመቀያየር ሁኔታ።';
  static const String aboutFeatureSpeed =
      'ለድምጽ ምዕራፎች የሚቀያየር የማጫወቻ ፍጥነት።';
  static const String aboutSectionCredits = 'ያበለጸገው';
  static const String aboutCreditCompany = 'በአላርም ቴክኖሎጂ የበለጸገ';
  static const String aboutEmail = 'alarmtechsolution9@gmail.com';
  static const String aboutPhone1 = '0933330933';
  static const String aboutPhone2 = '0933313133';
  static String get aboutFooter =>
      '© ${DateTime.now().year} አላርም ቴክኖሎጂ። መብቱ በህግ የተጠበቀ ነው።';

  // Feedback
  static const String feedbackSectionTitle = 'ድጋፍ';
  static const String feedbackButtonTitle = 'አስተያየት ይላኩ';
  static const String feedbackButtonSubtitle =
      'መሳሪያ መረጃ እና የመተግበሪያ ስሪት ይጨምራል';
  static const String feedbackEmailSubject =
      'አስተያየት - የሳዳት ከማል መጽሐፍ ማንበቢያ';
  static String feedbackEmailBody(
    String appVersion,
    String deviceInfo,
  ) =>
      'ሰላም፣\n\n'
      'ለመተግበሪያው ያለዎትን አስተያየት ወይም የሚያጋጥምዎትን ችግር ከታች ያለው ቦታ በመጠቀም ይጻፉልን።\n\n'
      'የመተግበሪያ ስሪት፦ $appVersion\n'
      'የመሳሪያ መረጃ፦ $deviceInfo\n\n'
      'አስተያየት / ችግር፦\n';
  static const String feedbackNoEmailApp =
      'በዚህ መሳሪያ ላይ የኢሜይል መተግበሪያ አልተገኘም።';
  static const String feedbackOpenError =
      'የአስተያየት ኢሜይሉን መክፈት አልተቻለም። እባክዎ በኋላ እንደገና ይሞክሩ።';
  static const String feedbackVersionFallback = 'Version 1.0.1';
  static const String feedbackDeviceFallback = 'ያልታወቀ መሳሪያ';

  // Downloads
  static const String downloadsAppBarTitle = 'የወረዱ መጽሐፍት';
  static const String downloadsEmptyMessage = 'እስካሁን ምንም አልወረደም።';
  static const String downloadsQueueHeader = 'የማውረድ ተራ';
  static const String downloadsUnknownStatus = 'ያልታወቀ';
  static String downloadsChapterTitle(String id, bool truncated) =>
      truncated ? 'ምዕራፍ ${id.substring(0, 8)}...' : 'ምዕራፍ $id';
  static String downloadsBookTitle(String id, bool truncated) =>
      truncated ? 'መጽሐፍ ${id.substring(0, 8)}...' : 'መጽሐፍ $id';
  static const String downloadsRetryCountLabel = 'ድጋሚ ሙከራዎች:';
  static String downloadsQueueItemSubtitle(
    String chapterTitle,
    String statusLabel,
    double progress,
    int retryCount,
  ) =>
      '$chapterTitle • $statusLabel • ${percentage(progress)} • $downloadsRetryCountLabel $retryCount';
  static const String downloadsRetryTooltip = 'ድጋሜ ይሞክሩ';
  static const String downloadsCancelTooltip = 'አቋርጥ';
  static const String downloadsRemoveTooltip = 'አስወግድ';
  static String downloadsBookProgress(
    String type,
    int downloaded,
    int total,
  ) =>
      '$type • $downloaded / $total ምዕራፍ ተወርዋል';
  static const String downloadsSyncing = 'በማውረድ ላይ...';
  static String downloadsSyncStateWithProgress(
    String stateName,
    double progress,
  ) =>
      '$stateName... ${percentage(progress)}';
  static String downloadsSyncState(String stateName) => '$stateName...';

  // Downloads controller
  static const String downloadsLoadError =
      'ማውረድ አልተቻለም ድጋሜ ይሞክሩ';
  static const String downloadsChapterError =
      'ምዕራፍ ማውረድ አልተቻለም ድጋሜ ይሞክሩ';
  static const String downloadsDeleteBookDialogTitle =
      'የወረደውን መጽሐፍ ይጥፉ?';
  static String downloadsDeleteBookBody(String title) =>
      '"$title" እና የሚመለከተው ፋይሎች ይጠፋሉ።';
  static const String downloadsDeleteBookCancel = 'ይቅር';
  static const String downloadsDeleteBookConfirm = 'አጥፋ';
  static const String downloadsStatusCompleted = 'አልቋል';
  static const String downloadsStatusFailed = 'አልተሳካም';
  static const String downloadsStatusDownloading = 'በማውረድ ላይ';
  static const String downloadsStatusPending = 'በተራ ላይ';
  // General helpers
  static String percentage(double value) =>
      '${(value * 100).toStringAsFixed(0)}%';

  // Home
  static const String homeTitle = 'ኢስላማዊ መጽሐፍት';
  static const String homeSubtitle = 'የሳዳት ከማል ኪታቦች';
  static const String homeEmptyOffline =
      'በአሁኑ ጊዜ ከኔትዎርክ ውጭ ነዎት። ሌሎች የሳዳት ከማልን መጻሕፍትን ለማየት እና ለማውረድ እባክዎ ከኢንተርኔት ጋር ይገናኙ።';
  static const String homeEmptyNoBooks = 'ምንም መጻሕፍት አልተገኙም።';
  static const String homeContinueReadingTitle = 'ማንበብ ይቀጥሉ';
  static const String homeContinueReadingCompleted = 'ተጠናቋል';
  static const String homeRefreshCatalogError = 'ካታሎጉን ማደስ አልተቻለም፦  ';
  static String homeBookDownloaded(String title) => '$title ወርዷል';
  static const String homeDownloadFailed = 'ማውረድ አልተሳካም: ';

  // Book details
  static const String bookDetailsFavoriteTooltip = 'የተወደደ';
  static const String bookDetailsChaptersTitle = 'ምዕራፎች';
  static const String bookDetailsEmptyChapters = 'ምንም ምዕራፍ አልተጫነም';
  static const String bookTypeText = 'ጽሁፍ';
  static const String bookTypeImage = 'ምስል';
  static const String bookDetailsProgressLabel = 'የንባብ ደረጃ';
  static const String bookDetailsUpdateAvailable = 'አዲስ ስሪት ተገኝቷል';
  static const String bookDetailsUpdateBody =
      'የቅርብ ለውጦችን ለማውረድ ማሻሻያ ይጫኑ።';
  static const String bookDetailsUpdateButton = 'UPDATE';
  static const String bookDetailsUpdateSuccess = 'ማሻሻያው ወርዷል';
  static String bookDetailsChapterDownloaded(String title) => '$title ወርዷል';
  static const String bookDetailsUpdateError =
      'ማሻሻያ ማውረድ አልተቻለም ድጋሜ ይሞክሩ';
  static const String bookDetailsDownloadError =
      'ማውረድ አልተሳካም ድጋሜ ይሞክሩ';
  static const String bookDetailsChapterNotDownloaded =
      'ይህን ምዕራፍ ለማንበብ ያውረዱት';

  // Search
  static const String searchHint =
      'መጻሕፍትን ወይም ምዕራፎችን ይፈልጉ...';
  static const String searchEmptyQuery =
      'ለመፈለግ የመጽሐፍ ወይም የምዕራፍ ርዕስ ይጻፉ።';
  static String searchNoResults(String query) =>
      'ለ"$query" ምንም ውጤት አልተገኘም።';
  static const String searchBooksSection = 'መጻሕፍት';
  static const String searchChaptersSection = 'ምዕራፎች';
  static String searchBookIdLabel(String id) =>
      'የመጽሐፍ መታወቂያ: $id';
  static String sectionTitleWithCount(String title, int count) =>
      '$title ($count)';

  // Favorites
  static const String favoritesAppBarTitle = 'የተወደዱ';
  static const String favoritesBooksTab = 'መጽሐፍት';
  static const String favoritesChaptersTab = 'ምዕራፎች';
  static const String favoritesPagesTab = 'ገጾች';
  static const String favoritesEmptyBooks =
      'እስካሁን የተመረጡ መጽሐፍት የሉም።';
  static const String favoritesEmptyChapters =
      'እስካሁን የተመረጡ ምዕራፎች የሉም።';
  static const String favoritesEmptyPages =
      'እስካሁን የተመረጡ ገጾች የሉም።';
  static const String favoritesBookFallback = 'መጽሐፍ';
  static const String favoritesChapterFallback = 'ምዕራፍ';
  static String favoritesPageTitle(String bookTitle, String chapterTitle) =>
      '$bookTitle - $chapterTitle';
  static String favoritesPageNumber(int page) => 'ገጽ $page';
  static String favoritesBookIdLabel(String id) => 'መጽሐፍ መታወቂያ: $id';

  // Onboarding
  static const String onboardingTitle =
      'በዚ አፕሊኬሽን የሳዳት ከማል ኪታቦችን ያገኛሉ';
  static const String onboardingBody =
      'አዳዲስ ኪታቦች ሲጨመሩ የማሳወቂያ መልዕክት እንዲደርሶ የኖትፍኬሽን ፍቃድ ለአፕልኬሽኑ ይስጡ።';
  static const String onboardingStartButton = 'ጀምር';

  // Chapter reader
  static const String chapterReaderScrollDirectionTooltip =
      'የማሸጋገሪያ አቅጣጫ ቀይር';
  static const String chapterReaderImmersiveTooltip =
      'ሙሉ ገጽ መቀየሪያ';
  static String textReaderProgressPercent(int progress) => '$progress%';
  static String textReaderPageIndicator(int current, int total) =>
      'Page $current of $total';
  static const String imageReaderNoImages =
      'ለዚህ ምዕራፍ ምንም የወረደ ምስል የለም';
  static String imageReaderPageIndicator(int current, int total) =>
      '$current / $total';
  static const String chapterReaderNextNotDownloaded =
      'ቀጣዩ ምዕራፍ አልወረደም ያውርዱት።';
  static const String chapterReaderPreviousNotDownloaded =
      'ቀዳሚው ምዕራፍ አልወረደም ያውርዱት';

  // Common widgets
  static const String commonErrorViewRetry = 'ደግመህ ሞክር';
  static const String bookCardDownloadPrompt =
      'መጽሐፉን ለማውረድ ይጫኑት';
  static const String chapterListTileDownloaded = 'ወርዷል';
  static const String chapterListTileDownloadPrompt =
      'ለማውረድ ይጫኑት';
  static String chapterListTileProgress(double progress) =>
      '${percentage(progress)} ተጠናቋል';

  // Audio player
  static const String audioPlayerBack10 = '10 ሰከንድ ወደኋላ';
  static const String audioPlayerPrevChapter = 'ቀዳሚ ምዕራፍ';
  static const String audioPlayerNextChapter = 'ቀጣይ ምዕራፍ';
  static const String audioPlayerForward10 = '10 ሰከንድ ወደፊት';
  static const String audioPlayerSpeedTooltip = 'የማጫወቻ ፍጥነት';
  static const String audioPlayerVolumeTooltip = 'የድምጽ መጠን';
  static String audioPlayerMiniSubtitle(
    String chapterTitle,
    String remaining,
  ) =>
      '$chapterTitle • $remaining ይቀራል';
  static String audioPlayerSpeedLabel(double speed) =>
      '${speed.toStringAsFixed(2)}x';

  // App / splash
  static const String appWindowTitle = 'መጽሐፍ ማንበቢያ';
  static const String splashTagline = """ 
እውቀትን ማስፋፋት፣ ኢማንን ማጠናከር
رَبِّ زِدْنِي عِلْمًا
"ጌታዬ ሆይ፣ እውቀቴን ጨምርልኝ።" 
                """;

  // Snackbar / notification helpers
  static const String snackErrorTitle = 'ስህተት';
  static const String snackNoticeTitle = 'ማሳሰቢያ';

  // Exceptions
  static const String storageFullMessage =
      'በቂ የማከማቻ ቦታ የለም። ቦታ በማስለቀቅ እንደገና ይሞክሩ።';

  // Local notifications
  static const String notificationChannelTest = 'የሙከራ ማሳወቂያዎች';
  static const String notificationChannelTestDesc =
      'የውስጥ ማሳወቂያዎች በትክክል እየሰሩ መሆናቸውን ለማረጋገጥ ይጠቅማል።';
  static const String notificationTestTitle = 'የሙከራ ማሳወቂያ';
  static const String notificationTestBody =
      'ማሳወቂያዎችዎ በትክክል እየሰሩ ነው!';
  static const String notificationChannelNewBooks = 'አዳዲስ መጽሐፍት';
  static const String notificationChannelNewBooksDesc =
      'አዲስ ለታተሙ መጽሐፍት የሚላኩ ማሳወቂያዎች።';
  static const String notificationNewBookTitle = 'አዲስ መጽሐፍ ተጭኗል';
  static String notificationNewBookBody(String title) =>
      '"$title" ወደ መጽሐፍት ዝርዝር ተጨምሯል።';
  static const String notificationChannelUpdates = 'ማሻሻያዎች';
  static const String notificationChannelUpdatesDesc =
      'የመጽሐፍ እና የምዕራፍ ማሻሻያ ማሳወቂያዎች።';
  static const String notificationUpdateTitle = 'ይዘቱ ተሻሽሏል';
  static String notificationUpdateBody(String title) =>
      '"$title" ተሻሽሏል።';
  static const String audioServiceChannelName = 'የድምጽ ማጫወቻ';
}
