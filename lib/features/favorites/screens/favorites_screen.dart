import 'package:book_store/common/widgets/empty_view.dart';
import 'package:book_store/common/widgets/loading_indicator.dart';
import 'package:book_store/features/favorites/controllers/favorites_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FavoritesScreen extends GetView<FavoritesController> {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Favorites'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Books'),
              Tab(text: 'Chapters'),
              Tab(text: 'Pages'),
            ],
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const LoadingIndicator();
          }

          return TabBarView(
            children: [
              _buildBooksTab(),
              _buildChaptersTab(),
              _buildPagesTab(),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildBooksTab() {
    return Obx(() {
      final books = controller.favoriteBooks;
      if (books.isEmpty) {
        return const EmptyView(message: 'No favorite books yet.');
      }
      return ListView.builder(
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];
          return ListTile(
            title: Text(book.title),
            subtitle: book.description != null && book.description!.isNotEmpty
                ? Text(book.description!)
                : null,
            trailing: const Icon(Icons.chevron_right),
            onTap: () => controller.openBook(book),
          );
        },
      );
    });
  }

  Widget _buildChaptersTab() {
    return Obx(() {
      final chapters = controller.favoriteChapters;
      if (chapters.isEmpty) {
        return const EmptyView(message: 'No favorite chapters yet.');
      }
      return ListView.builder(
        itemCount: chapters.length,
        itemBuilder: (context, index) {
          final chapter = chapters[index];
          return ListTile(
            title: Text(chapter.title),
            subtitle: Text('Book ID: ${chapter.bookId}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => controller.openChapter(chapter),
          );
        },
      );
    });
  }

  Widget _buildPagesTab() {
    return Obx(() {
      final pages = controller.favoritePages;
      if (pages.isEmpty) {
        return const EmptyView(message: 'No favorite pages yet.');
      }
      return ListView.builder(
        itemCount: pages.length,
        itemBuilder: (context, index) {
          final page = pages[index];
          final bookTitle = page['book_title']?.toString() ?? 'Book';
          final chapterTitle = page['chapter_title']?.toString() ?? 'Chapter';
          final pageIndex = (page['page_index'] as num?)?.toInt() ?? 0;
          return ListTile(
            title: Text('$bookTitle - $chapterTitle'),
            subtitle: Text('Page ${pageIndex + 1}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete, size: 20),
              onPressed: () => controller.removePageFavorite(page),
            ),
            onTap: () => controller.openPage(page),
          );
        },
      );
    });
  }
}
