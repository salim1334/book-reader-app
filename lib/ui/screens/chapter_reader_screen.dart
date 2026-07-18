import 'dart:io';

import 'package:book_store/core/constants/app_enums.dart';
import 'package:book_store/core/services/audio_player_service.dart';
import 'package:book_store/core/utils/asset_url.dart';
import 'package:book_store/data/local/models/book_local_models.dart';
import 'package:book_store/data/repositories/book_repository.dart';
import 'package:book_store/ui/widgets/reader_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

String? _coverArtUri(LocalBook book) {
  final cover = book.coverUrl;
  if (cover == null || cover.isEmpty) return null;
  if (cover.startsWith('http') || isRemoteCoverUrl(cover)) {
    return resolveAssetUrl(cover);
  }
  return Uri.file(cover).toString();
}

class ChapterReaderScreen extends StatefulWidget {
  final LocalBook book;
  final LocalChapter chapter;
  final int initialPageIndex;
  final int initialPositionMs;

  const ChapterReaderScreen({
    super.key,
    required this.book,
    required this.chapter,
    this.initialPageIndex = 0,
    this.initialPositionMs = 0,
  });

  @override
  State<ChapterReaderScreen> createState() => _ChapterReaderScreenState();
}

class _ChapterReaderScreenState extends State<ChapterReaderScreen> {
  final BookRepository _repository = Get.find<BookRepository>();
  final AudioPlayerService _audio = Get.find<AudioPlayerService>();
  late int _lastPageIndex;
  late int _lastPositionMs;
  double _chapterProgressPercent = 0.0;

  @override
  void initState() {
    super.initState();
    _audio.isReaderActive.value = true;
    _lastPageIndex = widget.initialPageIndex;
    _lastPositionMs = widget.initialPositionMs;
    _saveProgress(
      pageIndex: _lastPageIndex,
      positionMs: _lastPositionMs,
      chapterProgressPercent: _chapterProgressPercent,
    );
  }

  Future<void> _saveProgress({
    int pageIndex = 0,
    int positionMs = 0,
    double chapterProgressPercent = 0.0,
  }) async {
    try {
      await _repository.saveProgress(
        bookId: widget.book.id,
        chapterId: widget.chapter.id,
        lastPositionMs: positionMs,
        lastPageIndex: pageIndex,
        chapterProgressPercent: chapterProgressPercent,
      );
    } catch (e) {
      debugPrint('Failed to save progress: $e');
    }
  }

  @override
  void dispose() {
    _saveProgress(
      pageIndex: _lastPageIndex,
      positionMs: _lastPositionMs,
      chapterProgressPercent: _chapterProgressPercent,
    );
    _audio.isReaderActive.value = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reader = widget.book.type == LocalBookType.text
        ? _TextReader(
            book: widget.book,
            chapter: widget.chapter,
            initialPositionMs: widget.initialPositionMs,
            onPositionChanged: (ms) => _lastPositionMs = ms,
            onProgressChanged: (progress) {
              _chapterProgressPercent = progress;
              _saveProgress(
                positionMs: _lastPositionMs,
                chapterProgressPercent: progress,
              );
            },
          )
        : _ImageReader(
            book: widget.book,
            chapter: widget.chapter,
            swipeDirection: widget.book.swipeDirection,
            initialPageIndex: widget.initialPageIndex,
            onPageChanged: (index) {
              _lastPageIndex = index;
            },
            onProgressChanged: (progress) {
              _chapterProgressPercent = progress;
              _saveProgress(
                pageIndex: _lastPageIndex,
                chapterProgressPercent: progress,
              );
            },
          );

    return Scaffold(
      appBar: AppBar(title: Text(widget.chapter.title)),
      body: Column(
        children: [
          const ReaderAudioPlayer(),
          Expanded(child: reader),
        ],
      ),
    );
  }
}

class _TextReader extends StatefulWidget {
  final LocalBook book;
  final LocalChapter chapter;
  final int initialPositionMs;
  final void Function(int positionMs) onPositionChanged;
  final void Function(double progress) onProgressChanged;

  const _TextReader({
    required this.book,
    required this.chapter,
    this.initialPositionMs = 0,
    required this.onPositionChanged,
    required this.onProgressChanged,
  });

