import 'package:book_store/features/audio_player/bindings/audio_player_binding.dart';
import 'package:book_store/features/audio_player/screens/audio_player_screen.dart';
import 'package:book_store/features/book_details/bindings/book_details_binding.dart';
import 'package:book_store/features/book_details/screens/book_details_screen.dart';
import 'package:book_store/features/chapter_reader/bindings/chapter_reader_binding.dart';
import 'package:book_store/features/chapter_reader/screens/chapter_reader_screen.dart';
import 'package:book_store/features/downloads/bindings/downloads_binding.dart';
import 'package:book_store/features/downloads/screens/downloads_screen.dart';
import 'package:book_store/features/home/bindings/home_binding.dart';
import 'package:book_store/features/home/screens/home_screen.dart';
import 'package:book_store/features/main_navigation/bindings/main_navigation_binding.dart';
import 'package:book_store/features/main_navigation/screens/main_navigation_screen.dart';
import 'package:book_store/features/onboarding/bindings/onboarding_binding.dart';
import 'package:book_store/features/onboarding/screens/onboarding_screen.dart';
import 'package:book_store/features/settings/bindings/settings_binding.dart';
import 'package:book_store/features/settings/screens/settings_screen.dart';
import 'package:book_store/features/splash/bindings/splash_binding.dart';
import 'package:book_store/features/splash/screens/splash_screen.dart';
import 'package:book_store/routes/app_routes.dart';
import 'package:get/get.dart';

class AppPages {
  AppPages._();

  static final List<GetPage> pages = [
    GetPage(
      name: Routes.splash,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.onboarding,
      page: () => const OnboardingScreen(),
      binding: OnboardingBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.main,
      page: () => const MainNavigationScreen(),
      binding: MainNavigationBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.home,
      page: () => const HomeScreen(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.bookDetails,
      page: () => const BookDetailsScreen(),
      binding: BookDetailsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.chapterReader,
      page: () => const ChapterReaderScreen(),
      binding: ChapterReaderBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.downloads,
      page: () => const DownloadsScreen(),
      binding: DownloadsBinding(),
    ),
    GetPage(
      name: Routes.audioPlayer,
      page: () => const AudioPlayerScreen(),
      binding: AudioPlayerBinding(),
      transition: Transition.upToDown,
    ),
    GetPage(
      name: Routes.settings,
      page: () => const SettingsScreen(),
      binding: SettingsBinding(),
    ),
  ];
}
