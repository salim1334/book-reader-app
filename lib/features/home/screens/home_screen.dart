import 'package:book_store/common/widgets/book_card.dart';
import 'package:book_store/common/widgets/empty_view.dart';
import 'package:book_store/common/widgets/error_view.dart';
import 'package:book_store/common/widgets/loading_indicator.dart';
import 'package:book_store/features/home/controllers/home_controller.dart';
import 'package:book_store/features/home/widgets/continue_reading_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book Reader')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingIndicator();
        }

        final error = controller.errorMessage.value;
        if (error != null) {
          return ErrorView(message: error, onRetry: controller.loadBooks);
        }

        final hasContinue = controller.continueReading.value != null && controller.books.isNotEmpty;

        if (controller.books.isEmpty) {
          return EmptyView(
            message: controller.isOffline.value
                ? "You're currently offline. Please connect to the internet to view and download available books."
                : 'No books available.',
          );
        }

        return RefreshIndicator(
          onRefresh: controller.autoSync,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: controller.books.length + (hasContinue ? 1 : 0),
            itemBuilder: (context, index) {
              if (hasContinue && index == 0) {
                return ContinueReadingCard(
                  reading: controller.continueReading.value!,
                  onTap: controller.openContinueReading,
                );
              }
              final book = controller.books[hasContinue ? index - 1 : index];
              return Obx(() {
                final isDownloaded = controller.downloadedBooks[book.id] ?? false;
                return BookCard(
                  book: book,
                  isDownloaded: isDownloaded,
                  isDownloading: controller.downloadingBookId.value == book.id,
                  progressPercent: controller.bookProgress[book.id] ?? 0.0,
                  onDownload: () => controller.downloadBook(book),
                  onTap: () => controller.openBook(book),
                );
              });
            },
          ),
        );
      }),
    );
  }
}