  @override
  State<_TextReader> createState() => _TextReaderState();
}

class _TextReaderState extends State<_TextReader> {
  final BookRepository _repository = Get.find<BookRepository>();
  final AudioPlayerService _audio = Get.find<AudioPlayerService>();
  late int _positionMs;
  int _audioDurationMs = 0;
  late List<GlobalKey> _segmentKeys;
  int _currentSegmentIndex = -1;
  bool _hasAudio = false;
  final ScrollController _scrollController = ScrollController();
  Worker? _positionWorker;
  Worker? _durationWorker;

  @override
  void initState() {
    super.initState();
    _positionMs = widget.initialPositionMs;
    final segments = widget.chapter.contentSegments;
    _segmentKeys = List.generate(segments?.length ?? 0, (_) => GlobalKey());
    _updateCurrentSegment(scheduleScroll: true, shouldSetState: false);
    _scrollController.addListener(_onScroll);
    _initAudio();
  }

  Future<void> _initAudio() async {
    final rows = await _repository.getChapterAssets(
      widget.chapter.id,
      assetType: 'AUDIO',
    );
    final paths = rows.map((r) => r['file_path'] as String).toList();
    if (paths.isEmpty) {
      await _audio.stop();
      if (mounted) setState(() => _hasAudio = false);
      return;
    }

    if (mounted) setState(() => _hasAudio = true);

    _positionWorker = interval(
      _audio.position,
      (pos) => _onPositionChanged((pos).inMilliseconds),
      time: const Duration(milliseconds: 250),
    );
    _durationWorker = ever(
      _audio.duration,
      (dur) => _onDurationChanged((dur).inMilliseconds),
    );

    final artUri = _coverArtUri(widget.book);
    await _audio.playQueue(
      AudioQueue(
        items: [
          AudioItem(
            id: '${widget.book.id}_${widget.chapter.id}_0',
            title: widget.chapter.title,
            subtitle: widget.book.title,
            path: paths.first,
            artUri: artUri,
            book: widget.book,
            chapter: widget.chapter,
            initialPositionMs: widget.initialPositionMs,
          ),
        ],
      ),
      sourceTitle: widget.chapter.title,
      sourceSubtitle: widget.book.title,
      sourceArtUri: artUri,
    );
  }

  @override
  void dispose() {
    _positionWorker?.dispose();
    _durationWorker?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final max = _scrollController.position.maxScrollExtent;
    if (max <= 0) return;
    final progress = (_scrollController.offset / max)
        .clamp(0.0, 1.0)
        .toDouble();
    widget.onProgressChanged(progress);
  }

  void _onPositionChanged(int ms) {
    widget.onPositionChanged(ms);
    _positionMs = ms;
    _updateCurrentSegment();
    _updateAudioProgress();
  }

  void _onDurationChanged(int durationMs) {
    _audioDurationMs = durationMs;
    _updateAudioProgress();
  }

  void _updateAudioProgress() {
    if (_audioDurationMs <= 0) return;
    final progress = (_positionMs / _audioDurationMs)
        .clamp(0.0, 1.0)
        .toDouble();
    widget.onProgressChanged(progress);
  }

