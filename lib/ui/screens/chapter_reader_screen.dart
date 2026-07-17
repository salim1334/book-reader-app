import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:book_store/core/constants/app_enums.dart';
import 'package:book_store/data/local/models/book_local_models.dart';
import 'package:book_store/data/repositories/book_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
  late int _lastPageIndex;
  late int _lastPositionMs;
  double _chapterProgressPercent = 0.0;

  @override
  void initState() {
    super.initState();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.chapter.title)),
      body: widget.book.type == LocalBookType.text
          ? _TextReader(
              chapter: widget.chapter,
              chapterId: widget.chapter.id,
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
              chapterId: widget.chapter.id,
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
            ),
    );
  }
}

class _TextReader extends StatefulWidget {
  final LocalChapter chapter;
  final String chapterId;
  final int initialPositionMs;
  final void Function(int positionMs) onPositionChanged;
  final void Function(double progress) onProgressChanged;

  const _TextReader({
    required this.chapter,
    required this.chapterId,
    this.initialPositionMs = 0,
    required this.onPositionChanged,
    required this.onProgressChanged,
  });

  @override
  State<_TextReader> createState() => _TextReaderState();
}

class _TextReaderState extends State<_TextReader> {
  final BookRepository _repository = Get.find<BookRepository>();
  late Future<List<String>> _audioFuture;
  late int _positionMs;
  int _audioDurationMs = 0;
  late List<GlobalKey> _segmentKeys;
  int _currentSegmentIndex = -1;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _positionMs = widget.initialPositionMs;
    _audioFuture = _loadAudio();
    final segments = widget.chapter.contentSegments;
    _segmentKeys = List.generate(segments?.length ?? 0, (_) => GlobalKey());
    _updateCurrentSegment(scheduleScroll: true, shouldSetState: false);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final max = _scrollController.position.maxScrollExtent;
    if (max <= 0) return;
    final progress = (_scrollController.offset / max).clamp(0.0, 1.0);
    widget.onProgressChanged(progress);
  }

  Future<List<String>> _loadAudio() async {
    final rows = await _repository.getChapterAssets(
      widget.chapterId,
      assetType: 'AUDIO',
    );
    return rows.map((r) => r['file_path'] as String).toList();
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
    final progress = (_positionMs / _audioDurationMs).clamp(0.0, 1.0);
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
    return FutureBuilder<List<String>>(
      future: _audioFuture,
      builder: (context, snapshot) {
        final audioPaths = snapshot.data ?? [];
        final hasAudio = audioPaths.isNotEmpty;
        final hasKaraoke = widget.chapter.contentSegments?.isNotEmpty == true && hasAudio;

        final textContent = hasKaraoke
            ? _buildKaraoke(context)
            : Text(
                widget.chapter.contentText ?? 'No content available.',
                style: Theme.of(context).textTheme.bodyLarge,
              );

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16.0),
                child: textContent,
              ),
            ),
            if (hasAudio)
              _AudioPlayerBar(
                key: ValueKey('audio_${widget.chapterId}'),
                audioPath: audioPaths.first,
                initialPositionMs: widget.initialPositionMs,
                onPositionChanged: _onPositionChanged,
                onDurationChanged: _onDurationChanged,
              ),
          ],
        );
      },
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

class _AudioPlayerBar extends StatefulWidget {
  final String audioPath;
  final int initialPositionMs;
  final void Function(int positionMs) onPositionChanged;
  final void Function(int durationMs) onDurationChanged;

  const _AudioPlayerBar({
    super.key,
    required this.audioPath,
    this.initialPositionMs = 0,
    required this.onPositionChanged,
    required this.onDurationChanged,
  });

  @override
  State<_AudioPlayerBar> createState() => _AudioPlayerBarState();
}

class _AudioPlayerBarState extends State<_AudioPlayerBar> {
  final AudioPlayer _player = AudioPlayer();
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isPlaying = false;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    _player.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
      widget.onDurationChanged(d.inMilliseconds);
    });
    _player.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
      widget.onPositionChanged(p.inMilliseconds);
    });
    _player.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _isPlaying = state == PlayerState.playing);
    });

    await _player.setSource(DeviceFileSource(widget.audioPath));
    if (widget.initialPositionMs > 0) {
      await _player.seek(Duration(milliseconds: widget.initialPositionMs));
    }
    if (mounted) setState(() => _isReady = true);
  }

  Future<void> _toggle() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      await _player.resume();
    }
  }

  Future<void> _seek(double value) async {
    final position = Duration(milliseconds: value.toInt());
    await _player.seek(position);
  }

  String _format(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Slider(
                min: 0,
                max: _duration.inMilliseconds.toDouble().clamp(1, double.infinity),
                value: _position.inMilliseconds.toDouble().clamp(0, _duration.inMilliseconds.toDouble()),
                onChanged: _isReady ? _seek : null,
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                    onPressed: _isReady ? _toggle : null,
                  ),
                  Text('${_format(_position)} / ${_format(_duration)}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImageMedia {
  final List<String> images;
  final List<String> audio;

  _ImageMedia(this.images, this.audio);
}

class _ImageReader extends StatefulWidget {
  final String chapterId;
  final SwipeDirection swipeDirection;
  final int initialPageIndex;
  final void Function(int page) onPageChanged;
  final void Function(double progress) onProgressChanged;

  const _ImageReader({
    required this.chapterId,
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
  late final PageController _pageController;
  late Future<_ImageMedia> _mediaFuture;
  int _lastReportedPage = -1;
  int _imageCount = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialPageIndex);
    _mediaFuture = _loadMedia();
    _pageController.addListener(_onPageChanged);
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
    final progress = ((index + 1) / total).clamp(0.0, 1.0);
    widget.onProgressChanged(progress);
  }

  Future<_ImageMedia> _loadMedia() async {
    final imageRows = await _repository.getChapterAssets(
      widget.chapterId,
      assetType: 'IMAGE',
    );
    final images = imageRows.map((r) => r['file_path'] as String).toList();

    final audioRows = await _repository.getChapterAssets(
      widget.chapterId,
      assetType: 'AUDIO',
    );
    final audio = audioRows.map((r) => r['file_path'] as String).toList();

    return _ImageMedia(images, audio);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_ImageMedia>(
      future: _mediaFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error loading images: ${snapshot.error}'));
        }

        final media = snapshot.data ?? _ImageMedia([], []);
        _imageCount = media.images.length;
        if (media.images.isEmpty) {
          return const Center(
            child: Text('No downloaded images for this chapter.'),
          );
        }

        WidgetsBinding.instance.addPostFrameCallback((_) => _reportProgress());

        return Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                reverse: widget.swipeDirection.pageViewReverse,
                itemCount: media.images.length,
                itemBuilder: (context, index) {
                  return InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Image.file(
                      File(media.images[index]),
                      fit: BoxFit.contain,
                    ),
                  );
                },
              ),
            ),
            if (media.audio.isNotEmpty)
              _AudioPlayerBar(
                key: ValueKey('audio_${widget.chapterId}'),
                audioPath: media.audio.first,
                initialPositionMs: 0,
                onPositionChanged: (_) {},
                onDurationChanged: (_) {},
              ),
          ],
        );
      },
    );
  }
}
