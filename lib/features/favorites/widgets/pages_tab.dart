import 'package:book_store/core/constants/app_texts.dart';
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
        return const EmptyView(message: AppTexts.favoritesEmptyPages);
      }
      return ListView.builder(
        itemCount: pages.length,
        itemBuilder: (context, index) {
          final page = pages[index];
          final bookTitle =
              page['book_title']?.toString() ?? AppTexts.favoritesBookFallback;
          final chapterTitle = page['chapter_title']?.toString() ??
              AppTexts.favoritesChapterFallback;
          final pageIndex = (page['page_index'] as num?)?.toInt() ?? 0;
          return Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: ListTile(
              title: Text(
                AppTexts.favoritesPageTitle(bookTitle, chapterTitle),
              ),
              subtitle: Text(AppTexts.favoritesPageNumber(pageIndex + 1)),
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
