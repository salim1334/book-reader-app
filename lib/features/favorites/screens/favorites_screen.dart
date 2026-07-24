import 'package:book_store/common/widgets/loading_indicator.dart';
import 'package:book_store/features/favorites/controllers/favorites_controller.dart';
import 'package:book_store/features/favorites/widgets/books_tab.dart';
import 'package:book_store/features/favorites/widgets/chapters_tab.dart';
import 'package:book_store/features/favorites/widgets/pages_tab.dart';
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
          title: const Text('የተወደዱ'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'መጽሐፍት'),
              Tab(text: 'ምዕራፎች'),
              Tab(text: 'ገጾች'),
            ],
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const LoadingIndicator();
          }

          return TabBarView(children: [BooksTab(), ChaptersTab(), PagesTab()]);
        }),
      ),
    );
  }
}
