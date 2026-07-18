import 'dart:async';

import 'package:book_store/data/local/models/book_local_models.dart';
import 'package:book_store/core/services/audio_player_service.dart';
import 'package:book_store/core/utils/asset_url.dart';
import 'package:book_store/data/repositories/book_repository.dart';
import 'package:book_store/features/chapter_reader/controllers/chapter_reader_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TextReaderController extends GetxController {
  final BookRepository _repository = Get.find<BookRepository>();
  final AudioPlayerService _audio = Get.find<AudioPlayerService>();
  late final ChapterReaderController _chapterReader = Get.find<ChapterReaderController>();

  ChapterReaderController get chapterReader => _chapterReader;

  late final ScrollController scrollController;
  late final List<GlobalKey> segmentKeys;

  final positionMs = 0.obs;
  final audioDurationMs = 0.obs;
  final hasAudio = false.obs;
  final currentSegmentIndex = (-1).obs;

  Worker? _positionWorker;
  Worker? _durationWorker;

  @override
  void onInit() {
    super.onInit();
    positionMs.value = _chapterReader.initialPositionMs;
    final segments = _chapterReader.chapter.contentSegments;
    segmentKeys = List.generate(segments?.length ?? 0, (_) => GlobalKey());
    scrollController = ScrollController();
    scrollController.addListener(_onScroll);

    _updateCurrentSegment();

    if (_chapterReader.book.type == LocalBookType.text) {
      _initAudio();
    } else {
      hasAudio.value = false;
    }
  }

  @override
  void onClose() {
    _positionWorker?.dispose();
    _durationWorker?.dispose();
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.onClose();
  }

  Future<void> _initAudio() async {
    final rows = await _repository.getChapterAssets(
      _chapterReader.chapter.id,
      assetType: 'AUDIO',
    );
    final paths = rows.map((r) => r['file_path'] as String).toList();

    if (paths.isEmpty) {
      await _audio.stop();
      hasAudio.value = false;
      return;
    }

    hasAudio.value = true;

    _positionWorker = interval(
      _audio.position,
      (pos) => _onPositionChanged(pos.inMilliseconds),
      time: const Duration(milliseconds: 250),
    );
    _durationWorker = ever(
      _audio.duration,
      (dur) => _onDurationChanged(dur.inMilliseconds),
    );

    // If already playing this exact chapter, don't reset the source.
    if (_audio.isCurrentBookChapter(_chapterReader.book, _chapterReader.chapter)) {
      return;
    }

    final artUri = coverArtUri(_chapterReader.book);
    await _audio.playQueue(
      AudioQueue(
        items: [
          AudioItem(
            id: '${_chapterReader.book.id}_${_chapterReader.chapter.id}_0',
            title: _chapterReader.chapter.title,
            subtitle: _chapterReader.book.title,
            path: paths.first,
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

  void _onScroll() {
    final max = scrollController.position.maxScrollExtent;
    if (max <= 0) return;
    final progress = (scrollController.offset / max).clamp(0.0, 1.0).toDouble();
    _chapterReader.updateProgress(progress);
  }

  void _onPositionChanged(int ms) {
    _chapterReader.updatePosition(ms);
    positionMs.value = ms;
    _updateCurrentSegment();
    _updateAudioProgress();
  }

  void _onDurationChanged(int durationMs) {
    audioDurationMs.value = durationMs;
    _updateAudioProgress();
  }

  void _updateAudioProgress() {
    if (audioDurationMs.value <= 0) return;
    final progress = (positionMs.value / audioDurationMs.value).clamp(0.0, 1.0).toDouble();
    _chapterReader.updateProgress(progress);
  }

  void _updateCurrentSegment() {
    final segments = _chapterReader.chapter.contentSegments;
    if (segments == null || segments.isEmpty) return;

    final seconds = positionMs.value / 1000.0;
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

    if (index != currentSegmentIndex.value) {
      currentSegmentIndex.value = index;
      if (index != -1) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _scrollToSegment(index),
        );
      }
    }
  }

  void _scrollToSegment(int index) {
    if (index < 0 || index >= segmentKeys.length) return;
    final ctx = segmentKeys[index].currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      alignment: 0.5,
      duration: const Duration(milliseconds: 300),
    );
  }
}
