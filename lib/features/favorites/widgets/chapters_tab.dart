import 'package:book_store/common/widgets/empty_view.dart';
import 'package:book_store/features/favorites/controllers/favorites_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChaptersTab extends GetView<FavoritesController> {
  const ChaptersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final chapters = controller.favoriteChapters;
      if (chapters.isEmpty) {
        return const EmptyView(message: 'እስካሁን የተመረጡ ምዕራፎች የሉም።');
      }
      return ListView.builder(
        itemCount: chapters.length,
        itemBuilder: (context, index) {
          final chapter = chapters[index];
          return Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: ListTile(
              title: Text(chapter.title),
              subtitle: Text('Book ID: ${chapter.bookId}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete, size: 20),
                onPressed: () => controller.removeChapterFavorite(chapter),
              ),
              onTap: () => controller.openChapter(chapter),
            ),
          );
        },
      );
    });
  }
}
