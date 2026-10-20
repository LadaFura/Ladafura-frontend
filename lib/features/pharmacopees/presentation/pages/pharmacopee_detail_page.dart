import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/routing/route_names.dart';
import '../../../auth/providers/auth_state_provider.dart';
import '../../../commandes/providers/commande_provider.dart';
import '../../../panier/providers/panier_provider.dart';
import '../../providers/pharmacopee_detail_controller.dart';
import '../../providers/pharmacopee_provider.dart';
import '../../../../core/services/services_providers.dart';
import '../widgets/connexion_requise_dialog.dart';
import '../widgets/donner_avis_modal.dart';
import '../widgets/pharmacopee_avis_section.dart';
import '../widgets/pharmacopee_detail_header.dart';
import '../widgets/pharmacopee_detail_skeleton.dart';
import '../widgets/pharmacopee_modes_retrait_selector.dart';
import '../widgets/pharmacopee_produit_card.dart';
import '../widgets/pharmacopee_quick_actions_bar.dart';
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
class PharmacopeeDetailPage extends ConsumerStatefulWidget {
  final int pharmacopeeId;
  final String? initialSearchQuery;
  final List<String> initialMatchedProduits;

  const PharmacopeeDetailPage({
    super.key,
    required this.pharmacopeeId,
    this.initialSearchQuery,
    this.initialMatchedProduits = const [],
  });

  @override
  ConsumerState<PharmacopeeDetailPage> createState() => _PharmacopeeDetailPageState();
}

class _PharmacopeeDetailPageState extends ConsumerState<PharmacopeeDetailPage> {
  // Onglet sélectionné : 0 = Remèdes, 1 = Avis & Évaluations
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.initialSearchQuery != null &&
        widget.initialSearchQuery!.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref
            .read(pharmacopeeDetailControllerProvider(widget.pharmacopeeId).notifier)
            .initFromSearch(
              query: widget.initialSearchQuery,
              matchedProduits: widget.initialMatchedProduits,
            );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pharmacopeeId = widget.pharmacopeeId;

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
    final eligibiliteAsync =
        ref.watch(pharmacopeeEligibiliteAvisProvider(pharmacopeeId));
    final userPositionAsync = ref.watch(userLocationProvider);
    final userCoords = userPositionAsync.valueOrNull;

    // Panier pour le badge flottant ou en haut
    final panierItems = ref.watch(panierProvider);
    final nombreArticlesPanier =
        panierItems.fold(0, (sum, item) => sum + item.quantite);

