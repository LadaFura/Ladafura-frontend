/// Validateurs de formulaires pour LADAFURA.
///
/// Adaptés aux règles métier du backend Spring Boot et aux formats maliens.
class AppValidators {
  AppValidators._();

  /// Regex RFC 5322 simplifiée pour la validation d'adresses email.
  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$',
  );

  /// Regex pour les numéros de téléphone au Mali (8 chiffres, préfixe optionnel +223 ou 00223).
  /// Les préfixes d'opérateurs au Mali commencent généralement par 5, 6, 7, 8 ou 9 (Orange, Moov/Malitel, Telecel).
  static final RegExp _phoneMaliRegExp = RegExp(
    r'^(?:\+223|00223)?\s*([5-9]\d{7})$',
  );

  /// Valide qu'un champ obligatoire est renseigné.
  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null
          ? '$fieldName est obligatoire'
          : 'Ce champ est obligatoire';
    }
    return null;
  }

  /// Valide une adresse email.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "L'adresse email est obligatoire";
    }
    final cleanEmail = value.trim();
    if (!_emailRegExp.hasMatch(cleanEmail)) {
      return "Format d'adresse email invalide";
    }
    return null;
  }

  /// Valide un mot de passe sécurisé (minimum [minLength] caractères, défaut 6 selon backend).
  static String? password(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'Le mot de passe est obligatoire';
    }
    if (value.length < minLength) {
      return 'Le mot de passe doit comporter au moins $minLength caractères';
    }
    return null;
  }

  /// Valide la confirmation d'un mot de passe.
  static String? confirmPassword(String? value, String? originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Veuillez confirmer votre mot de passe';
    }
    if (value != originalPassword) {
      return 'Les mots de passe ne correspondent pas';
    }
    return null;
  }

  /// Valide un numéro de téléphone malien (Orange, Malitel/Moov, Telecel).
  ///
  /// Le numéro peut être saisi sous les formes :
  /// - `70 12 34 56` (8 chiffres)
  /// - `+223 70 12 34 56`
  /// - `00223 70 12 34 56`
  static String? phoneMali(String? value, {bool isRequired = false}) {
    if (value == null || value.trim().isEmpty) {
      return isRequired ? 'Le numéro de téléphone est obligatoire' : null;
    }
    final cleaned = value.replaceAll(RegExp(r'\s+|-'), '');
    if (!_phoneMaliRegExp.hasMatch(cleaned)) {
      return 'Numéro malien invalide (ex: +223 70 12 34 56 ou 70 12 34 56)';
    }
    return null;
  }

  /// Valide un montant ou un nombre positif.
  static String? positiveNumber(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null
          ? '$fieldName est obligatoire'
          : 'Veuillez saisir un nombre';
    }
    final parsed = num.tryParse(value.replaceAll(' ', ''));
    if (parsed == null || parsed <= 0) {
      return 'Veuillez entrer une valeur positive valide';
    }
    return null;
  }
}
