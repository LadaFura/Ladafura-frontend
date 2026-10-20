import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/image_utils.dart';
import '../../../../shared/widgets/feedback/app_loading_indicator.dart';
import '../../../auth/providers/auth_state_provider.dart';
import '../../../commandes/providers/commande_provider.dart';
import '../../../panier/providers/panier_provider.dart';
import '../../../plantes/providers/plante_provider.dart';
import '../../models/pharmacopee_produit_item_model.dart';
import 'connexion_requise_dialog.dart';

/// Modal / BottomSheet moderne de consultation détaillée d'un remède traditionnel.
/// Respecte scrupuleusement la séparation : Plante != Produit.
/// Présentation ergonomique, moderne et attractive inspirée des fiches produits de référence.
class ProduitDetailModal extends ConsumerStatefulWidget {
  final PharmacopeeProduitItemModel produitItem;
  final int? pharmacopeeId;
  final String? nomPharmacopee;

  const ProduitDetailModal({
    super.key,
    required this.produitItem,
    this.pharmacopeeId,
    this.nomPharmacopee,
  });

  static Future<void> show(
    BuildContext context, {
    required PharmacopeeProduitItemModel produit,
    int? pharmacopeeId,
    String? nomPharmacopee,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (ctx) => ProduitDetailModal(
        produitItem: produit,
        pharmacopeeId: pharmacopeeId,
        nomPharmacopee: nomPharmacopee,
      ),
    );
  }

  @override
  ConsumerState<ProduitDetailModal> createState() => _ProduitDetailModalState();
}

class _ProduitDetailModalState extends ConsumerState<ProduitDetailModal> {
  int _quantite = 1;
  int? _selectedPharmacopeeId;
  String? _selectedPharmacopeeNom;

  @override
  void initState() {
    super.initState();
    _selectedPharmacopeeId = widget.pharmacopeeId;
    _selectedPharmacopeeNom = widget.nomPharmacopee;
  }

