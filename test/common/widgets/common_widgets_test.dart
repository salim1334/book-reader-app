import 'package:book_store/common/widgets/book_card.dart';
import 'package:book_store/common/widgets/chapter_list_tile.dart';
import 'package:book_store/common/widgets/cover_image.dart';
import 'package:book_store/common/widgets/empty_view.dart';
import 'package:book_store/common/widgets/error_view.dart';
import 'package:book_store/common/widgets/loading_indicator.dart';
import 'package:book_store/core/theme/app_theme.dart';
import 'package:book_store/data/local/models/book_local_models.dart';
import 'package:book_store/data/remote/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../../helpers/test_setup.dart';

void main() {
  setupTestBinding();

  setUp(() {
    ApiClient.instance.dio.options.baseUrl = 'https://example.com/';
  });

  Widget buildWrapper(Widget child) {
    return GetMaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(body: child),
    );
  }

  group('EmptyView', () {
    testWidgets('displays message and icon', (tester) async {
      await tester.pumpWidget(
        buildWrapper(const EmptyView(message: 'No items')),
      );

      expect(find.text('No items'), findsOneWidget);
      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    });
  });

  group('ErrorView', () {
    testWidgets('displays message and retry button', (tester) async {
      var retried = false;
      await tester.pumpWidget(
        buildWrapper(
          ErrorView(
            message: 'Error!',
            onRetry: () => retried = true,
          ),
        ),
      );

      expect(find.text('Error!'), findsOneWidget);
      expect(find.text('ደግመህ ሞክር'), findsOneWidget);

      await tester.tap(find.text('ደግመህ ሞክር'));
      await tester.pump();

      expect(retried, true);
    });
  });

  group('LoadingIndicator', () {
    testWidgets('shows spinner and message', (tester) async {
      await tester.pumpWidget(
        buildWrapper(const LoadingIndicator(message: 'Loading')),
      );

      expect(find.text('Loading'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows determinate progress', (tester) async {
      await tester.pumpWidget(
        buildWrapper(const LoadingIndicator(progress: 0.5)),
      );

      final indicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(indicator.value, 0.5);
    });
  });

  group('CoverImage', () {
    testWidgets('shows placeholder when cover is null', (tester) async {
      await tester.pumpWidget(
        buildWrapper(const CoverImage(coverUrl: null)),
      );

      expect(find.byIcon(Icons.book), findsOneWidget);
    });

    testWidgets('renders with remote cover', (tester) async {
      await tester.pumpWidget(
        buildWrapper(const CoverImage(coverUrl: '/uploads/cover.jpg')),
      );

      expect(find.byType(Image), findsOneWidget);
    });
  });

  group('BookCard', () {
    testWidgets('displays book title and badges', (tester) async {
      const book = LocalBook(
        id: 'b1',
        title: 'Test Book',
        coverUrl: '/local/cover.jpg',
        type: LocalBookType.text,
        version: 1,
      );

      var tapped = false;
      var downloaded = false;
      var favorited = false;

      await tester.pumpWidget(
        buildWrapper(
          BookCard(
            book: book,
            isDownloaded: true,
            isDownloading: false,
            isFavorite: true,
            progressPercent: 0.5,
            onTap: () => tapped = true,
            onDownload: () => downloaded = true,
            onFavorite: () => favorited = true,
          ),
        ),
      );

      expect(find.text('Test Book'), findsOneWidget);
      expect(find.byIcon(Icons.bookmark), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);

      await tester.tap(find.text('Test Book'));
      await tester.pump();
      expect(tapped, true);
    });
  });

  group('ChapterListTile', () {
    testWidgets('displays chapter title and index', (tester) async {
      const chapter = LocalChapter(
        id: 'c1',
        bookId: 'b1',
        title: 'Chapter 1',
        sortOrder: 0,
        version: 1,
        isDownloaded: true,
      );

      var tapped = false;
      var favorited = false;

      await tester.pumpWidget(
        buildWrapper(
          ChapterListTile(
            index: 0,
            chapter: chapter,
            progress: 0.25,
            isOutdated: false,
            isDownloading: false,
            isFavorite: false,
            onTap: () => tapped = true,
            onFavorite: () => favorited = true,
          ),
        ),
      );

      expect(find.text('Chapter 1'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);

      await tester.tap(find.text('Chapter 1'));
      await tester.pump();
      expect(tapped, true);
    });
  });
}
