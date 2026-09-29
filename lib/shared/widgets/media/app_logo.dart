import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constants/app_assets.dart';

/// Type de logo LADAFURA à afficher
enum LogoVariant {
  /// Logo icône carré (emblème pilon/feuille)
  icon,

  /// Logo horizontal complet (icône + typographie LADAFURA)
  horizontal,
}

/// Composant d'affichage vectoriel (SVG) du logo officiel de LADAFURA.
///
/// Utilise [SvgPicture] pour un rendu haute définition sans perte de qualité
/// sur tous les ratios d'écran mobile.
///
/// Détecte automatiquement le thème actif (Clair / Sombre) pour afficher
/// les variantes adaptées (ex: typographie blanche en Dark Mode), avec possibilité
/// de forcer explicitement via le paramètre [isDark].
class AppLogo extends StatelessWidget {
  final LogoVariant variant;
  final double? width;
  final double? height;
  final BoxFit fit;
  final ColorFilter? colorFilter;
  final AlignmentGeometry alignment;

  /// Forcer l'affichage du logo en mode sombre ou clair.
  /// Si null (par défaut), s'adapte automatiquement au thème courant de l'application.
  final bool? isDark;

  const AppLogo({
    super.key,
    this.variant = LogoVariant.horizontal,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.colorFilter,
    this.alignment = Alignment.center,
    this.isDark,
  });

  /// Constructeur pour l'icône carrée de LADAFURA (512x512)
  const AppLogo.icon({
    super.key,
    double? size = 48.0,
    this.fit = BoxFit.contain,
    this.colorFilter,
    this.alignment = Alignment.center,
    this.isDark,
  })  : variant = LogoVariant.icon,
        width = size,
        height = size;

  /// Constructeur pour le logo horizontal complet de LADAFURA (284x84)
  const AppLogo.horizontal({
    super.key,
    this.width,
    this.height = 36.0,
    this.fit = BoxFit.contain,
    this.colorFilter,
    this.alignment = Alignment.center,
    this.isDark,
  }) : variant = LogoVariant.horizontal;

  @override
  Widget build(BuildContext context) {
    final effectiveIsDark =
        isDark ?? (Theme.of(context).brightness == Brightness.dark);

    final String assetPath;
    if (variant == LogoVariant.icon) {
      assetPath =
          effectiveIsDark ? AppAssets.logoIconDarkSvg : AppAssets.logoIconSvg;
    } else {
      assetPath = effectiveIsDark
          ? AppAssets.logoHorizontalDarkSvg
          : AppAssets.logoHorizontalSvg;
    }

    return Semantics(
      label: 'Logo officiel LADAFURA',
      image: true,
      child: SvgPicture.asset(
        assetPath,
        width: width,
        height: height,
        fit: fit,
        colorFilter: colorFilter,
        alignment: alignment,
      ),
    );
  }
}