  String _formatNumber(num value) {
    final intValue = value.round();
    return intValue.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final detailAsync =
        ref.watch(produitDetailProvider(widget.produitItem.produitId));
    final double prixUnitaire = widget.produitItem.prix;
    final double totalPrix = prixUnitaire * _quantite;

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF131F17) : Colors.white,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: Column(
            children: [
              // 1. En-tête avec barre de glissement & bouton de fermeture rapide
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 12, 4),
                child: Row(
                  children: [
                    const SizedBox(width: 32),
                    Expanded(
                      child: Center(
                        child: Container(
                          width: 44,
                          height: 5,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white24 : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: isDark ? Colors.white60 : Colors.grey.shade600,
                        size: 22,
                      ),
                      onPressed: () => Navigator.pop(context),
                      tooltip: 'Fermer',
                    ),
                  ],
                ),
              ),

              // 2. Contenu défilable
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.space20,
                  ),
                  children: [
                    // --- Image Hero avec badges en surimpression ---
                    _buildHeroImage(isDark),
                    const SizedBox(height: 18),

                    // --- Titre & Pharmacopée préparatrice ---
                    Text(
                      widget.produitItem.nom,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),

                    if (widget.nomPharmacopee != null || _selectedPharmacopeeNom != null) ...[
                      Row(
                        children: [
                          const Icon(
                            Icons.verified_rounded,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Préparé par ${_selectedPharmacopeeNom ?? widget.nomPharmacopee}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white70 : AppColors.textSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],

                    // --- Badges caractéristiques (Forme, Catégorie, Origine) ---
                    _buildQuickTags(isDark),
                    const SizedBox(height: 16),

                    // --- Carte Prix & Disponibilité (Remplace l'ancienne ligne austère) ---
                    _buildPriceStockBanner(isDark),
                    const SizedBox(height: 20),

                    // --- Description du remède ---
                    if (widget.produitItem.description != null &&
                        widget.produitItem.description!.isNotEmpty) ...[
                      _buildDescriptionCard(widget.produitItem.description!, isDark),
                      const SizedBox(height: 20),
                    ],

                    // --- Posologie & Conseils d'utilisation ---
                    _buildPosologieEtConseilsCard(
                      posologieCustom: detailAsync.valueOrNull?.posologie ??
                          detailAsync.valueOrNull?.compositionTexte ??
                          widget.produitItem.posologie,
                      forme: widget.produitItem.forme ?? detailAsync.valueOrNull?.forme,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 20),

                    // --- Données détaillées (Plantes composantes & Maladies ciblées) ---
                    detailAsync.when(
                      loading: () => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: AppLoadingIndicator()),
                      ),
                      error: (_, __) => _buildFallbackPlantsAndMaladies(isDark),
                      data: (detail) {
                        if (detail == null) {
                          return _buildFallbackPlantsAndMaladies(isDark);
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 🌿 Formulation Botanique (Plantes utilisées)
                            if (detail.compositions.isNotEmpty) ...[
                              _buildSectionHeader(
                                icon: Icons.eco_rounded,
                                title: 'Formulation Botanique',
                                countBadge: '${detail.compositions.length} plantes',
                                isDark: isDark,
                              ),
                              const SizedBox(height: 10),
                              ...detail.compositions.map((comp) {
                                return _buildBotanicalCard(
                                  nomScientifique: comp.nomScientifique,
                                  nomsVernaculaires: comp.nomsVernaculaires,
                                  quantite: comp.quantite > 0
                                      ? '${comp.quantite} ${comp.unite}'
                                      : null,
                                  photoUrl: comp.photoUrl,
                                  isDark: isDark,
                                );
                              }),
                              const SizedBox(height: 20),
                            ] else if (widget.produitItem.plantes.isNotEmpty) ...[
                              _buildFallbackPlantsList(widget.produitItem.plantes, isDark),
                              const SizedBox(height: 20),
                            ],

                            // 🎯 Indications & Troubles ciblés
                            if (detail.maladies.isNotEmpty) ...[
                              _buildSectionHeader(
                                icon: Icons.health_and_safety_outlined,
                                title: 'Indications & Troubles ciblés',
                                isDark: isDark,
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: detail.maladies.map((m) {
                                  return _buildHealthChip(m.nom, isDark);
                                }).toList(),
                              ),
                              const SizedBox(height: 20),
                            ] else if (widget.produitItem.maladies.isNotEmpty) ...[
                              _buildFallbackMaladiesList(widget.produitItem.maladies, isDark),
                              const SizedBox(height: 20),
                            ],

                            // 🏥 Choix de l'officine préparatrice (si plusieurs offres)
                            if (widget.pharmacopeeId == null &&
                                detail.offresPharmacopees.isNotEmpty) ...[
                              _buildSectionHeader(
                                icon: Icons.storefront_rounded,
                                title: 'Sélectionnez la pharmacopée',
                                countBadge: '${detail.offresPharmacopees.length} pharmacopées',
                                isDark: isDark,
                              ),
                              const SizedBox(height: 10),
                              ...detail.offresPharmacopees.map((offre) {
                                final currentSelectedId = _selectedPharmacopeeId ??
                                    detail.offresPharmacopees.first.pharmacopeeId;
                                final isSelected =
                                    currentSelectedId == offre.pharmacopeeId;
                                return _buildPharmacopeeOfferCard(
                                  offre: offre,
                                  isSelected: isSelected,
                                  isDark: isDark,
                                );
                              }),
                              const SizedBox(height: 16),
                            ],
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // 3. Barre inférieure fixe : Sélecteur de quantité & Bouton d'ajout ergonomique
              _buildBottomActionBar(
                prixUnitaire: prixUnitaire,
                totalPrix: totalPrix,
                isDark: isDark,
                detailAsync: detailAsync,
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Composant : Image Hero avec badge de catégorie & disponibilité ---
  Widget _buildHeroImage(bool isDark) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildImageWidget(isDark),

            // Dégradé d'assombrissement subtil en bas pour lisibilité
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.1),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.35),
                    ],
                  ),
                ),
              ),
            ),

            // Badge Catégorie en haut à gauche
            if (widget.produitItem.categorieNom != null &&
                widget.produitItem.categorieNom!.isNotEmpty)
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.spa_rounded, color: Color(0xFF68D391), size: 13),
                      const SizedBox(width: 5),
                      Text(
                        widget.produitItem.categorieNom!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Badge Disponibilité en bas à droite
            Positioned(
              bottom: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: widget.produitItem.disponible
                      ? const Color(0xFF15803D).withValues(alpha: 0.9)
                      : const Color(0xFFDC2626).withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.produitItem.stockLibelle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget(bool isDark) {
    final resolved = ImageUtils.resolveImageUrl(widget.produitItem.photoUrl);
    if (resolved != null && resolved.isNotEmpty) {
      if (resolved.startsWith('assets/')) {
        return Image.asset(
          resolved,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildFallbackHero(isDark),
        );
      }
      return CachedNetworkImage(
        imageUrl: resolved,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          color: isDark ? const Color(0xFF1B2F23) : const Color(0xFFE8F5E9),
          child: const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
            ),
          ),
        ),
        errorWidget: (_, __, ___) => _buildFallbackHero(isDark),
      );
    }
    return _buildFallbackHero(isDark);
  }

  // Fond d'image riche et chaleureux lorsqu'aucune photo physique n'est présente
  Widget _buildFallbackHero(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF0F3B20), const Color(0xFF1D5A34)]
              : [const Color(0xFFE8F5E9), const Color(0xFFC8E6C9)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (isDark ? Colors.black26 : Colors.white.withValues(alpha: 0.8)),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.local_pharmacy_rounded,
                size: 42,
                color: isDark ? const Color(0xFF4ADE80) : AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Remède Traditionnel Authentifié',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white70 : AppColors.primaryDark,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Composant : Badges rapides (Forme galénique, 100% Naturel, etc.) ---
  Widget _buildQuickTags(bool isDark) {
    final List<Widget> tags = [];

    if (widget.produitItem.forme != null && widget.produitItem.forme!.isNotEmpty) {
      tags.add(_buildBadgeItem(
        icon: Icons.grain_rounded,
        label: widget.produitItem.forme!,
        color: AppColors.primary,
        bgColor: isDark ? const Color(0xFF183824) : const Color(0xFFEBF7EE),
        isDark: isDark,
      ));
    }

    tags.add(_buildBadgeItem(
      icon: Icons.verified_outlined,
      label: '100% Naturel',
      color: const Color(0xFF0284C7),
      bgColor: isDark ? const Color(0xFF102A3D) : const Color(0xFFE0F2FE),
      isDark: isDark,
    ));

    tags.add(_buildBadgeItem(
      icon: Icons.local_shipping_outlined,
      label: 'Retrait & Livraison',
      color: const Color(0xFFD97706),
      bgColor: isDark ? const Color(0xFF38260D) : const Color(0xFFFEF3C7),
      isDark: isDark,
    ));

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags,
    );
  }

  Widget _buildBadgeItem({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // --- Composant : Carte Prix & Disponibilité Moderne ---
  Widget _buildPriceStockBanner(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF18291F) : const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2E5A3E) : const Color(0xFFBBF7D0),
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PRIX UNITAIRE',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: isDark ? Colors.white60 : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.produitItem.prixFormate,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: widget.produitItem.disponible
                  ? (isDark ? const Color(0xFF14532D) : const Color(0xFFDCFCE7))
                  : (isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFEE2E2)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  widget.produitItem.disponible
                      ? Icons.check_circle_rounded
                      : Icons.error_outline_rounded,
                  size: 15,
                  color: widget.produitItem.disponible
                      ? const Color(0xFF16A34A)
                      : const Color(0xFFDC2626),
                ),
                const SizedBox(width: 6),
                Text(
                  widget.produitItem.stockLibelle,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: widget.produitItem.disponible
                        ? (isDark ? const Color(0xFF86EFAC) : const Color(0xFF15803D))
                        : (isDark ? const Color(0xFFFCA5A5) : const Color(0xFFB91C1C)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Composant : Description du remède soignée ---
  Widget _buildDescriptionCard(String description, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withAlpha(8) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.description_outlined,
                size: 17,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Description & Usage',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.55,
              color: isDark ? AppColors.darkTextSecondary : const Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }

  // --- Composant : Posologie & Conseils d'utilisation ---
  Widget _buildPosologieEtConseilsCard({
    String? posologieCustom,
    String? forme,
    required bool isDark,
  }) {
    final formeStr = (forme ?? '').toLowerCase();

    // Déduction intelligente de la posologie et des conseils selon la forme galénique
    final bool isExterne = formeStr.contains('pommade') ||
        formeStr.contains('baume') ||
        formeStr.contains('huile') ||
        formeStr.contains('onguent') ||
        formeStr.contains('crème') ||
        formeStr.contains('creme') ||
        formeStr.contains('savon') ||
        formeStr.contains('lotion');

    final bool isInfusion = formeStr.contains('infusion') ||
        formeStr.contains('tisane') ||
        formeStr.contains('thé') ||
        formeStr.contains('the');

    final bool isDecoction = formeStr.contains('décoction') ||
        formeStr.contains('decoction') ||
        formeStr.contains('écorce') ||
        formeStr.contains('racine');

    final bool isSirop = formeStr.contains('sirop') ||
        formeStr.contains('goutte') ||
        formeStr.contains('solution');

    final bool isGelule = formeStr.contains('gélule') ||
        formeStr.contains('gelule') ||
        formeStr.contains('comprimé') ||
        formeStr.contains('capsule');

    final bool isPoudre = formeStr.contains('poudre') ||
        formeStr.contains('sachet') ||
        formeStr.contains('paquet');

    final String posologieTexte;
    final String frequenceBadge;
    final String voieAdministration;
    final String dureeRecommandee;
    final List<String> conseilsPratiques;

    if (posologieCustom != null && posologieCustom.trim().isNotEmpty) {
      posologieTexte = posologieCustom.trim();
      frequenceBadge = isExterne ? '2 à 3 fois / jour' : 'Matin & Soir';
      voieAdministration = isExterne ? 'Usage cutané externe' : 'Voie orale';
      dureeRecommandee = '7 à 14 jours';
      conseilsPratiques = [
        'Prendre de préférence après les repas avec de l\'eau tiède.',
        'Conserver le remède à l\'abri de l\'humidité, de la chaleur et du soleil.',
        'Bien refermer le contenant hermétiquement après chaque utilisation.',
      ];
    } else if (isInfusion) {
      posologieTexte =
          'Faire infuser 1 dose (ou 1 sachet) dans 250 ml d\'eau frémissante pendant 7 à 10 minutes. Boire chaud ou tiède après filtration.';
      frequenceBadge = '2 à 3 tasses / jour';
      voieAdministration = 'Voie orale (Infusion)';
      dureeRecommandee = 'Cure de 10 à 14 jours';
      conseilsPratiques = [
        'Consommer de préférence tiède, le matin à jeun et le soir avant le coucher.',
        'Possibilité d\'édulcorer avec une cuillère de miel pur si nécessaire.',
        'Conserver le sachet de plantes dans un endroit sec et bien aéré.',
      ];
    } else if (isDecoction) {
      posologieTexte =
          'Faire bouillir une poignée de plantes dans 1 litre d\'eau pendant 10 à 15 minutes à feu doux. Laisser tiédir et filtrer soigneusement.';
      frequenceBadge = '1 verre matin et soir';
      voieAdministration = 'Voie orale (Décoction)';
      dureeRecommandee = 'Cure de 7 à 10 jours';
      conseilsPratiques = [
        'Boire 1 verre à moutarde (environ 150 ml) matin et soir après les repas.',
        'La décoction préparée se conserve au frais et doit être consommée sous 48 heures.',
        'Ne pas réchauffer plusieurs fois la même portion.',
      ];
    } else if (isSirop) {
      posologieTexte =
          'Adulte : 1 cuillère à soupe 2 à 3 fois par jour. Enfant (à partir de 6 ans) : 1 cuillère à café matin et soir.';
      frequenceBadge = '2 à 3 prises / jour';
      voieAdministration = 'Voie orale (Sirop)';
      dureeRecommandee = '5 à 7 jours';
      conseilsPratiques = [
        'Prendre de préférence à distance des repas avec un demi-verre d\'eau.',
        'Bien agiter le flacon avant chaque utilisation.',
        'Conserver au frais après ouverture et hors de portée des enfants.',
      ];
    } else if (isGelule) {
      posologieTexte =
          'Prendre 1 à 2 gélules matin et soir avec un grand verre d\'eau au milieu ou à la fin des repas.';
      frequenceBadge = '2 gélules / jour';
      voieAdministration = 'Voie orale (Gélules)';
      dureeRecommandee = 'Cure de 15 jours';
      conseilsPratiques = [
        'Avaler sans croquer avec un verre d\'eau tempérée.',
        'Respecter une hydratation suffisante tout au long de la journée.',
        'Conserver le pilulier hermétiquement fermé à l\'abri de la lumière.',
      ];
    } else if (isExterne) {
      posologieTexte =
          'Appliquer une fine couche sur la zone propre et sèche 2 à 3 fois par jour. Masser délicatement en mouvements circulaires jusqu\'à pénétration complète.';
      frequenceBadge = '2 à 3 fois / jour';
      voieAdministration = 'Usage cutané externe';
      dureeRecommandee = 'Jusqu\'à amélioration';
      conseilsPratiques = [
        'Nettoyer et sécher la peau avant toute application.',
        'Ne pas appliquer sur une plaie ouverte, les muqueuses ou les yeux.',
        'Se laver soigneusement les mains après l\'application.',
      ];
    } else if (isPoudre) {
      posologieTexte =
          'Diluer 1 cuillère à café rase de poudre (ou 1 sachet) dans un verre d\'eau tiède, du lait caillé ou une bouillie légère le matin et le soir.';
      frequenceBadge = 'Matin & Soir';
      voieAdministration = 'Voie orale (Poudre)';
      dureeRecommandee = 'Cure de 10 à 14 jours';
      conseilsPratiques = [
        'Bien mélanger pour obtenir une suspension homogène avant d\'avaler.',
        'Prendre de préférence 15 à 30 minutes après le repas.',
        'Protéger la poudre contre l\'humidité pour éviter les grumeaux.',
      ];
    } else {
      posologieTexte =
          'Prendre 1 dose matin et soir selon les recommandations de la pharmacopée agréée, de préférence après les repas avec un verre d\'eau.';
      frequenceBadge = 'Matin & Soir';
      voieAdministration = 'Voie orale';
      dureeRecommandee = 'Cure de 7 à 14 jours';
      conseilsPratiques = [
        'Respecter scrupuleusement le rythme des prises prescrit.',
        'Conserver au sec, à température ambiante et à l\'abri du soleil direct.',
        'Demander conseil au pharmacien ou tradithérapeute en cas de doute.',
      ];
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withAlpha(8) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête de la section
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.primary.withAlpha(35)
                      : AppColors.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.medication_liquid_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Posologie & Conseils d\'utilisation',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 1. Encadré Posologie principale
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF132A1C)
                  : const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF1B4D2E)
                    : const Color(0xFFBBF7D0),
                width: 1.1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          size: 15,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'POSOLOGIE RECOMMANDÉE',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            color: isDark ? const Color(0xFF86EFAC) : AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF14532D) : const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        frequenceBadge,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  posologieTexte,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 2. Grille des 2 repères clés (Voie & Durée)
          Row(
            children: [
              Expanded(
                child: _buildPosologieInfoTile(
                  icon: isExterne ? Icons.touch_app_outlined : Icons.water_drop_outlined,
                  label: 'Mode de prise',
                  value: voieAdministration,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildPosologieInfoTile(
                  icon: Icons.calendar_month_outlined,
                  label: 'Durée indicative',
                  value: dureeRecommandee,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 3. Conseils pratiques (Puces)
          Text(
            'Conseils de préparation & conservation',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white70 : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          ...conseilsPratiques.map((conseil) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Icon(
                      Icons.check_circle_outline_rounded,
                      size: 14,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      conseil,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: isDark ? AppColors.darkTextSecondary : const Color(0xFF475569),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 10),

          // 4. Précautions d'emploi (Boîte Ambre sémantique)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF382A15) : const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark
                    ? AppColors.darkWarning.withValues(alpha: 0.4)
                    : AppColors.warning.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 18,
                  color: isDark ? AppColors.darkWarning : const Color(0xFFD97706),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Ne pas dépasser la dose journalière indiquée. En cas d\'absence d\'amélioration après 3 jours ou en cas de grossesse, demandez l\'avis d\'un professionnel de santé ou de votre pharmacopée.',
                    style: TextStyle(
                      fontSize: 11.5,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                      color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPosologieInfoTile({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withAlpha(6) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white54 : AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Titre de section réutilisable avec icône et badge compteur ---
  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    String? countBadge,
    required bool isDark,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        if (countBadge != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E3A28) : const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              countBadge,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ],
    );
  }

  // --- Carte Botanique : Présentation valorisante des plantes de la formulation ---
  Widget _buildBotanicalCard({
    required String nomScientifique,
    required List<String> nomsVernaculaires,
    String? quantite,
    String? photoUrl,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withAlpha(10) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFE5E7EB),
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        children: [
          // Avatar botanique
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF163E27) : const Color(0xFFEDF7EE),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.eco_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),

          // Noms scientifique et vernaculaire
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nomScientifique,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  nomsVernaculaires.isNotEmpty
                      ? 'Nom local : ${nomsVernaculaires.join(", ")}'
                      : 'Plante médicinale sauvage',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark ? Colors.white60 : AppColors.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Dosage / Poids
          if (quantite != null && quantite.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF183B26) : const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                quantite,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // --- Badge Maladie & Indication ---
  Widget _buildHealthChip(String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF332013) : const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF7C3D12) : const Color(0xFFFDBA74),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.healing_rounded,
            size: 14,
            color: Color(0xFFEA580C),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFFC2410C),
            ),
          ),
        ],
      ),
    );
  }

  // --- Fallbacks pour Plantes et Maladies si le détail async est en erreur ---
  Widget _buildFallbackPlantsAndMaladies(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.produitItem.plantes.isNotEmpty) ...[
          _buildFallbackPlantsList(widget.produitItem.plantes, isDark),
          const SizedBox(height: 20),
        ],
        if (widget.produitItem.maladies.isNotEmpty) ...[
          _buildFallbackMaladiesList(widget.produitItem.maladies, isDark),
          const SizedBox(height: 20),
        ],
      ],
    );
  }

  Widget _buildFallbackPlantsList(List<String> plantes, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: Icons.eco_rounded,
          title: 'Plantes composant ce remède',
          countBadge: '${plantes.length}',
          isDark: isDark,
        ),
        const SizedBox(height: 10),
        ...plantes.map((plante) => _buildBotanicalCard(
              nomScientifique: plante,
              nomsVernaculaires: const [],
              isDark: isDark,
            )),
      ],
    );
  }

  Widget _buildFallbackMaladiesList(List<String> maladies, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: Icons.health_and_safety_outlined,
          title: 'Indications & Troubles ciblés',
          isDark: isDark,
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: maladies.map((m) => _buildHealthChip(m, isDark)).toList(),
        ),
      ],
    );
  }

  // --- Carte Pharmacopée proposant le produit ---
  Widget _buildPharmacopeeOfferCard({
    required dynamic offre,
    required bool isSelected,
    required bool isDark,
  }) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedPharmacopeeId = offre.pharmacopeeId;
          _selectedPharmacopeeNom = offre.nomPharmacopee;
        });
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF1B3D28) : const Color(0xFFF0FDF4))
              : (isDark ? Colors.white.withAlpha(6) : Colors.grey.shade50),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.darkBorder : Colors.grey.shade200),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppColors.primary : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    offre.nomPharmacopee,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${offre.commune ?? offre.region ?? "Pharmacopée agréée"} • ${_formatNumber(offre.prix)} FCFA',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: isDark ? Colors.white70 : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Barre d'action inférieure sticky ---
  Widget _buildBottomActionBar({
    required double prixUnitaire,
    required double totalPrix,
    required bool isDark,
    required AsyncValue<dynamic> detailAsync,
  }) {
    return Container(
      padding: EdgeInsets.only(
        left: AppDimensions.space20,
        right: AppDimensions.space20,
        top: 14,
        bottom: MediaQuery.paddingOf(context).bottom + 14,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131F17) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Sélecteur de quantité ergonomique avec stepper
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withAlpha(10) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : const Color(0xFFCBD5E1),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_rounded, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: _quantite > 1
                      ? () => setState(() => _quantite--)
                      : null,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    '$_quantite',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_rounded, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: widget.produitItem.disponible
                      ? () => setState(() => _quantite++)
                      : null,
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          // Bouton Ajouter au panier avec affichage dynamique du sous-total
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: widget.produitItem.disponible
                    ? () async {
                        final authState = ref.read(authStateProvider);
                        if (!authState.isAuthenticated) {
                          ConnexionRequiseDialog.show(
                            context,
                            title: 'Connexion requise',
                            description:
                                'Veuillez vous connecter pour ajouter ${widget.produitItem.nom} à votre panier.',
                          );
                          return;
                        }

                        final notifier = ref.read(panierStateProvider.notifier);

                        int? finalPharmaId =
                            _selectedPharmacopeeId ?? widget.pharmacopeeId;
                        String? finalPharmaNom =
                            _selectedPharmacopeeNom ?? widget.nomPharmacopee;

                        if (finalPharmaId == null) {
                          final detail = detailAsync.asData?.value;
                          if (detail != null &&
                              detail.offresPharmacopees.isNotEmpty) {
                            finalPharmaId =
                                detail.offresPharmacopees.first.pharmacopeeId;
                            finalPharmaNom =
                                detail.offresPharmacopees.first.nomPharmacopee;
                          }
                        }

                        await notifier.ajouterProduit(
                          widget.produitItem.produitId,
                          quantite: _quantite,
                          pharmacopeeId: finalPharmaId,
                          nomPharmacopee: finalPharmaNom,
                        );

                        if (finalPharmaId != null && finalPharmaNom != null) {
                          ref.read(checkoutProvider.notifier).initCheckout(
                                pharmacopeeId: finalPharmaId,
                                nomPharmacopee: finalPharmaNom,
                              );
                        }

                        if (!mounted) return; if (true) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.check_circle_rounded,
                                      color: Colors.white, size: 20),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      '${widget.produitItem.nom} ($_quantite) ajouté au panier',
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: AppColors.primary,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shopping_bag_outlined, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      widget.produitItem.disponible
                          ? 'Ajouter • ${_formatNumber(totalPrix)} FCFA'
                          : 'Épuisé',
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
