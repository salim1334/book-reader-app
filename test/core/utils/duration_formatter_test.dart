import 'package:book_store/core/utils/duration_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatDuration', () {
    test('returns MM:SS when hours are zero', () {
      expect(formatDuration(const Duration(minutes: 5, seconds: 9)), '05:09');
    });

    test('returns H:MM:SS when there are hours', () {
      expect(
        formatDuration(const Duration(hours: 2, minutes: 5, seconds: 9)),
        '2:05:09',
      );
    });

    test('pads seconds only', () {
      expect(formatDuration(const Duration(seconds: 1)), '00:01');
    });

    test('handles zero duration', () {
      expect(formatDuration(Duration.zero), '00:00');
    });
  });
}
