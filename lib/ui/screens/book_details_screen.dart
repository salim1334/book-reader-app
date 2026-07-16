import 'package:book_store/core/utils/asset_url.dart';
import 'package:book_store/data/local/models/book_local_models.dart';
import 'package:book_store/data/remote/models/remote_book.dart';
import 'package:book_store/data/remote/sync_manager.dart';
import 'package:book_store/data/repositories/book_repository.dart';
import 'package:book_store/ui/screens/chapter_reader_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BookDetailsScreen extends StatefulWidget {
  final LocalBook book;

  const BookDetailsScreen({super.key, required this.book});

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  final BookRepository _repository = Get.find<BookRepository>();
  final SyncManager _syncManager = Get.find<SyncManager>();

  late LocalBook _book;
  List<LocalChapter> _chapters = [];
  bool _loading = true;
  String? _error;
  RemoteBook? _remoteBook;
  bool _hasUpdate = false;
  final List<String> _outdatedChapterIds = [];
  String? _downloadingChapterId;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _book = widget.book;
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });
      final localBook = await _repository.getBook(widget.book.id);
      final localChapters = await _repository.getChapters(widget.book.id);
      if (localBook != null) _book = localBook;
      _chapters = localChapters;

      final online = await _syncManager.isOnline();
      if (!mounted) return;
      setState(() => _isOffline = !online);
      if (online && mounted) {
        _remoteBook = await _syncManager.fetchAndSyncBookMetadata(widget.book.id);

        final updatedBook = await _repository.getBook(widget.book.id);
        final updatedChapters = await _repository.getChapters(widget.book.id);
        if (updatedBook != null) _book = updatedBook;
        _chapters = updatedChapters;

        _outdatedChapterIds.clear();
        _outdatedChapterIds.addAll(_findOutdatedChapterIds(_remoteBook!, _chapters));
        _hasUpdate = _remoteBook!.version > _book.version || _outdatedChapterIds.isNotEmpty;
      }
      if (!mounted) return;
      setState(() => _loading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Failed to load book details: $e';
      });
    }
  }

  List<String> _findOutdatedChapterIds(RemoteBook remote, List<LocalChapter> localChapters) {
    final localMap = {for (final c in localChapters) c.id: c};
    final outdated = <String>[];
    for (final summary in remote.chapters) {
      final local = localMap[summary.id];
      if (local != null && summary.version > local.version) {
        outdated.add(summary.id);
      }
    }
    return outdated;
  }

  Future<void> _updateBook() async {
    setState(() => _loading = true);
    try {
      await _syncManager.updateBook(_book.id);
      await _loadData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Book updated')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update failed: $e')),
      );
      setState(() => _loading = false);
    }
  }

  Future<void> _downloadChapter(LocalChapter chapter) async {
    setState(() => _downloadingChapterId = chapter.id);
    try {
      await _syncManager.downloadChapter(chapter.id);
      await _loadData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${chapter.title} downloaded')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _downloadingChapterId = null);
    }
  }

  void _openChapter(LocalChapter chapter) {
    if (!chapter.isDownloaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Download this chapter to read it')),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChapterReaderScreen(
          book: _book,
          chapter: chapter,
        ),
      ),
    );
  }

  Widget _buildUpdateBanner() {
    if (!_hasUpdate) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Card(
        color: Colors.orange.shade50,
        child: ListTile(
          leading: const Icon(Icons.update, color: Colors.orange),
          title: const Text('New version available'),
          subtitle: const Text('Some content has been updated. Tap update to download the latest changes.'),
          trailing: _loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : TextButton(
                  onPressed: _updateBook,
                  child: const Text('UPDATE'),
                ),
        ),
      ),
    );
  }

  Widget _buildCover() {
    final coverUrl = _book.coverUrl;
    final hasCover = coverUrl != null && coverUrl.isNotEmpty;
    return hasCover
        ? AspectRatio(
            aspectRatio: 16 / 9,
            child: Image(
              image: coverImageProvider(coverUrl)!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Center(
                child: Icon(Icons.broken_image),
              ),
            ),
          )
        : const SizedBox.shrink();
  }

  Widget _buildBookInfo() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _book.title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Chip(
            label: Text(_book.type == LocalBookType.text ? 'TEXT' : 'IMAGE'),
            visualDensity: VisualDensity.compact,
          ),
          if (_book.description != null && _book.description!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              _book.description!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text(_book.title)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text(_book.title)),
        body: Center(child: Text(_error!)),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(_book.title)),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildUpdateBanner()),
            SliverToBoxAdapter(child: _buildCover()),
            SliverToBoxAdapter(child: _buildBookInfo()),
            if (_chapters.isEmpty)
              const SliverFillRemaining(
                child: Center(child: Text('No chapters available')),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final chapter = _chapters[index];
                    final isOutdated = _outdatedChapterIds.contains(chapter.id);
                    return ListTile(
                      leading: CircleAvatar(child: Text('${index + 1}')),
                      title: Text(chapter.title),
                      subtitle: Text(
                        chapter.description ??
                            (chapter.isDownloaded
                                ? 'Downloaded'
                                : 'Tap to download'),
                      ),
                      trailing: _downloadingChapterId == chapter.id
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : chapter.isDownloaded
                              ? (isOutdated
                                  ? IconButton(
                                      icon: const Icon(Icons.update),
                                      onPressed: () => _downloadChapter(chapter),
                                    )
                                  : const Icon(Icons.chevron_right))
                              : IconButton(
                                  icon: const Icon(Icons.download),
                                  onPressed: () => _downloadChapter(chapter),
                                ),
                      onTap: () {
                        if (chapter.isDownloaded && !isOutdated) {
                          _openChapter(chapter);
                        } else {
                          _downloadChapter(chapter);
                        }
                      },
                    );
                  },
                  childCount: _chapters.length,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
