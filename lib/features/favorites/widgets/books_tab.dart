import 'package:book_store/common/widgets/empty_view.dart';
import 'package:book_store/features/favorites/controllers/favorites_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BooksTab extends GetView<FavoritesController> {
  const BooksTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final books = controller.favoriteBooks;
      if (books.isEmpty) {
        return const EmptyView(message: 'እስካሁን የተመረጡ መጽሐፍት የሉም።');
      }
      return ListView.builder(
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];
          return Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: ListTile(
              title: Text(book.title),
              subtitle: book.description != null && book.description!.isNotEmpty
                  ? Text(book.description!)
                  : null,
              trailing: IconButton(
                icon: const Icon(Icons.delete, size: 20),
                onPressed: () => controller.removeBooksFavorite(book),
              ),
              onTap: () => controller.openBook(book),
            ),
          );
        },
      );
    });
  }
}

