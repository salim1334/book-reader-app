import 'package:book_store/common/widgets/book_card.dart';
import 'package:book_store/common/widgets/empty_view.dart';
import 'package:book_store/common/widgets/error_view.dart';
import 'package:book_store/common/widgets/loading_indicator.dart';
import 'package:book_store/features/home/controllers/home_controller.dart';
import 'package:book_store/features/home/widgets/continue_reading_card.dart';
import 'package:book_store/features/home/widgets/home_header.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

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
          return EmptyView(
            message: controller.isOffline.value || controller.offlineMode.value
                ? "በአሁኑ ጊዜ ከመስመር ውጭ ነዎት። የሚገኙ መጻሕፍትን ለማየት እና ለማውረድ እባክዎ ከበይነመረብ (ኢንተርኔት) ጋር ይገናኙ።"
                : 'ምንም መጻሕፍት አልተገኙም።',
          );
        }

        return RefreshIndicator(
          onRefresh: controller.autoSync,
          child: ListView.builder(
            // padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: controller.books.length + (hasContinue ? 2 : 1),
            itemBuilder: (context, index) {
              // Header
              if (index == 0) {
                return const HomeHeader();
              }

              // Continue Reading
              if (hasContinue && index == 1) {
                return ContinueReadingCard(
                  reading: controller.continueReading.value!,
                  onTap: controller.openContinueReading,
                  progress:
                      controller.bookProgress[controller
                          .continueReading
                          .value!
                          .book
                          .id] ??
                      0.0,
                );
              }

              final adjustedIndex = hasContinue ? index - 2 : index - 1;

              final book = controller.books[adjustedIndex];

              return Obx(() {
                final isDownloaded =
                    controller.downloadedBooks[book.id] ?? false;

                final isFavorite = controller.bookFavorites[book.id] ?? false;

                return BookCard(
                  book: book,
                  isDownloaded: isDownloaded,
                  isDownloading: controller.downloadingBookId.value == book.id,
                  progressPercent: controller.bookProgress[book.id] ?? 0.0,
                  isFavorite: isFavorite,
                  onDownload: () => controller.downloadBook(book),
                  onTap: () => controller.openBook(book),
                  onFavorite: () => controller.toggleBookFavorite(book),
                );
              });
            },
          ),
        );
      }),
    );
  }
}
