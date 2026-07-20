import 'package:book_store/common/widgets/cover_image.dart';
import 'package:book_store/features/home/domain/entities/continue_reading.dart';
import 'package:flutter/material.dart';

class ContinueReadingCard extends StatelessWidget {
  final ContinueReading reading;
  final VoidCallback onTap;
  final double progress;

  const ContinueReadingCard({
    super.key,
    required this.reading,
    required this.onTap,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 24, right: 10, left: 10),
      child: SizedBox(
        height: 215,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              right: 55,
              child: Material(
                borderRadius: BorderRadius.circular(28),
                color: Colors.transparent,
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.surfaceContainerHighest,
                        theme.colorScheme.surfaceContainer,
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: 80,
                        top: -20,
                        child: Icon(
                          Icons.menu_book_rounded,
                          size: 170,
                          color: theme.colorScheme.primary.withOpacity(.05),
                        ),
                      ),
                      Positioned.fill(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(28),
                          onTap: onTap,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              right: 70,
                              top: 8.0,
                              bottom: 8.0,
                              left: 16.0,
                            ),
                            child: _Content(
                              reading: reading,
                              progress: progress,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: 18,
              bottom: 18,
              child: Hero(
                tag: "continue_${reading.book.id}",
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Material(
                      elevation: 10,
                      borderRadius: BorderRadius.circular(22),
                      child: CoverImage(
                        coverUrl: reading.book.coverUrl,
                        width: 120,
                        height: 180,
                        borderRadius: 22,
                      ),
                    ),
                    Positioned(
                      bottom: -8,
                      right: -8,
                      child: Material(
                        color: theme.colorScheme.primary,
                        shape: const CircleBorder(),
                        elevation: 6,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: onTap,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Icon(
                              Icons.play_arrow_rounded,
                              size: 28,
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final ContinueReading reading;
  final double progress;

  const _Content({required this.reading, required this.progress});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.auto_stories, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 12),
            Text(
              "Continue Reading",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const Spacer(),
        Text(
          reading.book.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          reading.chapter.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 18),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(value: progress, minHeight: 8),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Text(
              '${(progress * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 6),
            const Text("completed"),
          ],
        ),
      ],
    );
  }
}
