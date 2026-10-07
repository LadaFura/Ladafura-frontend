import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Utilitaire pour composer et lancer des appels téléphoniques directs.
class PhoneCallUtils {
  PhoneCallUtils._();

  /// Nettoie le numéro de téléphone pour le format standard tel:
  static String cleanPhoneNumber(String rawPhone) {
    // Conserver uniquement les chiffres et le '+' initial
    final trimmed = rawPhone.trim();
    final hasPlus = trimmed.startsWith('+');
    final digitsOnly = trimmed.replaceAll(RegExp(r'[^\d]'), '');
    return hasPlus ? '+$digitsOnly' : digitsOnly;
  }

  /// Ouvre le composeur téléphonique avec le numéro prérempli.
  /// L'utilisateur n'a plus qu'à confirmer ou appuyer sur le bouton vert d'appel.
  static Future<bool> makePhoneCall(String rawPhoneNumber) async {
    final cleaned = cleanPhoneNumber(rawPhoneNumber);
    if (cleaned.isEmpty) return false;

    final uri = Uri(scheme: 'tel', path: cleaned);
    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri);
      }
    } catch (e) {
      debugPrint('[PhoneCallUtils] Impossible d\'ouvrir le composeur d\'appel: $e');
    }
    return false;
  }
}