    void handleDonnerAvis(String nomPharma) {
      final authState = ref.read(authStateProvider);
      if (!authState.isAuthenticated) {
        ConnexionRequiseDialog.show(
          context,
          title: 'Connexion requise',
          description:
              'Vous devez être connecté à votre compte citoyen pour donner votre avis sur cette pharmacopée.',
        );
        return;
      }

      final eligibilite = eligibiliteAsync.valueOrNull;
      if (eligibilite != null && !eligibilite.eligible && !eligibilite.dejaEvalue) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              eligibilite.message ??
                  'Vous devez avoir passé au moins une commande livrée ou retirée auprès de cette pharmacopée pour déposer un avis.',
            ),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
        return;
      }

      DonnerAvisModal.show(
        context,
        pharmacopeeId: pharmacopeeId,
        nomPharmacopee: nomPharma,
        eligibilite: eligibilite,
        pharmacopeeService: ref.read(pharmacopeeServiceProvider),
        onAvisSubmitted: () {
          ref.invalidate(pharmacopeeAvisProvider(pharmacopeeId));
          ref.invalidate(pharmacopeeFullDetailProvider(pharmacopeeId));
          ref.invalidate(pharmacopeeEligibiliteAvisProvider(pharmacopeeId));
        },
      );
    }

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

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              ref.invalidate(pharmacopeeFullDetailProvider(pharmacopeeId));
              ref.invalidate(pharmacopeeAvisProvider(pharmacopeeId));
              ref.invalidate(pharmacopeeEligibiliteAvisProvider(pharmacopeeId));
              try {
                await Future.wait([
                  ref.read(pharmacopeeFullDetailProvider(pharmacopeeId).future),
                  ref.read(pharmacopeeAvisProvider(pharmacopeeId).future),
                ]);
              } catch (_) {}
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
              // 1 & 2. En-tête moderne (Couverture, infos principales de la pharmacopée)
              SliverToBoxAdapter(
                child: PharmacopeeDetailHeader(
                  pharmacopee: pharma,
                  onVoirAvis: () {
                    setState(() {
                      _selectedTabIndex = 1;
                    });
                  },
                ),
              ),

              // Masque de barre d'état actif dès que l'en-tête principal est défilé
              _StatusBarCoverSliver(
                topSafeArea: MediaQuery.paddingOf(context).top,
                color: isDark ? AppColors.darkBackground : AppColors.surface,
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 8),
              ),

              // Actions rapides : 📞 Appeler | 📍 Itinéraire | ⭐ Donner un avis
              SliverToBoxAdapter(
                child: PharmacopeeQuickActionsBar(
                  pharmacopee: pharma,
                  userCoordinates: userCoords,
                  onDonnerAvis: () => handleDonnerAvis(pharma.nom),
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 10),
              ),

              // Barre d'onglets ergonomique : [ Remèdes (N) | Avis & Évaluations (N) ]
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space16),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              if (_selectedTabIndex != 0) {
                                setState(() => _selectedTabIndex = 0);
                              }
                            },
                            borderRadius: BorderRadius.circular(9),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: _selectedTabIndex == 0
                                    ? AppColors.primary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(9),
                                boxShadow: _selectedTabIndex == 0
                                    ? [
                                        BoxShadow(
                                          color: AppColors.primary.withAlpha(50),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  'Remèdes (${pharma.nombreProduits})',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: _selectedTabIndex == 0
                                        ? FontWeight.bold
                                        : FontWeight.w600,
                                    color: _selectedTabIndex == 0
                                        ? Colors.white
                                        : (isDark
                                            ? AppColors.darkTextSecondary
                                            : AppColors.textSecondary),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              if (_selectedTabIndex != 1) {
                                setState(() => _selectedTabIndex = 1);
                              }
                            },
                            borderRadius: BorderRadius.circular(9),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: _selectedTabIndex == 1
                                    ? AppColors.primary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(9),
                                boxShadow: _selectedTabIndex == 1
                                    ? [
                                        BoxShadow(
                                          color: AppColors.primary.withAlpha(50),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  'Avis (${pharma.nombreAvis})',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: _selectedTabIndex == 1
                                        ? FontWeight.bold
                                        : FontWeight.w600,
                                    color: _selectedTabIndex == 1
                                        ? Colors.white
                                        : (isDark
                                            ? AppColors.darkTextSecondary
                                            : AppColors.textSecondary),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 8),
              ),

              if (_selectedTabIndex == 0) ...[
                // 3. Barre de recherche de produits, bouton retour et catégories fixés en haut au défilement
                SliverLayoutBuilder(
                  builder: (context, constraints) {
                    final topSafeArea = MediaQuery.paddingOf(context).top;
                    final yOnScreen = constraints.viewportMainAxisExtent -
                        constraints.remainingPaintExtent;
                    final isPinned =
                        constraints.scrollOffset > 0 || yOnScreen <= topSafeArea;
                    return _PinnedSearchBarSliver(
                      topSafeArea: topSafeArea,
                      child: PharmacopeeSearchBar(
                        pharmacopeeNom: pharma.nom,
                        searchQuery: controllerState.searchQuery,
                        onSearchChanged: controller.setSearchQuery,
                        categories: categories,
                        selectedCategory: controllerState.selectedCategory,
                        onCategorySelected: controller.selectCategory,
                        isPinned: isPinned,
                        onBack: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            Navigator.of(context).maybePop();
                          }
                        },
                      ),
                    );
                  },
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: 8),
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
                    child: SizedBox(height: 10),
                  ),
                ],

                // Titre de section "Remèdes disponibles"
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.space16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Remèdes disponibles (${filteredProduits.length})',
                          style: (isDark ? AppTextStyles.h3Dark : AppTextStyles.h3)
                              .copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
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
                  child: SizedBox(height: 8),
                ),

                // 5. Grille moderne de produits ou état vide
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
                              size: 48,
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
                        childAspectRatio: 0.72,
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
                                pharmacopeeId: pharma.id,
                                nomPharmacopee: pharma.nom,
                              );
                            },
                            onAddToCart: () {
                              final authState = ref.read(authStateProvider);
                              if (!authState.isAuthenticated) {
                                ConnexionRequiseDialog.show(
                                  context,
                                  title: 'Connexion requise',
                                  description:
                                      'Veuillez vous connecter pour ajouter ${produit.nom} à votre panier.',
                                );
                                return;
                              }

                              ref
                                  .read(panierStateProvider.notifier)
                                  .ajouterProduit(
                                    produit.produitId,
                                    pharmacopeeId: pharma.id,
                                    nomPharmacopee: pharma.nom,
                                   );
                              ref.read(checkoutProvider.notifier).initCheckout(
                                    pharmacopeeId: pharma.id,
                                    nomPharmacopee: pharma.nom,
                                  );
                            },
                          );
                        },
                        childCount: filteredProduits.length,
                      ),
                    ),
                  ),
              ] else ...[
                // Onglet Avis : affiché immédiatement sans avoir à faire défiler tous les produits !
                SliverToBoxAdapter(
                  child: avisAsync.when(
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (_, __) => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('Erreur lors du chargement des avis.'),
                      ),
                    ),
                    data: (avis) => PharmacopeeAvisSection(
                      avis: avis,
                      noteMoyenne: pharma.noteMoyenne,
                      nombreAvis: pharma.nombreAvis,
                      eligibilite: eligibiliteAsync.valueOrNull,
                      onDonnerAvis: () => handleDonnerAvis(pharma.nom),
                    ),
                  ),
                ),
              ],

              const SliverToBoxAdapter(
                child: SizedBox(height: 80),
              ),
            ],
          ),
        );
        },
      ),

      // Bouton flottant du panier si des articles ont été ajoutés
      floatingActionButton: nombreArticlesPanier > 0
          ? FloatingActionButton.extended(
              heroTag: 'fab_pharmacopee_panier',
              onPressed: () {
                context.push(RouteNames.citizenPanierViewPath);
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

/// Sliver qui couvre uniquement la barre d'état (SafeArea supérieure) dès que
/// l'en-tête principal a défilé, sans ajouter d'espace supplémentaire dans le flux.
class _StatusBarCoverSliver extends LeafRenderObjectWidget {
  final double topSafeArea;
  final Color color;

  const _StatusBarCoverSliver({
    required this.topSafeArea,
    required this.color,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderStatusBarCoverSliver(
      topSafeArea: topSafeArea,
      color: color,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderStatusBarCoverSliver renderObject,
  ) {
    renderObject
      ..topSafeArea = topSafeArea
      ..color = color;
  }
}

class _RenderStatusBarCoverSliver extends RenderSliver {
  double _topSafeArea;
  Color _color;

  _RenderStatusBarCoverSliver({
    required double topSafeArea,
    required Color color,
  })  : _topSafeArea = topSafeArea,
        _color = color;

  set topSafeArea(double value) {
    if (_topSafeArea == value) return;
    _topSafeArea = value;
    markNeedsLayout();
  }

  set color(Color value) {
    if (_color == value) return;
    _color = value;
    markNeedsPaint();
  }

  @override
  void performLayout() {
    if (constraints.scrollOffset <= 0 || _topSafeArea <= 0) {
      geometry = SliverGeometry.zero;
      return;
    }
    final double paintExtent =
        _topSafeArea.clamp(0.0, constraints.remainingPaintExtent);
    geometry = SliverGeometry(
      scrollExtent: 0.0,
      paintOrigin: 0.0,
      paintExtent: paintExtent,
      layoutExtent: 0.0,
      maxPaintExtent: _topSafeArea,
      hitTestExtent: 0.0,
      visible: paintExtent > 0.0,
      hasVisualOverflow: false,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (geometry == null || !geometry!.visible) return;
    final Paint paint = Paint()..color = _color;
    context.canvas.drawRect(
      offset & Size(constraints.crossAxisExtent, geometry!.paintExtent),
      paint,
    );
  }
}

/// Sliver qui affiche la barre de recherche, le bouton retour et les catégories
/// dans le flux normal sans espace superflu, puis les fixe en haut de l'écran
/// (sous la barre d'état) lors du défilement vers le haut.
class _PinnedSearchBarSliver extends SingleChildRenderObjectWidget {
  final double topSafeArea;

  const _PinnedSearchBarSliver({
    required this.topSafeArea,
    required super.child,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderPinnedSearchBarSliver(topSafeArea: topSafeArea);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderPinnedSearchBarSliver renderObject,
  ) {
    renderObject.topSafeArea = topSafeArea;
  }
}

class _RenderPinnedSearchBarSliver extends RenderSliverSingleBoxAdapter {
  double _topSafeArea;

  _RenderPinnedSearchBarSliver({required double topSafeArea})
      : _topSafeArea = topSafeArea;

  set topSafeArea(double value) {
    if (_topSafeArea == value) return;
    _topSafeArea = value;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    if (child == null) {
      geometry = SliverGeometry.zero;
      return;
    }

    final SliverConstraints constraints = this.constraints;
    child!.layout(constraints.asBoxConstraints(), parentUsesSize: true);
    final double childExtent = child!.size.height;

    final double yOnScreen =
        constraints.viewportMainAxisExtent - constraints.remainingPaintExtent;
    final bool isPinned =
        constraints.scrollOffset > 0 || yOnScreen <= _topSafeArea;

    final double scrollExtent = isPinned
        ? math.max(0.0, childExtent - _topSafeArea)
        : childExtent;

    if (!isPinned) {
      final double paintedChildSize =
          calculatePaintOffset(constraints, from: 0.0, to: scrollExtent);
      final double cacheExtent =
          calculateCacheOffset(constraints, from: 0.0, to: scrollExtent);

      geometry = SliverGeometry(
        scrollExtent: scrollExtent,
        paintExtent: paintedChildSize,
        cacheExtent: cacheExtent,
        maxPaintExtent: scrollExtent,
        hitTestExtent: paintedChildSize,
        hasVisualOverflow: childExtent > constraints.remainingPaintExtent ||
            constraints.scrollOffset > 0.0,
      );
      setChildParentData(child!, constraints, geometry!);
      return;
    }

    final double paintOrigin = constraints.scrollOffset > 0
        ? 0.0
        : -yOnScreen.clamp(0.0, _topSafeArea);
    final double paintExtent =
        childExtent.clamp(0.0, constraints.remainingPaintExtent);
    final double layoutExtent =
        (scrollExtent - constraints.scrollOffset).clamp(0.0, paintExtent);
    final double cacheExtent =
        calculateCacheOffset(constraints, from: 0.0, to: scrollExtent);

    geometry = SliverGeometry(
      scrollExtent: scrollExtent,
      paintOrigin: paintOrigin,
      paintExtent: paintExtent,
      layoutExtent: layoutExtent,
      maxPaintExtent: math.max(childExtent, paintExtent),
      maxScrollObstructionExtent: childExtent,
      cacheExtent: math.max(cacheExtent, layoutExtent),
      hitTestExtent: paintExtent,
      hasVisualOverflow: false,
    );

    final SliverPhysicalParentData childParentData =
        child!.parentData! as SliverPhysicalParentData;
    childParentData.paintOffset = Offset.zero;
  }

  @override
  double childMainAxisPosition(RenderBox child) => 0.0;
}



