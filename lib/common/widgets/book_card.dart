import 'package:book_store/common/widgets/cover_image.dart';
import 'package:book_store/data/local/models/book_local_models.dart';
import 'package:flutter/material.dart';

class BookCard extends StatelessWidget {
  final LocalBook book;
  final bool isDownloaded;
  final bool isDownloading;
  final double progressPercent;
  final VoidCallback onTap;
  final VoidCallback onDownload;

  const BookCard({
    super.key,
    required this.book,
    required this.isDownloaded,
    required this.isDownloading,
    this.progressPercent = 0.0,
    required this.onTap,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CoverImage(
                coverUrl: book.coverUrl,
                width: 80,
                aspectRatio: 2 / 3,
                borderRadius: 8.0,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (book.description != null && book.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        book.description!,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Chip(
                      label: Text(
                        book.type == LocalBookType.text ? 'TEXT' : 'IMAGE',
                        style: const TextStyle(fontSize: 10),
                      ),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                    if (isDownloaded && progressPercent > 0) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: LinearProgressIndicator(
                          value: progressPercent,
                          color: Colors.green,
                          backgroundColor: Colors.grey.shade300,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              isDownloading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : isDownloaded
                      ? const Icon(Icons.download_done, color: Colors.green)
                      : IconButton(
                          icon: const Icon(Icons.download),
                          onPressed: onDownload,
                        ),
            ],
          ),
        ),
      ),
    );
  }
}
