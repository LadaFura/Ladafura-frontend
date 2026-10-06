import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../panier/providers/panier_provider.dart';
import '../../providers/pharmacopee_detail_controller.dart';
import '../../providers/pharmacopee_provider.dart';
import '../widgets/pharmacopee_avis_section.dart';
import '../widgets/pharmacopee_detail_header.dart';
import '../widgets/pharmacopee_detail_skeleton.dart';
import '../widgets/pharmacopee_modes_retrait_selector.dart';
import '../widgets/pharmacopee_produit_card.dart';
import '../widgets/pharmacopee_search_bar.dart';
import '../widgets/produit_detail_modal.dart';

/// Page d'affichage et de consultation moderne de la fiche « Détail d'une pharmacopée »
/// Organisée en vitrine numérique professionnelle :
/// 1. Couverture et En-tête immersif avec badges & contact
/// 2. Localisation réelle & Distance GPS avec "Voir sur la carte"
/// 3. Modes de retrait (Livraison / Retrait sur place conformes aux règles métier)
/// 4. Recherche contextuelle dans la pharmacopée & Chips de catégories
/// 5. Grille moderne de produits avec ajout instantané au panier
/// 6. Avis clients et retours de la pharmacopée
class PharmacopeeDetailPage extends ConsumerWidget {
  final int pharmacopeeId;

