import 'dart:async';

import 'package:book_store/core/services/audio_player_service.dart';
import 'package:book_store/core/utils/asset_url.dart';
import 'package:book_store/data/local/models/book_local_models.dart';
import 'package:book_store/data/repositories/book_repository.dart';
import 'package:book_store/data/repositories/settings_repository.dart';
import 'package:book_store/features/chapter_reader/controllers/chapter_reader_controller.dart';
import 'package:book_store/features/chapter_reader/models/page_photo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';

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
  final SettingsRepository _settings = Get.find<SettingsRepository>();

  late final ChapterReaderController _chapterReader =
      Get.find<ChapterReaderController>();

  ChapterReaderController get chapterReader => _chapterReader;

  final Map<int, PagePhotoController> photoControllers = {};

  PageController? pageController;

  final isLoading = true.obs;
  final imageCount = 0.obs;
  final media = Rxn<ImageMedia>();
  final currentPageIndex = 0.obs;

  final RxDouble currentScale = 1.0.obs;

  Worker? _pageWorker;

  int _lastReportedPage = -1;

  bool get _isImageBook => _chapterReader.book.type != LocalBookType.text;

  PagePhotoController getPhotoController(int index) {
    return photoControllers.putIfAbsent(index, () {
      final photoController = PhotoViewController();

      final scaleController = PhotoViewScaleStateController();

      photoController.outputStateStream.listen((state) {
        if (currentPageIndex.value == index) {
          currentScale.value = state.scale ?? 1.0;
        }
      });

      return PagePhotoController(
        photoController: photoController,
        scaleController: scaleController,
      );
    });
  }

  PagePhotoController get currentPhotoController =>
      getPhotoController(currentPageIndex.value);

  @override
  void onInit() {
    super.onInit();

    unawaited(reload());
  }

  Future<void> reload() async {
    _pageWorker?.dispose();

    pageController?.dispose();

    for (final page in photoControllers.values) {
      page.dispose();
    }

    photoControllers.clear();

    isLoading.value = true;
    imageCount.value = 0;
    media.value = null;
    currentPageIndex.value = 0;
    currentScale.value = 1.0;

    _lastReportedPage = -1;

    if (!_isImageBook) {
      isLoading.value = false;
      return;
    }

    try {
      await _initMedia();
    } catch (e, stack) {
      debugPrint('Image reader failed: $e');
      debugPrintStack(stackTrace: stack);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _pageWorker?.dispose();

    pageController?.dispose();

    for (final page in photoControllers.values) {
      page.dispose();
    }

    photoControllers.clear();

    super.onClose();
  }

  Future<void> _initMedia() async {
    final loadedMedia = await _loadMedia();

    if (loadedMedia.audio.isNotEmpty) {
      final artUri = coverArtUri(_chapterReader.book);

      final sameChapter = _audio.isCurrentBookChapter(
        _chapterReader.book,
        _chapterReader.chapter,
      );

      if (!sameChapter) {
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
          initialSpeed: _settings.defaultSpeed.value,
        );
      }
    } else {
      await _audio.stop();
    }

    final initialPage = _computeInitialPage(loadedMedia);

    final maxPage = loadedMedia.images.length - 1;

    final safePage = loadedMedia.images.isEmpty
        ? 0
        : initialPage.clamp(0, maxPage);

    pageController = PageController(initialPage: safePage);

    currentPageIndex.value = safePage;
    _lastReportedPage = safePage;

    media.value = loadedMedia;

    imageCount.value = loadedMedia.images.length;

    isLoading.value = false;

    if (loadedMedia.timings.any(
      (e) => e.startSeconds != null && e.endSeconds != null,
    )) {
      _pageWorker = interval(_audio.position, (position) {
        _updateCurrentPage(position.inMilliseconds);
      }, time: const Duration(milliseconds: 500));
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _reportProgress());
  }

  int _computeInitialPage(ImageMedia media) {
    if (media.timings.isEmpty) {
      return _chapterReader.initialPageIndex;
    }

    return _pageIndexForSeconds(
      _chapterReader.initialPositionMs / 1000,
      media.timings,
      fallback: _chapterReader.initialPageIndex,
    );
  }

  void _updateCurrentPage(int ms) {
    if (!_settings.autoScroll.value) return;

    if (pageController == null) return;

    if (!pageController!.hasClients) return;

    final timings = media.value?.timings;

    if (timings == null || timings.isEmpty) return;

    final target = _pageIndexForSeconds(ms / 1000, timings, fallback: 0);

    if (target != currentPageIndex.value) {
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

      if (t.startSeconds != null &&
          t.endSeconds != null &&
          seconds >= t.startSeconds! &&
          seconds <= t.endSeconds!) {
        return i;
      }
    }

    return fallback;
  }

  void onPageChanged(int index) {
    if (index == _lastReportedPage) return;

    final previousIndex = _lastReportedPage;

    _lastReportedPage = index;

    currentPageIndex.value = index;

    // Reset the page we are leaving and the page we just landed on so
    // zoom does not persist across pages.
    if (previousIndex >= 0) {
      photoControllers[previousIndex]?.reset();
    }
    currentPhotoController.reset();

    currentScale.value = currentPhotoController.scale;

    _chapterReader.updatePage(index);

    _reportProgress();
  }

  bool get isZoomed => currentScale.value > 1.0;

  void _reportProgress() {
    if (imageCount.value <= 0) return;

    final progress = ((currentPageIndex.value + 1) / imageCount.value).clamp(
      0.0,
      1.0,
    );

    _chapterReader.updateProgress(progress);
  }

  Future<ImageMedia> _loadMedia() async {
    final imageRows = List<Map<String, dynamic>>.from(
      await _repository.getChapterAssets(
        _chapterReader.chapter.id,
        assetType: 'IMAGE',
      ),
    );

    imageRows.sort((a, b) {
      final aOrder = (a['sort_order'] as num?)?.toInt() ?? 0;

      final bOrder = (b['sort_order'] as num?)?.toInt() ?? 0;

      return aOrder.compareTo(bOrder);
    });

    final images = <String>[];

    final timings = <PageTiming>[];

    for (final row in imageRows) {
      final path = row['file_path'] as String? ?? '';

      if (path.isEmpty) continue;

      images.add(path);

      timings.add(
        PageTiming(
          orderIndex: (row['sort_order'] as int?) ?? 0,
          startSeconds: (row['audio_start_time'] as num?)?.toDouble(),
          endSeconds: (row['audio_end_time'] as num?)?.toDouble(),
        ),
      );
    }

    final audioRows = await _repository.getChapterAssets(
      _chapterReader.chapter.id,
      assetType: 'AUDIO',
    );

    final audio = audioRows.map((e) => e['file_path'] as String).toList();

    return ImageMedia(images: images, audio: audio, timings: timings);
  }

  void nextPage() {
    if (pageController == null) return;

    if (currentPageIndex.value >= imageCount.value - 1) return;

    pageController!.nextPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.ease,
    );
  }

  void previousPage() {
    if (pageController == null) return;

    if (currentPageIndex.value <= 0) return;

    pageController!.previousPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.ease,
    );
  }

  void zoomIn() {
    currentPhotoController.zoomIn();
  }

  void zoomOut() {
    currentPhotoController.zoomOut();
  }

  void resetZoom() {
    currentPhotoController.reset();

    currentScale.value = 1.0;
  }
}
