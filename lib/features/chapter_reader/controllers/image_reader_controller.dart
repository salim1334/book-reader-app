import 'package:book_store/data/local/models/book_local_models.dart';
import 'package:book_store/core/services/audio_player_service.dart';
import 'package:book_store/core/utils/asset_url.dart';
import 'package:book_store/data/repositories/book_repository.dart';
import 'package:book_store/features/chapter_reader/controllers/chapter_reader_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ImageMedia {
  final List<String> images;
  final List<String> audio;

  const ImageMedia(this.images, this.audio);
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

  bool get _isImageBook => _chapterReader.book.type != LocalBookType.text;

  @override
  void onInit() {
    super.onInit();
    if (!_isImageBook) {
      isLoading.value = false;
      return;
    }

    pageController = PageController(initialPage: _chapterReader.initialPageIndex);
    pageController?.addListener(_onPageChanged);
    _initMedia();
  }

  @override
  void onClose() {
    pageController?.removeListener(_onPageChanged);
    pageController?.dispose();
    super.onClose();
  }

  Future<void> _initMedia() async {
    final loadedMedia = await _loadMedia();
    media.value = loadedMedia;
    imageCount.value = loadedMedia.images.length;
    isLoading.value = false;

    if (loadedMedia.audio.isNotEmpty) {
      final artUri = coverArtUri(_chapterReader.book);
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
            ),
          ],
        ),
        sourceTitle: _chapterReader.chapter.title,
        sourceSubtitle: _chapterReader.book.title,
        sourceArtUri: artUri,
      );
    } else {
      await _audio.stop();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _reportProgress());
  }

  void _onPageChanged() {
    if (pageController?.page == null) return;
    final index = pageController!.page!.round();
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
    final images = imageRows.map((r) => r['file_path'] as String).toList();

    final audioRows = await _repository.getChapterAssets(
      _chapterReader.chapter.id,
      assetType: 'AUDIO',
    );
    final audio = audioRows.map((r) => r['file_path'] as String).toList();

    return ImageMedia(images, audio);
  }
}
