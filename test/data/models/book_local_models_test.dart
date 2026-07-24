import 'package:book_store/core/constants/app_enums.dart';
import 'package:book_store/data/local/models/book_local_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalBookTypeX', () {
    test('dbValue maps correctly', () {
      expect(LocalBookType.image.dbValue, 'IMAGE');
      expect(LocalBookType.text.dbValue, 'TEXT');
    });

    test('fromDb parses known types and defaults to text', () {
      expect(LocalBookTypeX.fromDb('IMAGE'), LocalBookType.image);
      expect(LocalBookTypeX.fromDb('TEXT'), LocalBookType.text);
      expect(LocalBookTypeX.fromDb('unknown'), LocalBookType.text);
    });
  });

  group('SwipeDirectionX', () {
    test('dbValue maps correctly', () {
      expect(SwipeDirection.rtl.dbValue, 'RTL');
      expect(SwipeDirection.ltr.dbValue, 'LTR');
    });

    test('fromDb parses LTR and defaults to RTL', () {
      expect(SwipeDirectionX.fromDb('LTR'), SwipeDirection.ltr);
      expect(SwipeDirectionX.fromDb('RTL'), SwipeDirection.rtl);
      expect(SwipeDirectionX.fromDb(null), SwipeDirection.rtl);
      expect(SwipeDirectionX.fromDb('unknown'), SwipeDirection.rtl);
    });

    test('pageViewReverse reflects RTL', () {
      expect(SwipeDirection.rtl.pageViewReverse, true);
      expect(SwipeDirection.ltr.pageViewReverse, false);
    });
  });

  group('LocalBook', () {
    test('toDb and fromDb are inverses', () {
      const book = LocalBook(
        id: 'b1',
        title: 'Test Book',
        description: 'A test',
        coverUrl: '/cover.jpg',
        type: LocalBookType.image,
        swipeDirection: SwipeDirection.ltr,
        version: 3,
        isFavorite: true,
      );

      final db = book.toDb();
      expect(db['id'], 'b1');
      expect(db['title'], 'Test Book');
      expect(db['book_type'], 'IMAGE');
      expect(db['is_favorite'], 1);

      final restored = LocalBook.fromDb(db);
      expect(restored.id, book.id);
      expect(restored.title, book.title);
      expect(restored.type, book.type);
      expect(restored.swipeDirection, book.swipeDirection);
      expect(restored.isFavorite, true);
    });

    test('fromDb handles missing values with defaults', () {
      final book = LocalBook.fromDb({
        'id': 'b2',
        'title': 'Missing',
        'book_type': null,
        'version': null,
      });
      expect(book.type, LocalBookType.text);
      expect(book.version, 0);
      expect(book.swipeDirection, SwipeDirection.rtl);
    });
  });

  group('TextSegment', () {
    test('toJson and fromJson are inverses', () {
      const segment = TextSegment(
        content: 'hello',
        startSeconds: 1.5,
        endSeconds: 3.0,
      );
      final json = segment.toJson();
      final restored = TextSegment.fromJson(json);
      expect(restored.content, 'hello');
      expect(restored.startSeconds, 1.5);
      expect(restored.endSeconds, 3.0);
    });

    test('fromJson parses int and string doubles', () {
      final restored = TextSegment.fromJson({
        'content': 'world',
        'startSeconds': 1,
        'endSeconds': '2.5',
      });
      expect(restored.startSeconds, 1.0);
      expect(restored.endSeconds, 2.5);
    });
  });

  group('LocalChapter', () {
    test('toDb and fromDb preserve content segments', () {
      const chapter = LocalChapter(
        id: 'c1',
        bookId: 'b1',
        title: 'Chapter 1',
        sortOrder: 1,
        contentText: 'Hello world',
        contentSegments: [
          TextSegment(content: 'Hello', startSeconds: 0.0, endSeconds: 1.0),
          TextSegment(content: 'world', startSeconds: 1.0, endSeconds: 2.0),
        ],
        version: 2,
        isDownloaded: true,
        isFavorite: true,
      );

      final db = chapter.toDb();
      expect(db['id'], 'c1');
      expect(db['content_text'], 'Hello world');
      expect(db['is_downloaded'], 1);
      expect(db['content_segments_json'], isNotNull);

      final restored = LocalChapter.fromDb(db);
      expect(restored.contentSegments?.length, 2);
      expect(restored.contentSegments?.first.content, 'Hello');
      expect(restored.isDownloaded, true);
    });

    test('fromDb handles null segments', () {
      final chapter = LocalChapter.fromDb({
        'id': 'c2',
        'book_id': 'b1',
        'title': 'Ch2',
        'sort_order': 2,
        'version': 0,
      });
      expect(chapter.contentSegments, null);
      expect(chapter.contentText, null);
    });
  });
}
