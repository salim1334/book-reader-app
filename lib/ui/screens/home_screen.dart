import 'package:book_store/core/utils/asset_url.dart';
import 'package:book_store/data/local/models/book_local_models.dart';
import 'package:book_store/data/repositories/book_repository.dart';
import 'package:book_store/data/remote/sync_manager.dart';
import 'package:book_store/ui/screens/book_details_screen.dart';
import 'package:book_store/ui/screens/chapter_reader_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _ContinueReading {
  final LocalBook book;
  final LocalChapter chapter;
  final int pageIndex;
  final int positionMs;

  const _ContinueReading({
    required this.book,
    required this.chapter,
    this.pageIndex = 0,
    this.positionMs = 0,
  });
}

class _HomeScreenState extends State<HomeScreen> {
  final BookRepository _bookRepository = Get.find<BookRepository>();
  final SyncManager _syncManager = Get.find<SyncManager>();

  List<LocalBook> _books = [];
  _ContinueReading? _continue;
  bool _loading = true;
  String? _error;
  bool _isOffline = false;
  String? _downloadingBookId;
  final Map<String, bool> _downloadedBooks = {};
  final Map<String, double> _bookProgress = {};

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadBooks();
    await _autoSync();
  }

  Future<void> _loadBooks() async {
    try {
      final books = await _bookRepository.getBooks();
      final cont = await _loadContinueReading();
      final downloaded = <String, bool>{};
      final progress = <String, double>{};
      for (final book in books) {
        downloaded[book.id] = await _isBookDownloaded(book);
        progress[book.id] = await _bookRepository.getBookProgressPercent(book.id);
      }
      if (!mounted) return;
      setState(() {
        _books = books;
        _continue = cont;
        _loading = false;
        _error = null;
        _downloadedBooks.addAll(downloaded);
        _bookProgress.addAll(progress);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Failed to load books: $e';
      });
    }
  }

  Future<bool> _isBookDownloaded(LocalBook book) async {
    final chapters = await _bookRepository.getChapters(book.id);
    return chapters.isNotEmpty && chapters.every((c) => c.isDownloaded);
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  Future<_ContinueReading?> _loadContinueReading() async {
    final progress = await _bookRepository.getLastReadingProgress();
    if (progress == null) return null;

    final bookId = progress['book_id']?.toString();
    final chapterId = progress['chapter_id']?.toString();
    if (bookId == null || chapterId == null) return null;

    final book = await _bookRepository.getBook(bookId);
    final chapter = await _bookRepository.getChapter(chapterId);
    if (book == null || chapter == null || !chapter.isDownloaded) return null;

    return _ContinueReading(
      book: book,
      chapter: chapter,
      pageIndex: _toInt(progress['last_page_index']),
      positionMs: _toInt(progress['last_position_ms']),
    );
  }

  Future<void> _autoSync() async {
    final online = await _syncManager.isOnline();
    if (!mounted) return;
    setState(() => _isOffline = !online);
    if (!online) return;

    try {
      await _syncManager.syncCatalog();
      await _loadBooks();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not refresh catalog: $e')),
      );
    }
  }

  Future<void> _downloadBook(LocalBook book) async {
    setState(() => _downloadingBookId = book.id);
    try {
      await _syncManager.downloadBook(book.id);
      await _loadBooks();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${book.title} downloaded')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _downloadingBookId = null);
    }
  }

  void _openBook(LocalBook book) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => BookDetailsScreen(book: book)),
    );
  }

  void _openContinueReading() {
    final cont = _continue;
    if (cont == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChapterReaderScreen(
          book: cont.book,
          chapter: cont.chapter,
          initialPageIndex: cont.pageIndex,
          initialPositionMs: cont.positionMs,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasContinue = _continue != null && _books.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Book Reader')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _books.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          _isOffline
                              ? "You're currently offline. Please connect to the internet to view and download available books."
                              : 'No books available.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        await _autoSync();
                      },
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: _books.length + (hasContinue ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (hasContinue && index == 0) {
                            return _ContinueReadingCard(
                              reading: _continue!,
                              onTap: _openContinueReading,
                            );
                          }
                          final book = _books[hasContinue ? index - 1 : index];
                          final isDownloaded = _downloadedBooks[book.id] ?? false;
                          return _BookCard(
                            book: book,
                            isDownloaded: isDownloaded,
                            isDownloading: _downloadingBookId == book.id,
                            progressPercent: _bookProgress[book.id] ?? 0.0,
                            onDownload: () => _downloadBook(book),
                            onTap: () => _openBook(book),
                          );
                        },
                      ),
                    ),
    );
  }
}

class _ContinueReadingCard extends StatelessWidget {
  final _ContinueReading reading;
  final VoidCallback onTap;

  const _ContinueReadingCard({
    required this.reading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12.0),
      child: ListTile(
        leading: _CoverAvatar(book: reading.book),
        title: const Text('Continue reading'),
        subtitle: Text('${reading.book.title} · ${reading.chapter.title}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  final LocalBook book;
  final bool isDownloaded;
  final bool isDownloading;
  final double progressPercent;
  final VoidCallback onTap;
  final VoidCallback onDownload;

  const _BookCard({
    required this.book,
    required this.isDownloaded,
    required this.isDownloading,
    this.progressPercent = 0.0,
    required this.onTap,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    final coverProvider = coverImageProvider(book.coverUrl);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: SizedBox(
                  width: 80,
                  child: AspectRatio(
                    aspectRatio: 2 / 3,
                    child: coverProvider != null
                        ? Image(
                            image: coverProvider,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const _PlaceholderCover(),
                          )
                        : const _PlaceholderCover(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (book.description != null && book.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        book.description!,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Chip(
                      label: Text(
                        book.type == LocalBookType.text ? 'TEXT' : 'IMAGE',
                        style: const TextStyle(fontSize: 10),
                      ),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                    if (isDownloaded && progressPercent > 0) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: LinearProgressIndicator(
                          value: progressPercent,
                          color: Colors.green,
                          backgroundColor: Colors.grey.shade300,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              isDownloading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : isDownloaded
                      ? const Icon(Icons.download_done, color: Colors.green)
                      : IconButton(
                          icon: const Icon(Icons.download),
                          onPressed: onDownload,
                        ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CoverAvatar extends StatelessWidget {
  final LocalBook book;

  const _CoverAvatar({required this.book});

  @override
  Widget build(BuildContext context) {
    final provider = coverImageProvider(book.coverUrl);
    return CircleAvatar(
      backgroundImage: provider,
      onBackgroundImageError: provider != null ? (_, __) {} : null,
      child: const Icon(Icons.book),
    );
  }
}

class _PlaceholderCover extends StatelessWidget {
  const _PlaceholderCover();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade300,
      child: const Center(child: Icon(Icons.book)),
    );
  }
}
