import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:book_store/data/local/models/book_local_models.dart';
import 'package:book_store/data/repositories/book_repository.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

class AudioItem {
  final String id;
  final String title;
  final String? subtitle;
  final String path;
  final String? artUri;
  final LocalBook? book;
  final LocalChapter? chapter;
  final int initialPositionMs;

  const AudioItem({
    required this.id,
    required this.title,
    this.subtitle,
    required this.path,
    this.artUri,
    this.book,
    this.chapter,
    this.initialPositionMs = 0,
  });

  MediaItem toMediaItem(Duration duration) {
    return MediaItem(
      id: id,
      title: title,
      album: subtitle ?? book?.title ?? '',
      artist: book?.title ?? '',
      duration: duration,
      artUri: artUri != null && artUri!.isNotEmpty ? Uri.parse(artUri!) : null,
      extras: <String, dynamic>{
        'path': path,
        'initialPositionMs': initialPositionMs,
        if (book != null) 'bookId': book!.id,
        if (chapter != null) 'chapterId': chapter!.id,
      },
    );
  }
}

class AudioQueue {
  final List<AudioItem> items;
  final int startIndex;

  const AudioQueue({
    required this.items,
    this.startIndex = 0,
  });
}

class AudioPlayerService extends GetxService {
  late _BookReaderAudioHandler _handler;
  final _initialized = false.obs;

  final currentTitle = ''.obs;
  final currentSubtitle = ''.obs;
  final currentArtUri = Rxn<String>();
  final isPlaying = false.obs;
  final isLoading = false.obs;
  final position = Duration.zero.obs;
  final duration = Duration.zero.obs;
  final bufferedPosition = Duration.zero.obs;
  final speed = 1.0.obs;
  final volume = 1.0.obs;
  final hasMedia = false.obs;
  final currentIndex = 0.obs;
  final queueLength = 0.obs;
  final isReaderActive = false.obs;

  /// The book/chapter currently being played, used to reopen the reader from
  /// the mini player.
  LocalBook? currentBook;
  LocalChapter? currentChapter;

  bool get isInitialized => _initialized.value;

  bool isCurrentBookChapter(LocalBook book, LocalChapter chapter) {
    return hasMedia.value &&
        currentBook?.id == book.id &&
        currentChapter?.id == chapter.id;
  }

  AudioPlayerService() {
    _BookReaderAudioHandler.service = this;
  }

