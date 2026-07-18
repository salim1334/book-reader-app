import 'package:book_store/data/local/models/book_local_models.dart';
import 'package:book_store/core/services/audio_player_service.dart';
import 'package:book_store/core/utils/asset_url.dart';
import 'package:book_store/data/repositories/book_repository.dart';
import 'package:book_store/features/chapter_reader/controllers/chapter_reader_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PageTiming {
  final int orderIndex;
  final double? startSeconds;
  final double? endSeconds;

  const PageTiming({
    required this.orderIndex,
    this.startSeconds,
    this.endSeconds,
  });
}

class ImageMedia {
  final List<String> images;
  final List<String> audio;
  final List<PageTiming> timings;

  const ImageMedia({
    required this.images,
    required this.audio,
    required this.timings,
  });
}

class ImageReaderController extends GetxController {
  final BookRepository _repository = Get.find<BookRepository>();
  final AudioPlayerService _audio = Get.find<AudioPlayerService>();
  late final ChapterReaderController _chapterReader = Get.find<ChapterReaderController>();

  ChapterReaderController get chapterReader => _chapterReader;

  PageController? pageController;
  final isLoading = true.obs;
  final imageCount = 0.obs;
  final media = Rxn<ImageMedia>();

  int _lastReportedPage = -1;

  Worker? _pageWorker;

  bool get _isImageBook => _chapterReader.book.type != LocalBookType.text;

  @override
  void onInit() {
    super.onInit();
    if (!_isImageBook) {
      isLoading.value = false;
      return;
    }

    _initMedia();
  }

  @override
  void onClose() {
    _pageWorker?.dispose();
    pageController?.dispose();
    super.onClose();
  }

  Future<void> _initMedia() async {
    final loadedMedia = await _loadMedia();

    if (loadedMedia.audio.isNotEmpty) {
      final artUri = coverArtUri(_chapterReader.book);
      final isSameChapter = _audio.isCurrentBookChapter(
        _chapterReader.book,
        _chapterReader.chapter,
      );
      if (!isSameChapter) {
        await _audio.playQueue(
          AudioQueue(
            items: [
              AudioItem(
                id: '${_chapterReader.book.id}_${_chapterReader.chapter.id}_0',
                title: _chapterReader.chapter.title,
                subtitle: _chapterReader.book.title,
                path: loadedMedia.audio.first,
                artUri: artUri,
                book: _chapterReader.book,
                chapter: _chapterReader.chapter,
                initialPositionMs: _chapterReader.initialPositionMs,
              ),
            ],
          ),
          sourceTitle: _chapterReader.chapter.title,
          sourceSubtitle: _chapterReader.book.title,
          sourceArtUri: artUri,
        );
      }
    } else {
      await _audio.stop();
    }

    final initialPage = _computeInitialPage(loadedMedia);
    final lastIndex = loadedMedia.images.isEmpty ? 0 : loadedMedia.images.length - 1;
    pageController = PageController(
      initialPage: loadedMedia.images.isEmpty ? 0 : initialPage.clamp(0, lastIndex).toInt(),
    );

    media.value = loadedMedia;
    imageCount.value = loadedMedia.images.length;
    isLoading.value = false;

    if (loadedMedia.timings.any((t) => t.startSeconds != null && t.endSeconds != null)) {
      _pageWorker = interval(
        _audio.position,
        (pos) => _updateCurrentPage(pos.inMilliseconds),
        time: const Duration(milliseconds: 500),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _reportProgress());
  }

  int _computeInitialPage(ImageMedia media) {
    final timings = media.timings;
    if (timings.isEmpty) return _chapterReader.initialPageIndex;
    final seconds = _chapterReader.initialPositionMs / 1000.0;
    return _pageIndexForSeconds(
      seconds,
      timings,
      fallback: _chapterReader.initialPageIndex,
    );
  }

  void _updateCurrentPage(int ms) {
    if (pageController == null || imageCount.value <= 0) return;
    if (!pageController!.hasClients || pageController!.page == null) return;
    final timings = media.value?.timings;
    if (timings == null || timings.isEmpty) return;
    final seconds = ms / 1000.0;
    final target = _pageIndexForSeconds(seconds, timings, fallback: 0);
    final current = pageController!.page!.round();
    if (target != current) {
      pageController!.animateToPage(
        target,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  int _pageIndexForSeconds(
    double seconds,
    List<PageTiming> timings, {
    required int fallback,
  }) {
    for (var i = 0; i < timings.length; i++) {
      final t = timings[i];
      if (t.startSeconds != null && t.endSeconds != null) {
        if (seconds >= t.startSeconds! && seconds <= t.endSeconds!) {
          return i;
        }
      }
    }
    for (var i = 0; i < timings.length; i++) {
      final t = timings[i];
      if (t.startSeconds != null && seconds < t.startSeconds!) {
        return i > 0 ? i - 1 : 0;
      }
    }
    final valid = timings.where((t) => t.startSeconds != null && t.endSeconds != null);
    if (valid.isNotEmpty) return timings.length - 1;
    return fallback;
  }

  void onPageChanged(int index) {
    if (index == _lastReportedPage) return;
    _lastReportedPage = index;
    _chapterReader.updatePage(index);
    _reportProgress();
  }

  void _reportProgress() {
    if (pageController == null) return;
    final total = imageCount.value;
    if (total <= 0) return;
    final index = pageController!.page?.round() ?? _chapterReader.initialPageIndex;
    final progress = ((index + 1) / total).clamp(0.0, 1.0).toDouble();
    _chapterReader.updateProgress(progress);
  }

  Future<ImageMedia> _loadMedia() async {
    final imageRows = await _repository.getChapterAssets(
      _chapterReader.chapter.id,
      assetType: 'IMAGE',
    );
    final images = <String>[];
    final timings = <PageTiming>[];
    for (final r in imageRows) {
      final path = r['file_path'] as String? ?? '';
      if (path.isEmpty) continue;
      final order = (r['sort_order'] as num?)?.toInt() ?? 0;
      final start = (r['audio_start_time'] as num?)?.toDouble();
      final end = (r['audio_end_time'] as num?)?.toDouble();
      images.add(path);
      timings.add(PageTiming(
        orderIndex: order,
        startSeconds: start,
        endSeconds: end,
      ));
    }

    final audioRows = await _repository.getChapterAssets(
      _chapterReader.chapter.id,
      assetType: 'AUDIO',
    );
    final audio = audioRows.map((r) => r['file_path'] as String).toList();

    return ImageMedia(images: images, audio: audio, timings: timings);
  }
}
