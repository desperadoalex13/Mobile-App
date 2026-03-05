import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/shared/utils/date_utils.dart';

void main() {
  group('AppDateUtils', () {
    group('startOfWeek', () {
      test('returns Monday for a Wednesday', () {
        final wednesday = DateTime(2026, 3, 4); // Wednesday
        expect(wednesday.startOfWeek, DateTime(2026, 3, 2)); // Monday
      });

      test('returns same day for Monday', () {
        final monday = DateTime(2026, 3, 2);
        expect(monday.startOfWeek, monday);
      });

      test('returns correct Monday for Sunday', () {
        final sunday = DateTime(2026, 3, 8);
        expect(sunday.startOfWeek, DateTime(2026, 3, 2));
      });

      test('returns correct Monday for Saturday', () {
        final saturday = DateTime(2026, 3, 7);
        expect(saturday.startOfWeek, DateTime(2026, 3, 2));
      });
    });

    group('isSameDay', () {
      test('returns true for same date', () {
        final a = DateTime(2026, 3, 6, 9, 0);
        final b = DateTime(2026, 3, 6, 23, 59);
        expect(a.isSameDay(b), isTrue);
      });

      test('returns false for different day', () {
        final a = DateTime(2026, 3, 6);
        final b = DateTime(2026, 3, 7);
        expect(a.isSameDay(b), isFalse);
      });

      test('returns false for same day different month', () {
        final a = DateTime(2026, 3, 6);
        final b = DateTime(2026, 4, 6);
        expect(a.isSameDay(b), isFalse);
      });

      test('returns false for same day different year', () {
        final a = DateTime(2026, 3, 6);
        final b = DateTime(2025, 3, 6);
        expect(a.isSameDay(b), isFalse);
      });
    });

    group('toDisplayDate', () {
      test('formats March 6 correctly', () {
        expect(DateTime(2026, 3, 6).toDisplayDate(), 'Mar 6');
      });

      test('formats January 1 correctly', () {
        expect(DateTime(2026, 1, 1).toDisplayDate(), 'Jan 1');
      });

      test('formats December 31 correctly', () {
        expect(DateTime(2026, 12, 31).toDisplayDate(), 'Dec 31');
      });

      test('formats single-digit day without padding', () {
        expect(DateTime(2026, 6, 5).toDisplayDate(), 'Jun 5');
      });
    });
  });
}