  Future<AudioPlayerService> init() async {
    _handler = await AudioService.init<_BookReaderAudioHandler>(
      builder: () => _BookReaderAudioHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.book_store.channel.audio',
        androidNotificationChannelName: 'Audio playback',
        androidNotificationOngoing: true,
        androidResumeOnClick: true,
        androidNotificationClickStartsActivity: true,
      ),
    );
    _initialized.value = true;
    _listenToState();
    return this;
  }

  void _listenToState() {
    _handler.playbackState.listen((state) {
      isPlaying.value = state.playing;
      currentIndex.value = state.queueIndex ?? 0;
      position.value = state.position;
      bufferedPosition.value = state.bufferedPosition;
      speed.value = state.speed;
    });

    _handler.mediaItem.listen((item) {
      if (item != null) {
        currentTitle.value = item.title;
        currentSubtitle.value = item.album ?? '';
        currentArtUri.value = item.artUri?.toString();
        duration.value = item.duration ?? Duration.zero;
        hasMedia.value = true;
      } else {
        hasMedia.value = false;
      }
    });

    _handler.queue.listen((queue) {
      queueLength.value = queue.length;
    });
  }

  Future<void> playQueue(
    AudioQueue queue, {
    String? sourceTitle,
    String? sourceSubtitle,
    String? sourceArtUri,
  }) async {
    if (!_initialized.value) return;

    // If this exact chapter is already loaded, just continue from where we are
    // instead of resetting to the beginning.
    if (queue.items.isNotEmpty) {
      final startItem = queue.items[queue.startIndex];
      if (startItem.book != null &&
          startItem.chapter != null &&
          hasMedia.value &&
          currentBook?.id == startItem.book!.id &&
          currentChapter?.id == startItem.chapter!.id) {
        return;
      }
    }

    isLoading.value = true;
    try {
      final mediaItems = <MediaItem>[];
      for (var i = 0; i < queue.items.length; i++) {
        final item = queue.items[i];
        final duration = await _estimateDuration(item.path);
        final mediaItem = item.toMediaItem(duration).copyWith(
          album: sourceSubtitle ?? item.subtitle ?? item.book?.title ?? '',
          artUri: sourceArtUri != null && sourceArtUri.isNotEmpty
              ? Uri.parse(sourceArtUri)
              : item.toMediaItem(duration).artUri,
        );
        mediaItems.add(mediaItem);
      }

      await _handler.updateQueue(mediaItems);
      await _handler.skipToQueueItem(queue.startIndex);

      final startItem = queue.items[queue.startIndex];
      currentBook = startItem.book;
      currentChapter = startItem.chapter;
    } finally {
      isLoading.value = false;
    }

    // play() returns a future that completes when playback completes or is
    // paused/stopped, so we must not await it here. Awaiting it would keep
    // isLoading true for the entire duration of playback.
    unawaited(_handler.play());
  }

  Future<Duration> _estimateDuration(String path) async {
    final tempPlayer = AudioPlayer();
    try {
      return await tempPlayer.setAudioSource(
            AudioSource.uri(Uri.file(path)),
          ) ??
          Duration.zero;
    } catch (_) {
      return Duration.zero;
    } finally {
      await tempPlayer.dispose();
    }
  }

  Future<void> play() => _handler.play();
  Future<void> pause() => _handler.pause();
  Future<void> togglePlayPause() async {
    if (isPlaying.value) {
      await pause();
    } else {
      // play() completes when playback completes/pauses/stops, so don't await.
      unawaited(play());
    }
  }

  Future<void> seek(Duration pos) => _handler.seek(pos);
  Future<void> skipToNext() => _handler.skipToNext();
  Future<void> skipToPrevious() => _handler.skipToPrevious();

  Future<void> setSpeed(double value) async {
    final clamped = value.clamp(0.5, 2.0).toDouble();
    await _handler.setSpeed(clamped);
    speed.value = clamped;
  }

  Future<void> setVolume(double value) async {
    final clamped = value.clamp(0.0, 1.0).toDouble();
    await _handler.setVolume(clamped);
    volume.value = clamped;
  }

  Future<void> stop() => _handler.stop();

  Future<void> persistCurrentProgress() async {
    if (!_initialized.value || !hasMedia.value) return;
    final item = _handler.mediaItem.valueOrNull;
    if (item == null) return;

    final bookId = item.extras?['bookId'] as String?;
    final chapterId = item.extras?['chapterId'] as String?;
    if (bookId == null || chapterId == null) return;

    final positionMs = position.value.inMilliseconds;
    final repository = Get.find<BookRepository>();

    await repository.saveProgress(
      bookId: bookId,
      chapterId: chapterId,
      lastPositionMs: positionMs,
      lastPageIndex: 0,
      chapterProgressPercent: _progressFromPosition(duration.value, position.value),
    );
  }

  double _progressFromPosition(Duration total, Duration current) {
    if (total.inMilliseconds <= 0) return 0.0;
    return (current.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0).toDouble();
  }

  @override
  void onClose() {
    persistCurrentProgress();
    unawaited(_handler.stop().then((_) => _handler.dispose()));
    super.onClose();
  }
}

class _BookReaderAudioHandler extends BaseAudioHandler with SeekHandler {
  static AudioPlayerService? service;

  final _player = AudioPlayer();
  int _currentIndex = 0;
  Timer? _progressTimer;

  _BookReaderAudioHandler() {
    _init();
  }

