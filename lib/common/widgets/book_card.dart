import 'package:book_store/common/widgets/cover_image.dart';
import 'package:book_store/core/utils/extensions/theme_extension.dart';
import 'package:book_store/data/local/models/book_local_models.dart';
import 'package:flutter/material.dart';

class BookCard extends StatelessWidget {
  final LocalBook book;
  final bool isDownloaded;
  final bool isDownloading;
  final double progressPercent;
  final double downloadProgress;
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
    this.downloadProgress = 0.0,
    this.isFavorite = false,
    required this.onTap,
    required this.onDownload,
    required this.onFavorite,
  });

  /// Returns localized label and icon based on book type
  (String label, IconData icon) _getTypeInfo() {
    switch (book.type) {
      case LocalBookType.text:
        return ('ጽሑፍ', Icons.text_snippet);
      case LocalBookType.image:
        return ('ምስል', Icons.swap_horiz);
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
                // Cover Image
                _BookCover(coverUrl: book.coverUrl!),
                const SizedBox(width: 16),

                // Title, type label, and reading progress bar
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

                      // Format type badge
                      _TypeBadge(label: typeLabel, icon: typeIcon),

                      // Reading progress bar
                      if (isDownloaded && progressPercent > 0) ...[
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progressPercent,
                            minHeight: 4,
                            color: theme.colorScheme.primary,
                            backgroundColor:
                                theme.colorScheme.surfaceContainerHighest,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Action icons (favorite & download)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        isFavorite ? Icons.bookmark : Icons.bookmark_outline,
                        color: isFavorite
                            ? context.sacred.gold
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

                    if (isDownloading)
                      _DownloadIndicator(progress: downloadProgress)
                    else
                      IconButton(
                        icon: Icon(
                          isDownloaded
                              ? Icons.check_circle_outline
                              : Icons.cloud_download_outlined,
                          color: isDownloaded
                              ? theme.colorScheme.primary
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

// ---- Private Sub-components ----

class _BookCover extends StatelessWidget {
  final String? coverUrl;

  const _BookCover({required this.coverUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          coverUrl: coverUrl,
          width: 70,
          aspectRatio: 2 / 3,
          borderRadius: 10,
        ),
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final String label;
  final IconData icon;

  const _TypeBadge({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _DownloadIndicator extends StatelessWidget {
  final double progress;

  const _DownloadIndicator({required this.progress});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
