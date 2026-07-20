import 'package:book_store/common/widgets/empty_view.dart';
import 'package:book_store/common/widgets/loading_indicator.dart';
import 'package:book_store/features/search/controllers/search_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchScreen extends GetView<BookSearchController> {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: controller.textController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search books or chapters...',
            border: InputBorder.none,
            suffixIcon: Obx(() {
              if (controller.query.value.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.clear),
                onPressed: controller.clearQuery,
              );
            }),
          ),
          onChanged: controller.onQueryChanged,
        ),
      ),
      body: Obx(() {
        if (controller.query.value.isEmpty) {
          return const Center(
            child: Text('Type a book or chapter title to search.'),
          );
        }

        if (controller.isLoading.value) {
          return const LoadingIndicator();
        }

        final hasBooks = controller.books.isNotEmpty;
        final hasChapters = controller.chapters.isNotEmpty;

        if (!hasBooks && !hasChapters) {
          return EmptyView(
            message: 'No results found for "${controller.query.value}".',
          );
        }

        return ListView.builder(
          itemCount: _itemCount,
          itemBuilder: (context, index) {
            return _buildItem(context, index);
          },
        );
      }),
    );
  }

  int get _itemCount {
    var count = 0;
    if (controller.books.isNotEmpty) count += controller.books.length + 1;
    if (controller.chapters.isNotEmpty) count += controller.chapters.length + 1;
    return count;
  }

  Widget _buildItem(BuildContext context, int index) {
    var offset = 0;

    if (controller.books.isNotEmpty) {
      if (index == offset) {
        return _SectionHeader(title: 'Books', count: controller.books.length);
      }
      offset++;
      if (index < offset + controller.books.length) {
        final book = controller.books[index - offset];
        return ListTile(
          leading: const Icon(Icons.menu_book),
          title: Text(book.title),
          subtitle:
              book.description != null && book.description!.isNotEmpty
                  ? Text(
                    book.description!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                  : null,
          trailing: const Icon(Icons.chevron_right),
          onTap: () => controller.openBook(book),
        );
      }
      offset += controller.books.length;
    }

    if (controller.chapters.isNotEmpty) {
      if (index == offset) {
        return _SectionHeader(
          title: 'Chapters',
          count: controller.chapters.length,
        );
      }
      offset++;
      final chapter = controller.chapters[index - offset];
      return ListTile(
        leading: const Icon(Icons.article),
        title: Text(chapter.title),
        subtitle: Text('Book ID: ${chapter.bookId}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => controller.openChapter(chapter),
      );
    }

    return const SizedBox.shrink();
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;

  const _SectionHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        '$title ($count)',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
