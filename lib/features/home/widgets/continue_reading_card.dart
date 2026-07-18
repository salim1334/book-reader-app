import 'package:book_store/common/widgets/cover_image.dart';
import 'package:book_store/features/home/domain/entities/continue_reading.dart';
import 'package:flutter/material.dart';

class ContinueReadingCard extends StatelessWidget {
  final ContinueReading reading;
  final VoidCallback onTap;

  const ContinueReadingCard({super.key, required this.reading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12.0),
      child: ListTile(
        leading: ClipOval(
          child: CoverImage(
            coverUrl: reading.book.coverUrl,
            width: 40,
            height: 40,
            borderRadius: 0,
          ),
        ),
        title: const Text('Continue reading'),
        subtitle: Text('${reading.book.title} · ${reading.chapter.title}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
