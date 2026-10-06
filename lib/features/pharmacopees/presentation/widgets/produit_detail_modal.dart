import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/image_utils.dart';
import '../../../../shared/widgets/feedback/app_loading_indicator.dart';
import '../../../auth/providers/auth_state_provider.dart';
import '../../../panier/providers/panier_provider.dart';
import '../../../plantes/providers/plante_provider.dart';
import '../../models/pharmacopee_produit_item_model.dart';
import 'connexion_requise_dialog.dart';

/// Modal / BottomSheet moderne de consultation détaillée d'un remède traditionnel.
/// Respecte scrupuleusement la séparation : Plante != Produit.
/// Affiche :
/// - Photo et informations générales
/// - Forme galénique & Composition textuelle
/// - Plantes associées dans la formulation (avec quantités)
/// - Maladies et troubles ciblés
/// - Sélecteur de quantité & Bouton d'ajout au panier direct
class ProduitDetailModal extends ConsumerStatefulWidget {
  final PharmacopeeProduitItemModel produitItem;

  const ProduitDetailModal({
    super.key,
    required this.produitItem,
  });

  static Future<void> show(
    BuildContext context, {
    required PharmacopeeProduitItemModel produit,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ProduitDetailModal(produitItem: produit),
    );
  }

  @override
  ConsumerState<ProduitDetailModal> createState() => _ProduitDetailModalState();
}

class _ProduitDetailModalState extends ConsumerState<ProduitDetailModal> {
  int _quantite = 1;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final detailAsync =
        ref.watch(produitDetailProvider(widget.produitItem.produitId));

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppDimensions.radiusModal),
            ),
          ),
          child: Column(
            children: [
              // Poignée de glissement
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              // Contenu défilable
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.space20,
                  ),
                  children: [
                    // Photo de couverture
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusCard),
                      child: SizedBox(
                        height: 180,
                        width: double.infinity,
                        child: _buildImage(isDark),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.space16),

                    // Nom et Catégorie
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.produitItem.nom,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                ),
                              ),
                              if (widget.produitItem.categorieNom != null) ...[
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    widget.produitItem.categorieNom!,
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        // Prix
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              widget.produitItem.prixFormate,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              widget.produitItem.stockLibelle,
                              style: TextStyle(
                                fontSize: 11,
                                color: widget.produitItem.disponible
                                    ? AppColors.success
                                    : AppColors.danger,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: AppDimensions.space16),
                    const Divider(height: 1),
                    const SizedBox(height: AppDimensions.space16),

                    // Forme galénique & conditionnement
                    if (widget.produitItem.forme != null &&
                        widget.produitItem.forme!.isNotEmpty) ...[
                      _buildSectionTitle('Forme & Présentation', isDark),
                      const SizedBox(height: 6),
                      Text(
                        widget.produitItem.forme!,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.space16),
                    ],

                    // Description
                    if (widget.produitItem.description != null &&
                        widget.produitItem.description!.isNotEmpty) ...[
                      _buildSectionTitle('Description du remède', isDark),
                      const SizedBox(height: 6),
                      Text(
                        widget.produitItem.description!,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.space16),
                    ],

                    // Données approfondies provenant du backend (Plantes et Maladies)
                    detailAsync.when(
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(AppDimensions.space16),
                          child: AppLoadingIndicator(),
                        ),
                      ),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (detail) {
                        if (detail == null) return const SizedBox.shrink();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 🌿 Plantes dans la formulation (Plante != Produit)
                            if (detail.compositions.isNotEmpty) ...[
                              _buildSectionTitle(
                                  'Plantes composant ce remède', isDark),
                              const SizedBox(height: 8),
                              ...detail.compositions.map((comp) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.white.withAlpha(8)
                                        : const Color(0xFFF6FBF7),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isDark
                                          ? AppColors.darkBorder
                                          : const Color(0xFFE2EFE5),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.eco_rounded,
                                          color: AppColors.primary, size: 18),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              comp.nomScientifique,
                                              style: TextStyle(
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.bold,
                                                color: isDark
                                                    ? Colors.white
                                                    : AppColors.textPrimary,
                                              ),
                                            ),
                                            if (comp.nomsVernaculaires
                                                .isNotEmpty)
                                              Text(
                                                'Nom local : ${comp.nomsVernaculaires.join(", ")}',
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: AppColors.textMuted,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      if (comp.quantite > 0)
                                        Text(
                                          '${comp.quantite} ${comp.unite}',
                                          style: const TextStyle(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              }),
                              const SizedBox(height: AppDimensions.space16),
                            ],

                            // 🎯 Maladies & Indications
                            if (detail.maladies.isNotEmpty) ...[
                              _buildSectionTitle(
                                  'Indications & Troubles ciblés', isDark),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: detail.maladies.map((m) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? AppColors.darkSurface
                                          : const Color(0xFFFFF3E0),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: const Color(0xFFFFB74D),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.healing_rounded,
                                          size: 14,
                                          color: Color(0xFFE65100),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          m.nom,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFFE65100),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: AppDimensions.space16),
                            ],
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Barre inférieure fixe : Sélecteur de quantité & Bouton d'ajout
              Container(
                padding: EdgeInsets.only(
                  left: AppDimensions.space16,
                  right: AppDimensions.space16,
                  top: AppDimensions.space12,
                  bottom: MediaQuery.paddingOf(context).bottom + 12,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  border: Border(
                    top: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.border,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // Sélecteur de quantité - / +
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color:
                              isDark ? AppColors.darkBorder : AppColors.border,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 18),
                            onPressed: _quantite > 1
                                ? () => setState(() => _quantite--)
                                : null,
                          ),
                          Text(
                            '$_quantite',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, size: 18),
                            onPressed: widget.produitItem.disponible
                                ? () => setState(() => _quantite++)
                                : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppDimensions.space12),

                    // Bouton Ajouter au panier
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: widget.produitItem.disponible
                            ? () {
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

                                final notifier =
                                    ref.read(panierProvider.notifier);
                                for (int i = 0; i < _quantite; i++) {
                                  notifier.ajouterProduit(
                                    widget.produitItem.toProduitModel(),
                                  );
                                }
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '$_quantite x ${widget.produitItem.nom} ajouté au panier',
                                    ),
                                    backgroundColor: AppColors.primary,
                                    behavior: SnackBarBehavior.floating,
                                    action: SnackBarAction(
                                      label: 'Voir panier',
                                      textColor: Colors.white,
                                      onPressed: () {
                                        // Aller au panier
                                      },
                                    ),
                                  ),
                                );
                              }
                            : null,
                        icon: const Icon(Icons.add_shopping_cart_rounded),
                        label: Text(
                          widget.produitItem.disponible
                              ? 'Ajouter au panier'
                              : 'Épuisé',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white70 : AppColors.textPrimary,
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _buildImage(bool isDark) {
    final resolved = ImageUtils.resolveImageUrl(widget.produitItem.photoUrl);
    if (resolved != null) {
      return Image.network(
        resolved,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildFallback(isDark),
      );
    }
    return _buildFallback(isDark);
  }

  Widget _buildFallback(bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF1B2F23) : const Color(0xFFE8F5E9),
      child: Center(
        child: Icon(
          Icons.medication_rounded,
          size: 60,
          color: isDark ? const Color(0xFF2ECC71) : AppColors.primary,
        ),
      ),
    );
  }
}
