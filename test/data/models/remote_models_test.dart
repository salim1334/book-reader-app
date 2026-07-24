import 'package:book_store/data/remote/models/remote_book.dart';
import 'package:book_store/data/remote/models/remote_chapter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RemoteBook.isPublished', () {
    test('returns true for default book', () {
      const book = RemoteBook(
        id: 'b1',
        title: 'Title',
        type: 'TEXT',
        version: 1,
        author: RemoteAuthor(id: 'a1', name: 'Author'),
      );
      expect(book.isPublished, true);
    });

    test('returns false when published is false', () {
      const book = RemoteBook(
        id: 'b1',
        title: 'Title',
        type: 'TEXT',
        version: 1,
        author: RemoteAuthor(id: 'a1', name: 'Author'),
        published: false,
      );
      expect(book.isPublished, false);
    });

    test('returns false when unpublishChange is true', () {
      const book = RemoteBook(
        id: 'b1',
        title: 'Title',
        type: 'TEXT',
        version: 1,
        author: RemoteAuthor(id: 'a1', name: 'Author'),
        published: true,
        unpublishChange: true,
      );
      expect(book.isPublished, false);
    });

    test('respects status strings', () {
      String? status;
      RemoteBook build(String s) => RemoteBook(
            id: 'b1',
            title: 'Title',
            type: 'TEXT',
            version: 1,
            author: RemoteAuthor(id: 'a1', name: 'Author'),
            status: s,
          );

      expect(build('published').isPublished, true);
      expect(build('unpublished').isPublished, false);
      expect(build('draft').isPublished, false);
      expect(build('pending').isPublished, false);
      expect(build('false').isPublished, false);
      expect(build('UNPUBLISH_CHANGE').isPublished, false);
    });
  });

  group('RemoteBook.fromJson', () {
    test('parses a complete payload', () {
      final book = RemoteBook.fromJson({
        'id': 'b1',
        'title': 'Title',
        'description': 'Desc',
        'coverImage': '/cover.jpg',
        'type': 'IMAGE',
        'swipeDirection': 'LTR',
        'version': 5,
        'author': {'id': 'a1', 'name': 'Author'},
        'chapters': [
          {
            'id': 'c1',
            'title': 'Chapter 1',
            'orderIndex': 1,
            'version': 1,
            '_count': {'pages': 3, 'texts': 0, 'audios': 1},
          }
        ],
        '_count': {'chapters': 10},
        'status': 'published',
        'published': true,
      });

      expect(book.id, 'b1');
      expect(book.type, 'IMAGE');
      expect(book.swipeDirection, 'LTR');
      expect(book.version, 5);
      expect(book.chapters.length, 1);
      expect(book.chapters.first.pagesCount, 3);
      expect(book.chaptersCount, 10);
      expect(book.isPublished, true);
    });

    test('uses fallbacks for missing fields', () {
      final book = RemoteBook.fromJson({
        'id': 'b1',
        'title': 'Title',
        'version': '2',
        'author': {},
      });

      expect(book.type, 'TEXT');
      expect(book.swipeDirection, 'RTL');
      expect(book.version, 2);
      expect(book.chaptersCount, 0);
      expect(book.isPublished, true);
    });
  });

  group('RemoteChapter.fromJson', () {
    test('parses pages, texts and audios', () {
      final chapter = RemoteChapter.fromJson({
        'id': 'c1',
        'bookId': 'b1',
        'title': 'Chapter 1',
        'orderIndex': 1,
        'version': 2,
        'pages': [
          {
            'id': 'p1',
            'chapterId': 'c1',
            'imagePath': '/img.jpg',
            'orderIndex': 0,
            'version': 1,
            'audioStartTime': 0.0,
            'audioEndTime': 1.5,
          }
        ],
        'texts': [
          {
            'id': 't1',
            'chapterId': 'c1',
            'content': 'hello',
            'orderIndex': 0,
            'version': 1,
          }
        ],
        'audios': [
          {
            'id': 'a1',
            'chapterId': 'c1',
            'audioPath': '/audio.mp3',
            'duration': 120,
            'version': 1,
          }
        ],
      });

      expect(chapter.pages?.length, 1);
      expect(chapter.texts?.length, 1);
      expect(chapter.audios?.length, 1);
      expect(chapter.pages?.first.audioEndTime, 1.5);
    });
  });
}
