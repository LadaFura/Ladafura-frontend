/// Formatages de données pour l'écosystème LADAFURA.
class AppFormatters {
  AppFormatters._();

  /// Formate un montant numérique en Francs CFA avec séparateur d'espace pour les milliers.
  ///
  /// Exemples :
  /// - `2500` -> `"2 500 FCFA"`
  /// - `150000` -> `"150 000 FCFA"`
  /// - `null` -> `"0 FCFA"`
  static String formatFCFA(num? amount) {
    if (amount == null) return '0 FCFA';
    final intAmount = amount.toInt();
    final formatted = intAmount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );
    return '$formatted FCFA';
  }

  /// Formate un numéro de téléphone malien vers la forme standardisée internationale.
  ///
  /// Exemples :
  /// - `"70123456"` -> `"+223 70 12 34 56"`
  /// - `"+22370123456"` -> `"+223 70 12 34 56"`
  static String formatPhoneMali(String? rawPhone) {
    if (rawPhone == null || rawPhone.trim().isEmpty) return '';
    final digits = rawPhone.replaceAll(RegExp(r'\D'), '');

    String local8Digits;
    if (digits.startsWith('223') && digits.length >= 11) {
      local8Digits = digits.substring(3, 11);
    } else if (digits.length >= 8) {
      local8Digits = digits.substring(digits.length - 8);
    } else {
      return rawPhone.trim();
    }

    final p1 = local8Digits.substring(0, 2);
    final p2 = local8Digits.substring(2, 4);
    final p3 = local8Digits.substring(4, 6);
    final p4 = local8Digits.substring(6, 8);

    return '+223 $p1 $p2 $p3 $p4';
  }

  /// Formate une taille de fichier en octets vers une chaîne lisible (Ko, Mo, Go).
  static String formatFileSize(int bytes) {
    if (bytes <= 0) return '0 o';
    if (bytes < 1024) return '$bytes o';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} Ko';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} Mo';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} Go';
  }

  /// Formate une durée temporelle (ex: enregistrement audio ou temps d'attente).
  ///
  /// Exemples :
  /// - `Duration(seconds: 75)` -> `"01:15"`
  /// - `Duration(hours: 1, minutes: 2, seconds: 3)` -> `"01:02:03"`
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    if (hours > 0) {
      final hoursStr = hours.toString().padLeft(2, '0');
      return '$hoursStr:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }
}
