import 'package:book_store/data/local/models/book_local_models.dart';
import 'package:book_store/data/remote/sync_manager.dart';
import 'package:book_store/data/repositories/book_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  final BookRepository _repository = Get.find<BookRepository>();
  final SyncManager _syncManager = Get.find<SyncManager>();

  List<LocalBook> _books = [];
  Map<String, int> _chapterCounts = {};
  List<Map<String, Object?>> _queue = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final books = await _repository.getBooks();
      final counts = <String, int>{};
      for (final book in books) {
        final chapters = await _repository.getChapters(book.id);
        counts[book.id] = chapters.length;
      }
      final queue = await _repository.getDownloadQueue();
      if (!mounted) return;
      setState(() {
        _books = books;
        _chapterCounts = counts;
        _queue = queue;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Failed to load downloads: $e';
      });
    }
  }

  Future<void> _retryChapter(String chapterId) async {
    try {
      await _syncManager.downloadChapter(chapterId);
      await _loadData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Retry failed: $e')));
    }
  }

  Future<void> _deleteBook(LocalBook book) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete downloaded book?'),
        content: Text('This will remove "${book.title}" and its media.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _repository.deleteBook(book.id);
      await _loadData();
    }
  }

  int get _queueSectionCount => _queue.isNotEmpty ? _queue.length + 1 : 0;
  int get _booksSectionCount => _books.isNotEmpty ? _books.length + 1 : 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Downloads')),
      body: Column(
        children: [
          Obx(() {
            final state = _syncManager.syncState.value;
            final isActive =
                state == SyncState.syncing || state == SyncState.downloading;
            return AnimatedSize(
              duration: const Duration(milliseconds: 250),
              child: isActive
                  ? Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const LinearProgressIndicator(),
                          const SizedBox(height: 8),
                          Text(
                            '${state.name}...',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          if (_syncManager.currentDownload != null)
                            Obx(
                              () => Text(
                                _syncManager.currentDownload!.value,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            );
          }),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(child: Text(_error!))
                : _queue.isEmpty && _books.isEmpty
                ? const Center(child: Text('No downloads yet.'))
                : RefreshIndicator(
                    onRefresh: _loadData,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: _queueSectionCount + _booksSectionCount,
                      itemBuilder: (context, index) {
                        if (_queue.isNotEmpty) {
                          if (index == 0) {
                            return const ListTile(
                              title: Text(
                                'Download queue',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            );
                          }
                          if (index <= _queue.length) {
                            final item = _queue[index - 1];
                            final chapterId =
                                item['chapter_id'] as String? ?? '';
                            final status =
                                item['status'] as String? ?? 'UNKNOWN';
                            final progress =
                                (item['progress'] as num?)?.toDouble() ?? 0.0;
                            final retryCount =
                                (item['retry_count'] as num?)?.toInt() ?? 0;
                            final canRetry = status == 'FAILED';
                            return ListTile(
                              leading: _queueIcon(status),
                              title: Text(
                                'Chapter ${chapterId.length > 8 ? chapterId.substring(0, 8) : chapterId}...',
                              ),
                              subtitle: Text(
                                '$status • ${(progress * 100).toStringAsFixed(0)}% • retries: $retryCount',
                              ),
                              trailing: canRetry
                                  ? IconButton(
                                      icon: const Icon(Icons.replay),
                                      onPressed: () => _retryChapter(chapterId),
                                    )
                                  : null,
                            );
                          }
                        }
                        final bookOffset = _queueSectionCount;
                        if (index == bookOffset) {
                          return const ListTile(
                            title: Text(
                              'Downloaded books',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          );
                        }
                        final bookIndex = index - bookOffset - 1;
                        final book = _books[bookIndex];
                        final chapterCount = _chapterCounts[book.id] ?? 0;
                        return ListTile(
                          leading: const Icon(Icons.book),
                          title: Text(book.title),
                          subtitle: Text(
                            '${book.type.name} • $chapterCount chapter${chapterCount == 1 ? '' : 's'}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteBook(book),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _queueIcon(String status) {
    return switch (status) {
      'COMPLETED' => const Icon(Icons.download_done, color: Colors.green),
      'FAILED' => const Icon(Icons.error, color: Colors.red),
      'DOWNLOADING' => const Icon(Icons.downloading),
      'PENDING' => const Icon(Icons.pending),
      _ => const Icon(Icons.download),
    };
  }
}
