/// Chemins vers les assets graphiques et icônes du projet LADAFURA.
/// Privilégier les formats vectoriels SVG pour les logos et icônes afin de
/// garantir un rendu net et optimal sur toutes les résolutions mobiles.
class AppAssets {
  AppAssets._();

  // ==========================================
  // LOGOS SVG - THÈME CLAIR (LIGHT MODE)
  // ==========================================
  /// Logo icône carré SVG - Thème Clair (fond vert, motif blanc & or)
  static const String logoIconSvg = 'assets/images/ladafura-logo-icon.svg';
  static const String logoEmbleme = logoIconSvg;

  /// Logo horizontal complet SVG - Thème Clair (texte vert foncé #065223)
  static const String logoHorizontalSvg =
      'assets/images/ladafura-logo-horizontal.svg';
  static const String logoComplet = logoHorizontalSvg;

  // ==========================================
  // LOGOS SVG - THÈME SOMBRE (DARK MODE)
  // ==========================================
  /// Logo icône carré SVG - Thème Sombre
  static const String logoIconDarkSvg =
      'assets/images/ladafura-logo-icon-darkmode.svg';

  /// Logo horizontal complet SVG - Thème Sombre (texte blanc contrasté)
  static const String logoHorizontalDarkSvg =
      'assets/images/ladafura-logo-horizontal-darkmode.svg';

  // ==========================================
  // LOGOS PNG (Fallback / Écrans matriciels)
  // ==========================================
  /// Logo icône carré PNG - Thème Clair
  static const String logoIconPng = 'assets/images/ladafura-logo-icon.png';

  /// Logo horizontal complet PNG - Thème Clair
  static const String logoHorizontalPng =
      'assets/images/ladafura-logo-horizontal.png';

  /// Logo icône carré PNG - Thème Sombre
  static const String logoIconDarkPng =
      'assets/images/ladafura-logo-icon-darkmode.png';

  /// Logo horizontal complet PNG - Thème Sombre
  static const String logoHorizontalDarkPng =
      'assets/images/ladafura-logo-horizontal-darkmode.png';

  // ==========================================
  // ILLUSTRATIONS & PLACEHOLDERS
  // ==========================================
  /// Image par défaut pour une fiche plante médicinale
  static const String plantPlaceholder = 'assets/images/plant_placeholder.png';

  /// Image par défaut pour un produit de pharmacopée
  static const String productPlaceholder =
      'assets/images/product_placeholder.png';
}
