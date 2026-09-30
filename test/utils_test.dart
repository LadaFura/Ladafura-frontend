import 'package:flutter_test/flutter_test.dart';
import 'package:ladafura_frontend_flutter/shared/utils/utils.dart';

void main() {
  group('Utils - AppValidators', () {
    test('required validator works properly', () {
      expect(AppValidators.required(''), isNotNull);
      expect(AppValidators.required('   '), isNotNull);
      expect(AppValidators.required(null), isNotNull);
      expect(AppValidators.required('Valid text'), isNull);
      expect(AppValidators.required('', 'Nom'), 'Nom est obligatoire');
    });

    test('email validator verifies proper email format', () {
      expect(AppValidators.email(null), isNotNull);
      expect(AppValidators.email(''), isNotNull);
      expect(AppValidators.email('invalid-email'), isNotNull);
      expect(AppValidators.email('test@'), isNotNull);
      expect(AppValidators.email('@domain.com'), isNotNull);
      expect(AppValidators.email('fatoumata.diarra@gmail.com'), isNull);
      expect(AppValidators.email('agent@ladafura.ml'), isNull);
    });

    test('password validator enforces minimum length', () {
      expect(AppValidators.password(null), isNotNull);
      expect(AppValidators.password('12345'), isNotNull); // < 6
      expect(AppValidators.password('123456'), isNull);
      expect(AppValidators.password('Mali2026!'), isNull);
      expect(AppValidators.password('short', minLength: 8), isNotNull);
    });

    test('confirmPassword checks password matching', () {
      expect(AppValidators.confirmPassword('pass', 'pass'), isNull);
      expect(AppValidators.confirmPassword('pass1', 'pass2'), isNotNull);
      expect(AppValidators.confirmPassword('', 'pass'), isNotNull);
    });

    test('phoneMali validator validates Malian phone numbers', () {
      expect(AppValidators.phoneMali(null), isNull); // optional
      expect(AppValidators.phoneMali('', isRequired: true), isNotNull);
      expect(AppValidators.phoneMali('12345678'),
          isNotNull); // doesn't start with 5-9
      expect(AppValidators.phoneMali('70 12 34 56'), isNull);
      expect(AppValidators.phoneMali('+223 70 12 34 56'), isNull);
      expect(AppValidators.phoneMali('00223 66 12 34 56'), isNull);
      expect(AppValidators.phoneMali('90123456'), isNull);
      expect(AppValidators.phoneMali('50123456'), isNull);
    });

    test('positiveNumber validates numeric positive inputs', () {
      expect(AppValidators.positiveNumber(null), isNotNull);
      expect(AppValidators.positiveNumber('0'), isNotNull);
      expect(AppValidators.positiveNumber('-100'), isNotNull);
      expect(AppValidators.positiveNumber('abc'), isNotNull);
      expect(AppValidators.positiveNumber('2500'), isNull);
      expect(AppValidators.positiveNumber('10 000'), isNull);
    });
  });

  group('Utils - AppFormatters', () {
    test('formatFCFA formats amounts with thousands separator', () {
      expect(AppFormatters.formatFCFA(null), '0 FCFA');
      expect(AppFormatters.formatFCFA(0), '0 FCFA');
      expect(AppFormatters.formatFCFA(500), '500 FCFA');
      expect(AppFormatters.formatFCFA(2500), '2 500 FCFA');
      expect(AppFormatters.formatFCFA(150000), '150 000 FCFA');
      expect(AppFormatters.formatFCFA(1000000), '1 000 000 FCFA');
    });

    test(
        'formatPhoneMali formats phone numbers into international Mali notation',
        () {
      expect(AppFormatters.formatPhoneMali(null), '');
      expect(AppFormatters.formatPhoneMali(''), '');
      expect(AppFormatters.formatPhoneMali('70123456'), '+223 70 12 34 56');
      expect(AppFormatters.formatPhoneMali('+22370123456'), '+223 70 12 34 56');
      expect(
          AppFormatters.formatPhoneMali('0022370123456'), '+223 70 12 34 56');
    });

    test('formatFileSize formats bytes to human readable sizes', () {
      expect(AppFormatters.formatFileSize(0), '0 o');
      expect(AppFormatters.formatFileSize(500), '500 o');
      expect(AppFormatters.formatFileSize(2048), '2.0 Ko');
      expect(AppFormatters.formatFileSize(1048576 * 3), '3.0 Mo');
    });

    test('formatDuration formats Duration objects to HH:MM:SS or MM:SS', () {
      expect(
          AppFormatters.formatDuration(const Duration(seconds: 45)), '00:45');
      expect(
          AppFormatters.formatDuration(const Duration(minutes: 2, seconds: 30)),
          '02:30');
      expect(
          AppFormatters.formatDuration(
              const Duration(hours: 1, minutes: 15, seconds: 4)),
          '01:15:04');
    });
  });

  group('Utils - AppDateUtils', () {
    test('parseIsoDate parses valid and invalid ISO strings', () {
      expect(AppDateUtils.parseIsoDate(null), isNull);
      expect(AppDateUtils.parseIsoDate('invalid-date'), isNull);
      final date = AppDateUtils.parseIsoDate('2026-09-29T14:30:00');
      expect(date, isNotNull);
      expect(date!.year, 2026);
      expect(date.month, 9);
      expect(date.day, 29);
      expect(date.hour, 14);
      expect(date.minute, 30);
    });

    test('formatDate and formatDateTime format dates correctly', () {
      final date = DateTime(2026, 9, 29, 14, 30);
      expect(AppDateUtils.formatDate(date), '29/09/2026');
      expect(AppDateUtils.formatDateTime(date), '29/09/2026 à 14:30');
      expect(AppDateUtils.formatDateComplete(date), '29 septembre 2026');
      expect(AppDateUtils.formatTime(date), '14:30');
    });

    test('formatRelative calculates time distance cleanly', () {
      final now = DateTime(2026, 9, 29, 15, 00);
      expect(
          AppDateUtils.formatRelative(now.subtract(const Duration(seconds: 30)),
              now: now),
          "À l'instant");
      expect(
          AppDateUtils.formatRelative(now.subtract(const Duration(minutes: 15)),
              now: now),
          "Il y a 15 min");
      expect(
          AppDateUtils.formatRelative(now.subtract(const Duration(hours: 3)),
              now: now),
          "Il y a 3 h");
      expect(
          AppDateUtils.formatRelative(now.subtract(const Duration(days: 1)),
              now: now),
          "Hier à 15:00");
      expect(
          AppDateUtils.formatRelative(now.subtract(const Duration(days: 4)),
              now: now),
          "Il y a 4 jours");
    });
  });
}