  void _updateCurrentSegment({
    bool scheduleScroll = false,
    bool shouldSetState = true,
  }) {
    final segments = widget.chapter.contentSegments;
    if (segments == null || segments.isEmpty) return;

    final seconds = _positionMs / 1000.0;
    var index = -1;
    for (var i = 0; i < segments.length; i++) {
      final s = segments[i];
      if (s.startSeconds != null &&
          s.endSeconds != null &&
          seconds >= s.startSeconds! &&
          seconds <= s.endSeconds!) {
        index = i;
        break;
      }
    }

    if (index != _currentSegmentIndex) {
      _currentSegmentIndex = index;
      if (shouldSetState && mounted) {
        setState(() {});
      }
      if (index != -1 && scheduleScroll) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _scrollToSegment(index),
        );
      }
    }
  }

  void _scrollToSegment(int index) {
    final ctx = _segmentKeys[index].currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      alignment: 0.5,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasKaraoke =
        _hasAudio && widget.chapter.contentSegments?.isNotEmpty == true;

    final textContent = hasKaraoke
        ? _buildKaraoke(context)
        : Text(
            widget.chapter.contentText ?? 'No content available.',
            style: Theme.of(context).textTheme.bodyLarge,
          );

    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16.0),
      child: textContent,
    );
  }

  Widget _buildKaraoke(BuildContext context) {
    final theme = Theme.of(context);
    final segments = widget.chapter.contentSegments!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: segments.asMap().entries.map((entry) {
        final index = entry.key;
        final segment = entry.value;
        final isCurrent = index == _currentSegmentIndex;
        return Container(
          key: _segmentKeys[index],
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            segment.content,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              color: isCurrent
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ImageMedia {
  final List<String> images;
  final List<String> audio;

  _ImageMedia(this.images, this.audio);
}

class _ImageReader extends StatefulWidget {
  final LocalBook book;
  final LocalChapter chapter;
  final SwipeDirection swipeDirection;
  final int initialPageIndex;
  final void Function(int page) onPageChanged;
  final void Function(double progress) onProgressChanged;

  const _ImageReader({
    required this.book,
    required this.chapter,
    this.swipeDirection = SwipeDirection.rtl,
    this.initialPageIndex = 0,
    required this.onPageChanged,
    required this.onProgressChanged,
  });

  @override
  State<_ImageReader> createState() => _ImageReaderState();
}

class _ImageReaderState extends State<_ImageReader> {
  final BookRepository _repository = Get.find<BookRepository>();
  final AudioPlayerService _audio = Get.find<AudioPlayerService>();
  late final PageController _pageController;
  int _lastReportedPage = -1;
  int _imageCount = 0;
  _ImageMedia? _media;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialPageIndex);
    _pageController.addListener(_onPageChanged);
    _initMedia();
  }

  Future<void> _initMedia() async {
    final media = await _loadMedia();
    if (!mounted) return;
    setState(() {
      _media = media;
      _imageCount = media.images.length;
      _isLoading = false;
    });

    if (media.audio.isNotEmpty) {
      final artUri = _coverArtUri(widget.book);
      await _audio.playQueue(
        AudioQueue(
          items: [
            AudioItem(
              id: '${widget.book.id}_${widget.chapter.id}_0',
              title: widget.chapter.title,
              subtitle: widget.book.title,
              path: media.audio.first,
              artUri: artUri,
              book: widget.book,
              chapter: widget.chapter,
            ),
          ],
        ),
        sourceTitle: widget.chapter.title,
        sourceSubtitle: widget.book.title,
        sourceArtUri: artUri,
      );
    } else {
      await _audio.stop();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _reportProgress());
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged() {
    if (_pageController.page == null) return;
    final index = _pageController.page!.round();
    if (index == _lastReportedPage) return;
    _lastReportedPage = index;
    widget.onPageChanged(index);
    _reportProgress();
  }

  void _reportProgress() {
    final total = _imageCount;
    if (total <= 0) return;
    final index = _pageController.page?.round() ?? widget.initialPageIndex;
    final progress = ((index + 1) / total).clamp(0.0, 1.0).toDouble();
    widget.onProgressChanged(progress);
  }

  Future<_ImageMedia> _loadMedia() async {
    final imageRows = await _repository.getChapterAssets(
      widget.chapter.id,
      assetType: 'IMAGE',
    );
    final images = imageRows.map((r) => r['file_path'] as String).toList();

    final audioRows = await _repository.getChapterAssets(
      widget.chapter.id,
      assetType: 'AUDIO',
    );
    final audio = audioRows.map((r) => r['file_path'] as String).toList();

    return _ImageMedia(images, audio);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final media = _media ?? _ImageMedia([], []);
    if (media.images.isEmpty) {
      return const Center(
        child: Text('No downloaded images for this chapter.'),
      );
    }

    return PageView.builder(
      controller: _pageController,
      reverse: widget.swipeDirection.pageViewReverse,
      itemCount: media.images.length,
      itemBuilder: (context, index) {
        return InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.file(File(media.images[index]), fit: BoxFit.contain),
        );
      },
    );
  }
}
