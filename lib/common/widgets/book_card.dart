import 'package:book_store/common/widgets/cover_image.dart';
import 'package:book_store/data/local/models/book_local_models.dart';
import 'package:book_store/data/remote/sync_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BookCard extends StatelessWidget {
  final LocalBook book;
  final bool isDownloaded;
  final bool isDownloading;
  final double progressPercent;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onDownload;
  final VoidCallback onFavorite;

  const BookCard({
    super.key,
    required this.book,
    required this.isDownloaded,
    required this.isDownloading,
    this.progressPercent = 0.0,
    this.isFavorite = false,
    required this.onTap,
    required this.onDownload,
    required this.onFavorite,
  });

  /// Returns a label and icon based on book type
  (String label, IconData icon) _getTypeInfo() {
    switch (book.type) {
      case LocalBookType.text:
        return ('scrollable', Icons.text_snippet);
      case LocalBookType.image:
        return ('swappable', Icons.swap_horiz);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (typeLabel, typeIcon) = _getTypeInfo();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Cover image with a soft shadow
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CoverImage(
                      coverUrl: book.coverUrl,
                      width: 70,
                      aspectRatio: 2 / 3,
                      borderRadius: 10,
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Title, type label, progress bar
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        book.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),

                      // Type label as a small rounded container with icon
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withOpacity(
                            0.5,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              typeIcon,
                              size: 14,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              typeLabel,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.w500,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Progress bar (only if downloaded and progress > 0)
                      if (isDownloaded && progressPercent > 0) ...[
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: LinearProgressIndicator(
                            value: progressPercent,
                            minHeight: 4,
                            color: theme.colorScheme.primary,
                            backgroundColor: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Action icons (favorite + download)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Favorite button
                    IconButton(
                      icon: Icon(
                        isFavorite ? Icons.bookmark : Icons.bookmark_outline,
                        color: isFavorite
                            ? Colors.red
                            : theme.colorScheme.onSurfaceVariant,
                        size: 24,
                      ),
                      onPressed: onFavorite,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                      splashRadius: 20,
                    ),
                    const SizedBox(height: 4),

                    // Download / progress button
                    isDownloading
                        ? Obx(() {
                            final progress =
                                Get.find<SyncManager>()
                                    .bookDownloadProgress[book.id] ??
                                0.0;
                            return SizedBox(
                              width: 40,
                              height: 40,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    value: progress,
                                    strokeWidth: 2.5,
                                    color: theme.colorScheme.primary,
                                  ),
                                  Text(
                                    '${(progress * 100).round()}%',
                                    style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          })
                        : IconButton(
                            icon: Icon(
                              isDownloaded
                                  ? Icons.check_circle_outline
                                  : Icons.cloud_download_outlined,
                              color: isDownloaded
                                  ? Colors.green
                                  : theme.colorScheme.onSurfaceVariant,
                              size: 26,
                            ),
                            onPressed: onDownload,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 40,
                              minHeight: 40,
                            ),
                            splashRadius: 20,
                          ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
