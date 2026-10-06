import 'package:flutter/material.dart';

/// Dimensions, rayons de courbure, paddings et espacements officiels LADAFURA.
///
/// Conçu pour un rendu optimal sur écran mobile de référence (402 × 874 px),
/// avec support des tablettes et du responsive Web (breakpoints et contraintes de largeur max).
/// Aligné sur une grille stricte de multiples de 4 px et conforme aux critères d'ergonomie tactile (WCAG).
class AppDimensions {
  AppDimensions._();

  // ===========================================================================
  // 1. ÉCRANS & BREAKPOINTS RESPONSIVE (MOBILE & WEB)
  // ===========================================================================

  /// Largeur de l'écran mobile de référence (402 px)
  static const double referenceWidth = 402.0;

  /// Hauteur de l'écran mobile de référence (874 px)
  static const double referenceHeight = 874.0;

  /// Largeur minimale supportée pour petits smartphones (360 px)
  static const double minMobileWidth = 360.0;

  /// Seuil de transition Mobile -> Tablette (768 px)
  static const double tabletBreakpoint = 768.0;

  /// Seuil de transition Tablette -> Desktop / Web (1024 px)
  static const double desktopBreakpoint = 1024.0;

  /// Largeur maximale du conteneur de contenu sur le Web (1200 px)
  /// Empêche l'étirement excessif des formulaires et fiches plantes sur grand écran
  static const double maxContentWidthWeb = 1200.0;

  /// Largeur maximale de lecture / formulaire centré (640 px)
  static const double maxFormWidth = 640.0;

  // ===========================================================================
  // 2. GRILLE D'ESPACEMENTS UNIVERSELLE (MULTIPLE DE 4 PX)
  // ===========================================================================

  /// Micro espacement (2 px)
  static const double space2 = 2.0;

  /// 4 px (XXS)
  static const double space4 = 4.0;

  /// 8 px (XS) - Espacement standard entre icône et texte
  static const double space8 = 8.0;

  /// 12 px (SM) - Espacement interne compact
  static const double space12 = 12.0;

  /// 16 px (MD) - Marge standard écran mobile et espacement courant
  static const double space16 = 16.0;

  /// 20 px (LG) - Espacement entre sections de cartes
  static const double space20 = 20.0;

  /// 24 px (XL) - Marge entre blocs majeurs de la page
  static const double space24 = 24.0;

  /// 32 px (2XL) - Séparation de grandes sections
  static const double space32 = 32.0;

  /// 40 px (3XL) - Espacement majeur
  static const double space40 = 40.0;

  /// 48 px (4XL) - Espacement aéré
  static const double space48 = 48.0;

  /// 64 px (5XL) - Espacement haut d'écran / landing
  static const double space64 = 64.0;

  /// 80 px - Dégagement important
  static const double space80 = 80.0;

  /// 96 px - Dégagement inférieur pour la barre de navigation flottante
  static const double space96 = 96.0;

  // ===========================================================================
  // 3. PADDINGS STANDARDS (EDGEINSETS & DOUBLES)
  // ===========================================================================

  // --- Paddings Écrans (Screen Padding) ---
  /// Marge horizontale standard pour mobile (16 px)
  static const double screenPaddingMobileH = 16.0;

  /// Marge verticale standard pour mobile (16 px)
  static const double screenPaddingMobileV = 16.0;

  /// Marge horizontale pour tablettes (24 px)
  static const double screenPaddingTabletH = 24.0;

  /// Marge horizontale pour écrans Web / Desktop (32 px)
  static const double screenPaddingWebH = 32.0;

  /// Padding complet écran mobile : `EdgeInsets.all(16.0)`
  static const EdgeInsets paddingScreenMobile = EdgeInsets.all(space16);

  /// Padding écran mobile avec dégagement inférieur pour la barre flottante
  static const EdgeInsets paddingScreenWithNavBar = EdgeInsets.fromLTRB(
    space16,
    space16,
    space16,
    space96,
  );

  /// Padding écran pour Web / Desktop : `EdgeInsets.symmetric(horizontal: 32, vertical: 24)`
  static const EdgeInsets paddingScreenWeb = EdgeInsets.symmetric(
    horizontal: screenPaddingWebH,
    vertical: space24,
  );

  // --- Paddings Conteneurs & Composants ---
  /// Padding interne standard d'une carte (16 px)
  static const EdgeInsets paddingCard = EdgeInsets.all(space16);

  /// Padding interne compact d'une carte (12 px)
  static const EdgeInsets paddingCardCompact = EdgeInsets.all(space12);

  /// Padding interne d'un champ de saisie (H: 16 px, V: 12 px)
  static const EdgeInsets paddingInput = EdgeInsets.symmetric(
    horizontal: space16,
    vertical: space12,
  );

  /// Padding d'un bouton standard (H: 16 px, V: 12 px)
  static const EdgeInsets paddingButton = EdgeInsets.symmetric(
    horizontal: space16,
    vertical: space12,
  );

  /// Padding d'un badge de statut ENF11 (H: 12 px, V: 6 px)
  static const EdgeInsets paddingBadge = EdgeInsets.symmetric(
    horizontal: space12,
    vertical: space4 + space2,
  );

  /// Padding d'une modale ou boîte de dialogue (24 px)
  static const EdgeInsets paddingModal = EdgeInsets.all(space24);

  // ===========================================================================
  // 4. RAYONS DE COURBURE (BORDER RADIUS)
  // ===========================================================================

  /// 4 px : Petits éléments, indicateurs ou sous-cartes
  static const double radiusSmall = 4.0;

