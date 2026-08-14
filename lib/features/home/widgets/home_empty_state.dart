import 'package:book_store/core/constants/app_texts.dart';
import 'package:flutter/material.dart';

/// Modern empty state for the Home screen shown when no books are available
/// yet (e.g. while the bundled catalog is still importing on slow devices, or
/// before the remote catalog has ever been fetched).
class HomeEmptyState extends StatelessWidget {
  final bool isChecking;
  final VoidCallback onCheckForBooks;

  const HomeEmptyState({
    super.key,
    required this.isChecking,
    required this.onCheckForBooks,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 112,
              width: 112,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_stories_outlined,
                size: 52,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              AppTexts.homeEmptyTitle,
              textAlign: TextAlign.center,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppTexts.homeEmptyBody,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: isChecking ? null : onCheckForBooks,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              icon: isChecking
                  ? SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.onPrimary,
                      ),
                    )
                  : const Icon(Icons.refresh_rounded),
              label: Text(
                AppTexts.homeCheckForBooks,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
