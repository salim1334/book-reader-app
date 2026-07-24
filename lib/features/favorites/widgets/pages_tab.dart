import 'package:book_store/common/widgets/empty_view.dart';
import 'package:book_store/features/favorites/controllers/favorites_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PagesTab extends GetView<FavoritesController> {
  const PagesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final pages = controller.favoritePages;
      if (pages.isEmpty) {
        return const EmptyView(message: 'እስካሁን የተመረጡ ገጾች የሉም።');
      }
      return ListView.builder(
        itemCount: pages.length,
        itemBuilder: (context, index) {
          final page = pages[index];
          final bookTitle = page['book_title']?.toString() ?? 'Book';
          final chapterTitle = page['chapter_title']?.toString() ?? 'Chapter';
          final pageIndex = (page['page_index'] as num?)?.toInt() ?? 0;
          return Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: ListTile(
              title: Text('$bookTitle - $chapterTitle'),
              subtitle: Text('Page ${pageIndex + 1}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete, size: 20),
                onPressed: () => controller.removePageFavorite(page),
              ),
              onTap: () => controller.openPage(page),
            ),
          );
        },
      );
    });
  }
}