  /// 8 px : Champs de saisie (inputs) et boutons standards
  static const double radiusInput = 8.0;
  static const double radiusButton = 8.0;

  /// 12 px : Cartes de plantes, produits et pharmacopées (cards)
  static const double radiusCard = 12.0;

  /// 16 px : Modales, popups et conteneurs surélevés
  static const double radiusModal = 16.0;

  /// 20 px : Draps inférieurs (BottomSheets)
  static const double radiusBottomSheet = 20.0;

  /// 999 px : Badges d'état (pills/chips) et boutons capsules
  static const double radiusBadge = 999.0;
  static const double radiusCapsule = 999.0;

  // ===========================================================================
  // 5. BOUTONS & CONTRÔLES INTERACTIFS (BUTTONS)
  // ===========================================================================

  /// Hauteur standard des boutons : 48 px (ergonomie tactile optimale)
  static const double buttonHeight = 48.0;

  /// Hauteur d'un bouton compact : 36 px (actions secondaires dans cartes)
  static const double buttonHeightSmall = 36.0;

  /// Hauteur d'un grand bouton principal : 56 px (boutons de paiement / validation finale)
  static const double buttonHeightLarge = 56.0;

  /// Largeur minimale d'un bouton d'action : 120 px
  static const double buttonMinWidth = 120.0;

  /// Taille minimale d'une zone tactile pour icône cliquable (48 × 48 px - WCAG)
  static const double touchTargetMin = 48.0;

  /// Diamètre d'un bouton circulaire d'icône : 44 px
  static const double iconButtonSize = 44.0;

  // ===========================================================================
  // 6. PANIER & COMMERCE (CART DIMENSIONS)
  // ===========================================================================

  /// Taille de l'image miniature d'un remède / produit dans le panier : 72 px
  static const double cartItemImageSize = 72.0;

  /// Hauteur d'une carte d'article dans le panier : 96 px
  static const double cartItemHeight = 96.0;

  /// Taille des boutons de réglage de quantité (+ / -) : 32 px
  static const double cartQuantityButtonSize = 32.0;

  /// Diamètre du badge indicateur sur l'icône du panier : 18 px
  static const double cartBadgeSize = 18.0;

  /// Hauteur du panneau récapitulatif du panier (Sous-total, livraison, total) : 140 px
  static const double cartSummaryHeight = 140.0;

  /// Hauteur de la barre d'action d'achat flottante au bas de l'écran : 80 px
  static const double cartCheckoutBarHeight = 80.0;

  // ===========================================================================
  // 7. CARTES & CONTENEURS (CARDS)
  // ===========================================================================

  /// Épaisseur standard des bordures de cartes : 1.0 px
  static const double cardBorderWidth = 1.0;

  /// Hauteur de l'image de présentation dans une fiche / carte produit : 160 px
  static const double cardImageHeight = 160.0;

  /// Hauteur totale d'une carte plante dans la grille du catalogue : 240 px
  static const double cardPlantGridHeight = 240.0;

  /// Largeur d'une carte produit dans un carrousel horizontal : 160 px
  static const double cardMarketplaceWidth = 160.0;

  // ===========================================================================
  // 8. CHAMPS DE SAISIE DE FORMULAIRE (INPUTS)
  // ===========================================================================

  /// Hauteur standard des champs de formulaire : 48 px
  static const double inputHeight = 48.0;

  /// Épaisseur de la bordure inactive : 1.0 px
  static const double inputBorderWidth = 1.0;

  /// Épaisseur de la bordure en état de focus : 1.5 px
  static const double inputFocusBorderWidth = 1.5;

  /// Taille des icônes de préfixe et suffixe dans les champs : 20 px
  static const double inputIconSize = 20.0;

  // ===========================================================================
  // 9. BARRE DE NAVIGATION & DOCK FLOTTANT (NAVBAR)
  // ===========================================================================

  /// Hauteur du dock de navigation flottant : 68 px
  static const double navBarHeight = 68.0;

  /// Diamètre des 4 boutons circulaires de la barre flottante : 48 px
  static const double navBarCircleSize = 48.0;

  /// Hauteur du bouton capsule central « Recherche » : 48 px
  static const double navBarCapsuleHeight = 48.0;

  /// Largeur minimale du bouton capsule central : 124 px
  static const double navBarCapsuleMinWidth = 124.0;

  /// Taille des icônes de navigation : 22 px
  static const double navBarIconSize = 22.0;

  /// Dégagement de sécurité pour le défilement du contenu au-dessus du dock : 96 px
  static const double navBarBottomClearance = 96.0;

  // ===========================================================================
  // 10. ICÔNES, AVATARS & INDICATEURS
  // ===========================================================================

  /// Petite icône (16 px)
  static const double iconSizeSmall = 16.0;

  /// Icône standard (20 px)
  static const double iconSizeMedium = 20.0;

  /// Grande icône (24 px)
  static const double iconSizeLarge = 24.0;

  /// Icône très grande pour en-têtes et illustrations (32 px)
  static const double iconSizeXLarge = 32.0;

  /// Diamètre du point indicateur dans les badges de statuts certifiés (ENF11) : 8 px
  static const double badgeDotSize = 8.0;

  /// Avatar utilisateur compact : 32 px
  static const double avatarSmall = 32.0;

  /// Avatar utilisateur moyen : 48 px
  static const double avatarMedium = 48.0;

  /// Avatar utilisateur grand (profil, tradipraticien certifié) : 64 px
  static const double avatarLarge = 64.0;
}
