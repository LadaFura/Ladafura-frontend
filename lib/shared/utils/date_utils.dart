/// Utilitaires de manipulation et de formatage des dates et heures locales (Mali).
class AppDateUtils {
  AppDateUtils._();

  static const List<String> _moisFrancais = [
    'janvier',
    'février',
    'mars',
    'avril',
    'mai',
    'juin',
    'juillet',
    'août',
    'septembre',
    'octobre',
    'novembre',
    'décembre',
  ];

  /// Analyse une chaîne de date ISO-8601 (ex: `2026-09-29T14:30:00`).
  static DateTime? parseIsoDate(String? isoString) {
    if (isoString == null || isoString.trim().isEmpty) return null;
    try {
      return DateTime.parse(isoString.trim());
    } catch (_) {
      return null;
    }
  }

  /// Formate une date au format court numérique : `JJ/MM/AAAA` (ex: `29/09/2026`).
  static String formatDate(DateTime? date) {
    if (date == null) return '';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  /// Formate une date et son heure : `JJ/MM/AAAA à HH:mm` (ex: `29/09/2026 à 14:30`).
  static String formatDateTime(DateTime? date) {
    if (date == null) return '';
    final dateStr = formatDate(date);
    final hours = date.hour.toString().padLeft(2, '0');
    final minutes = date.minute.toString().padLeft(2, '0');
    return '$dateStr à $hours:$minutes';
  }

  /// Formate une date en toutes lettres : `29 septembre 2026`.
  static String formatDateComplete(DateTime? date) {
    if (date == null) return '';
    final day = date.day;
    final mois = _moisFrancais[date.month - 1];
    final year = date.year;
    return '$day $mois $year';
  }

  /// Formate une heure : `HH:mm` (ex: `14:30`).
  static String formatTime(DateTime? date) {
    if (date == null) return '';
    final hours = date.hour.toString().padLeft(2, '0');
    final minutes = date.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  /// Calcule un temps relatif convivial (ex: "À l'instant", "Il y a 5 min", "Hier", "Il y a 3 jours").
  static String formatRelative(DateTime? date, {DateTime? now}) {
    if (date == null) return '';
    final current = now ?? DateTime.now();
    final difference = current.difference(date);

    if (difference.inSeconds < 60 && difference.inSeconds >= 0) {
      return "À l'instant";
    } else if (difference.inMinutes < 60 && difference.inMinutes > 0) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24 && difference.inHours > 0) {
      return 'Il y a ${difference.inHours} h';
    } else if (difference.inDays == 1) {
      return 'Hier à ${formatTime(date)}';
    } else if (difference.inDays < 7 && difference.inDays > 1) {
      return 'Il y a ${difference.inDays} jours';
    } else {
      return formatDate(date);
    }
  }
}