  const PharmacopeeDetailPage({
    super.key,
    required this.pharmacopeeId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Données de la pharmacopée
    final pharmaAsync = ref.watch(pharmacopeeFullDetailProvider(pharmacopeeId));
    final controllerState =
        ref.watch(pharmacopeeDetailControllerProvider(pharmacopeeId));
    final controller =
        ref.read(pharmacopeeDetailControllerProvider(pharmacopeeId).notifier);

    // Produits filtrés et catégories
    final filteredProduits =
        ref.watch(pharmacopeeFilteredProduitsProvider(pharmacopeeId));
    final categories = ref.watch(pharmacopeeCategoriesProvider(pharmacopeeId));
    final avisAsync = ref.watch(pharmacopeeAvisProvider(pharmacopeeId));

    // Panier pour le badge flottant ou en haut
    final panierItems = ref.watch(panierProvider);
    final nombreArticlesPanier =
        panierItems.fold(0, (sum, item) => sum + item.quantite);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.surface,
      body: pharmaAsync.when(
        loading: () => const PharmacopeeDetailSkeleton(),
        error: (err, stack) => Scaffold(
          appBar: AppBar(
            title: const Text('Fiche Pharmacopée'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  Navigator.of(context).maybePop();
                }
              },
            ),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.space24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded,
                      color: AppColors.danger, size: 48),
                  const SizedBox(height: AppDimensions.space12),
                  Text(
                    'Impossible de charger la fiche de cette pharmacopée',
                    style: isDark ? AppTextStyles.h3Dark : AppTextStyles.h3,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimensions.space16),
                  ElevatedButton.icon(
                    onPressed: () => ref
                        .refresh(pharmacopeeFullDetailProvider(pharmacopeeId)),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
          ),
        ),
        data: (pharma) {
          if (pharma == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Pharmacopée')),
              body: const Center(
                child: Text('Cette pharmacopée est introuvable.'),
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              // 1 & 2. En-tête moderne (Couverture, infos principales de la pharmacopée)
              SliverToBoxAdapter(
                child: PharmacopeeDetailHeader(pharmacopee: pharma),
              ),

              // 3. Barre de recherche de produits fixée au défilement (Sticky pinned header)
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickySearchBarDelegate(
                  builder: (context, isPinned) => PharmacopeeSearchBar(
                    pharmacopeeNom: pharma.nom,
                    onSearchChanged: controller.setSearchQuery,
                    categories: categories,
                    selectedCategory: controllerState.selectedCategory,
                    onCategorySelected: controller.selectCategory,
                    isPinned: isPinned,
                  ),
                  baseHeight: categories.isNotEmpty ? 116.0 : 66.0,
                  topSafeArea: MediaQuery.paddingOf(context).top,
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: AppDimensions.space8),
              ),

              // 4. Choix du mode de retrait (Livraison vs Retrait sur place)
              if (pharma.modesRetrait.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: PharmacopeeModesRetraitSelector(
                    modes: pharma.modesRetrait,
                    selectedMode: controllerState.selectedModeRetrait,
                    onModeChanged: controller.selectModeRetrait,
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppDimensions.space16),
                ),
              ],

              // Titre de section "Remèdes & Produits disponibles"
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.space16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.medication_rounded,
                              color: AppColors.primary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Remèdes disponibles (${filteredProduits.length})',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color:
                                  isDark ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      if (controllerState.searchQuery.isNotEmpty ||
                          controllerState.selectedCategory != null)
                        TextButton(
                          onPressed: () {
                            controller.reset();
                          },
                          child: const Text('Réinitialiser'),
                        ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: AppDimensions.space12),
              ),

              // 5. Grille moderne de produits ou état vide contextualisé
              if (filteredProduits.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.space24),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 54,
                            color:
                                isDark ? Colors.white30 : Colors.grey.shade400,
                          ),
                          const SizedBox(height: AppDimensions.space12),
                          Text(
                            controllerState.searchQuery.isNotEmpty
                                ? 'Aucun remède ne correspond à "${controllerState.searchQuery}" dans cette pharmacopée.'
                                : 'Aucun remède disponible actuellement dans cette pharmacopée.',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.space16,
                  ),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.78,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final produit = filteredProduits[index];
                        return PharmacopeeProduitCard(
                          produit: produit,
                          onTap: () {
                            ProduitDetailModal.show(
                              context,
                              produit: produit,
                            );
                          },
                          onAddToCart: () {
                            ref
                                .read(panierProvider.notifier)
                                .ajouterProduit(produit.toProduitModel());
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${produit.nom} ajouté au panier !',
                                ),
                                backgroundColor: AppColors.primary,
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 2),
                                action: SnackBarAction(
                                  label: 'Voir panier',
                                  textColor: Colors.white,
                                  onPressed: () {
                                    // Naviguer vers le panier
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      },
                      childCount: filteredProduits.length,
                    ),
                  ),
                ),

              const SliverToBoxAdapter(
                child: SizedBox(height: AppDimensions.space24),
              ),

              // 6. Section Avis clients vérifiés
              SliverToBoxAdapter(
                child: avisAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (avis) => PharmacopeeAvisSection(avis: avis),
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 80),
              ),
            ],
          );
        },
      ),

      // Bouton flottant du panier si des articles ont été ajoutés
      floatingActionButton: nombreArticlesPanier > 0
          ? FloatingActionButton.extended(
              onPressed: () {
                // Navigation vers le panier
              },
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: Badge(
                label: Text('$nombreArticlesPanier'),
                child: const Icon(Icons.shopping_bag_outlined),
              ),
              label: const Text(
                'Mon Panier',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          : null,
    );
  }
}

/// Délégué pour épingler la barre de recherche en haut au défilement (sticky header)
/// avec animation fluide lors de la transition et dégagement supérieur sous la barre d'état.
class _StickySearchBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget Function(BuildContext context, bool isPinned) builder;
  final double baseHeight;
  final double topSafeArea;

  const _StickySearchBarDelegate({
    required this.builder,
    required this.baseHeight,
    required this.topSafeArea,
  });

  // Hauteur fixe lorsque la barre est épinglée sous la barre de statut (avec marge de confort)
  double get pinnedHeight => baseHeight + topSafeArea;

  @override
  double get minExtent => pinnedHeight;

  @override
  double get maxExtent => pinnedHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    // La barre est considérée fixée / épinglée dès qu'il y a recouvrement ou défilement
    final isPinned = overlapsContent || shrinkOffset > 0;
    return SizedBox(
      height: pinnedHeight,
      child: builder(context, isPinned),
    );
  }

  @override
  bool shouldRebuild(covariant _StickySearchBarDelegate oldDelegate) {
    return oldDelegate.baseHeight != baseHeight ||
        oldDelegate.topSafeArea != topSafeArea;
  }
}



