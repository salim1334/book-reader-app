import 'package:book_store/common/widgets/book_card.dart';
import 'package:book_store/common/widgets/error_view.dart';
import 'package:book_store/common/widgets/loading_indicator.dart';
import 'package:book_store/core/constants/app_texts.dart';
import 'package:book_store/data/remote/sync_manager.dart';
import 'package:book_store/data/repositories/settings_repository.dart';
import 'package:book_store/features/home/controllers/home_controller.dart';
import 'package:book_store/features/home/widgets/continue_reading_card.dart';
import 'package:book_store/features/home/widgets/home_empty_state.dart';
import 'package:book_store/features/home/widgets/more_books_banner.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  // on init check if there's any change in continue reaing and refresh nessaryparts
  // @override
  // void onInit() {
  //   super.onInit();
  //   controller.checkContinueReading();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingIndicator();
        }

        final error = controller.errorMessage.value;
        if (error != null) {
          return ErrorView(message: error, onRetry: controller.loadBooks);
        }

        final hasContinue =
            controller.continueReading.value != null &&
            controller.books.isNotEmpty;

        if (controller.books.isEmpty) {
          return RefreshIndicator(
            onRefresh: controller.checkForBooks,
            child: HomeEmptyState(
              isChecking: controller.isCheckingForBooks.value,
              onCheckForBooks: controller.checkForBooks,
            ),
          );
        }

        final showBanner = controller.showMoreBooksHint.value;

        return RefreshIndicator(
          onRefresh: controller.autoSync,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Sticky Header that shrinks on scroll
              SliverAppBar(
                pinned: true,
                floating: false,
                elevation: 0,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                surfaceTintColor: Colors.transparent,
                expandedHeight: 120,
                flexibleSpace: FlexibleSpaceBar(
                  background: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 50, 24, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          AppTexts.homeTitle,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          AppTexts.homeSubtitle,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () => Get.toNamed(Routes.search),
                  ),
                  Obx(() {
                    final settingsController = Get.find<SettingsRepository>();
                    return IconButton(
                      icon: Icon(
                        settingsController.themeMode.value == ThemeMode.dark
                            ? Icons.dark_mode_rounded
                            : Icons.light_mode_rounded,
                      ),
                      onPressed: () => settingsController.setThemeMode(
                        settingsController.themeMode.value == ThemeMode.light
                            ? ThemeMode.dark
                            : ThemeMode.light,
                      ),
                    );
                  }),
                  const SizedBox(width: 8),
                ],
              ),

              // "More books online" hint
              SliverToBoxAdapter(
                child: MoreBooksBanner(showMoreBooks: showBanner),
              ),

              // Continue Reading
              if (hasContinue)
                SliverToBoxAdapter(
                  child: ContinueReadingCard(
                    reading: controller.continueReading.value!,
                    onTap: controller.openContinueReading,
                    progress:
                        controller.bookProgress[controller
                            .continueReading
                            .value!
                            .book
                            .id] ??
                        0.0,
                  ),
                ),

              // Books List
              SliverPadding(
                padding: const EdgeInsets.only(bottom: 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final book = controller.books[index];

                    return Obx(() {
                      final isDownloaded =
                          controller.downloadedBooks[book.id] ?? false;

                      final isFavorite = controller.bookFavorites[book.id] ?? false;
                      final syncManager = Get.find<SyncManager>();
                      // Show downloading state if:
                      // 1. This book is currently being downloaded (full book download)
                      // 2. This book is in the queue for batch download
                      // 3. Any chapter of this book has download progress (individual chapter downloads)
                      final isCurrentlyDownloading =
                          controller.currentDownloadingBookId.value == book.id;
                      final isInQueue = controller.queuedBookIds.contains(book.id);
                      
                      // Check if book has any chapter-level download activity
                      // by checking if bookDownloadProgress contains this book ID with progress < 1.0
                      final hasBookProgress = syncManager.bookDownloadProgress.containsKey(book.id) && 
                          syncManager.bookDownloadProgress[book.id]! > 0 &&
                          syncManager.bookDownloadProgress[book.id]! < 1.0;
                      
                      // Check if any chapter of THIS book has individual download progress
                      // by checking if this book is in queuedBookIds or is currently downloading
                      final hasChapterProgress = controller.queuedBookIds.contains(book.id) ||
                          (controller.currentDownloadingBookId.value == book.id);
                      
                      final isDownloading = isCurrentlyDownloading || isInQueue || hasBookProgress || hasChapterProgress;

                      return BookCard(
                        book: book,
                        isDownloaded: isDownloaded,
                        isDownloading: isDownloading,
                        progressPercent: controller.bookProgress[book.id] ?? 0.0,
                        downloadProgress: hasBookProgress 
                            ? (syncManager.bookDownloadProgress[book.id] ?? 0.0)
                            : (hasChapterProgress ? 0.01 : 0.0),
                        isFavorite: isFavorite,
                        onDownload: () => controller.downloadBook(book),
                        onTap: () => controller.openBook(book),
                        onFavorite: () => controller.toggleBookFavorite(book),
                      );
                    });
                  }, childCount: controller.books.length),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
