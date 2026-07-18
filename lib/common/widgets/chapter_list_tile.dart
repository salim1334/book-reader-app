import 'package:book_store/data/local/models/book_local_models.dart';
import 'package:flutter/material.dart';

class ChapterListTile extends StatelessWidget {
  final int index;
  final LocalChapter chapter;
  final double progress;
  final bool isOutdated;
  final bool isDownloading;
  final VoidCallback onTap;

  const ChapterListTile({
    super.key,
    required this.index,
    required this.chapter,
    required this.progress,
    required this.isOutdated,
    required this.isDownloading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progressText = chapter.isDownloaded ? '${(progress * 100).round()}%' : null;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: progress >= 1.0 ? Colors.green : null,
        child: Text('${index + 1}'),
      ),
      title: Text(chapter.title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            chapter.description ??
                (chapter.isDownloaded ? 'Downloaded' : 'Tap to download'),
          ),
          if (chapter.isDownloaded && progressText != null) ...[
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: LinearProgressIndicator(
                value: progress,
                color: Colors.green,
                backgroundColor: Colors.grey.shade300,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              progressText,
              style: const TextStyle(
                color: Colors.green,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
      trailing: _trailingWidget(),
      onTap: onTap,
    );
  }

  Widget _trailingWidget() {
    if (isDownloading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    if (chapter.isDownloaded) {
      return isOutdated
          ? const Icon(Icons.update)
          : const Icon(Icons.chevron_right);
    }
    return const Icon(Icons.download);
  }
}