  Future<void> _init() async {
    await _player.setLoopMode(LoopMode.off);

    _player.positionStream.listen((_) => _updatePlaybackState());
    _player.playbackEventStream.listen((_) => _updatePlaybackState());
    _player.durationStream.listen(_updateMediaItemDuration);

    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _onTrackCompleted();
      }
      _updatePlaybackState();
    });

    _player.currentIndexStream.listen((index) {
      if (index != null) {
        _currentIndex = index;
        _updateMediaItemFromQueue();
      }
    });

    _progressTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      service?.persistCurrentProgress();
    });
  }

  void _updatePlaybackState() {
    final processingState = _player.processingState;
    final controls = [
      MediaControl.skipToPrevious,
      _player.playing ? MediaControl.pause : MediaControl.play,
      MediaControl.skipToNext,
    ];

    playbackState.add(playbackState.value.copyWith(
      controls: controls,
      systemActions: {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
        MediaAction.playPause,
        MediaAction.stop,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: _mapProcessingState(processingState),
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: _player.currentIndex,
    ));
  }

  AudioProcessingState _mapProcessingState(ProcessingState state) {
    switch (state) {
      case ProcessingState.idle:
        return AudioProcessingState.idle;
      case ProcessingState.loading:
        return AudioProcessingState.loading;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
    }
  }

  void _updateMediaItemFromQueue() {
    final queue = this.queue.valueOrNull ?? [];
    if (_currentIndex < 0 || _currentIndex >= queue.length) return;

    final item = queue[_currentIndex];
    final current = mediaItem.valueOrNull;
    if (current == null || current.id != item.id) {
      mediaItem.add(item);
    }
  }

  void _updateMediaItemDuration(Duration? dur) {
    if (dur == null) return;
    final current = mediaItem.valueOrNull;
    if (current != null && (current.duration == null || current.duration! != dur)) {
      mediaItem.add(current.copyWith(duration: dur));
    }
  }

  Future<void> _onTrackCompleted() async {
    final queue = this.queue.valueOrNull ?? [];
    if (_currentIndex < queue.length - 1) {
      await skipToNext();
    } else {
      await _player.pause();
      await _player.seek(Duration.zero);
    }
  }

  @override
  Future<void> updateQueue(List<MediaItem> queue) async {
    this.queue.add(queue);
    _currentIndex = 0;

    if (queue.isEmpty) {
      await _player.stop();
      return;
    }

    final sources = queue.map((item) {
      final path = item.extras?['path'] as String? ?? '';
      return AudioSource.uri(Uri.file(path));
    }).toList();

    await _player.setAudioSource(
      ConcatenatingAudioSource(children: sources),
      initialIndex: 0,
    );
    _updateMediaItemFromQueue();
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index < 0 || index >= (this.queue.valueOrNull ?? []).length) return;

    _currentIndex = index;
    await _player.seek(Duration.zero, index: index);

    final queue = this.queue.valueOrNull ?? [];
    final item = queue[index];
    final initial = (item.extras?['initialPositionMs'] as num?)?.toInt() ?? 0;
    if (initial > 0) {
      await _player.seek(Duration(milliseconds: initial));
    }

    _updateMediaItemFromQueue();
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await service?.persistCurrentProgress();
    await _player.stop();
    mediaItem.add(null);
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() async {
    final queue = this.queue.valueOrNull ?? [];
    if (_currentIndex < queue.length - 1) {
      await skipToQueueItem(_currentIndex + 1);
    } else {
      await _player.seek(Duration.zero);
      await _player.pause();
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (_player.position.inSeconds > 3) {
      await _player.seek(Duration.zero);
    } else if (_currentIndex > 0) {
      await skipToQueueItem(_currentIndex - 1);
    }
  }

  @override
  Future<void> setSpeed(double speed) => _player.setSpeed(speed);

  Future<void> setVolume(double volume) => _player.setVolume(volume);

  @override
  Future<void> click([MediaButton button = MediaButton.media]) async {
    switch (button) {
      case MediaButton.media:
        if (_player.playing) {
          await pause();
        } else {
          await play();
        }
        break;
      case MediaButton.next:
        await skipToNext();
        break;
      case MediaButton.previous:
        await skipToPrevious();
        break;
    }
  }

  @override
  Future<void> onTaskRemoved() async {
    await stop();
    await super.onTaskRemoved();
  }

  Future<void> dispose() async {
    _progressTimer?.cancel();
    await _player.dispose();
  }
}
