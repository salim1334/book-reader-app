import 'package:book_store/common/widgets/book_card.dart';
import 'package:book_store/common/widgets/error_view.dart';
import 'package:book_store/common/widgets/loading_indicator.dart';
import 'package:book_store/data/remote/sync_manager.dart';
import 'package:book_store/features/home/controllers/home_controller.dart';
import 'package:book_store/features/home/widgets/continue_reading_card.dart';
import 'package:book_store/features/home/widgets/home_empty_state.dart';
import 'package:book_store/features/home/widgets/home_header.dart';
import 'package:book_store/features/home/widgets/more_books_banner.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
              // Sticky Header
              SliverToBoxAdapter(
                child: const HomeHeader(),
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
                      // Show downloading state if this book is currently being downloaded
                      // OR if it has chapters in the download queue
                      final isCurrentlyDownloading =
                          controller.currentDownloadingBookId.value == book.id;
                      final isInQueue = controller.queuedBookIds.contains(book.id);
                      final isDownloading = isCurrentlyDownloading || isInQueue;

                      return BookCard(
                        book: book,
                        isDownloaded: isDownloaded,
                        isDownloading: isDownloading,
                        progressPercent: controller.bookProgress[book.id] ?? 0.0,
                        downloadProgress:
                            syncManager.bookDownloadProgress[book.id] ?? 0.0,
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
