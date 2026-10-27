import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../shared/widgets/feedback/app_loading_indicator.dart';
import '../../../pharmacopees/models/pharmacopee_produit_item_model.dart';
import '../../../pharmacopees/presentation/widgets/produit_detail_modal.dart';
import '../../models/favori_model.dart';
import '../../providers/favori_provider.dart';

/// Page « Mes Favoris » pour l'espace Citoyen / Population.
/// Permet de consulter, filtrer et retirer ses Plantes, Remèdes (Produits) et Pharmacopées favoris.
class FavorisScreen extends ConsumerStatefulWidget {
  const FavorisScreen({super.key});

  @override
  ConsumerState<FavorisScreen> createState() => _FavorisScreenState();
}

class _FavorisScreenState extends ConsumerState<FavorisScreen> {
  /// null = Tous, sinon filtre par type
  TypeFavori? _selectedFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(favorisProvider.notifier).chargerFavoris();
      }
    });
  }

  String _formatPrix(double? prix) {
    if (prix == null || prix <= 0) return 'Prix sur demande';
    final intVal = prix.round();
    final formatted = intVal.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );
    return '$formatted FCFA';
  }

  Future<void> _handleRemoveFavori(FavoriItemModel item) async {
    final success =
        await ref.read(favorisProvider.notifier).supprimerFavoriById(item);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Retiré de vos favoris'
              : 'Impossible de retirer ce favori pour le moment',
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(favorisProvider);

    final filteredItems = _selectedFilter == null
        ? state.items
        : state.items.where((i) => i.type == _selectedFilter).toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              Navigator.of(context).maybePop();
            }
          },
        ),
        title: Text(
          'Mes Favoris',
          style: isDark ? AppTextStyles.h3Dark : AppTextStyles.h3,
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Barre de filtres par catégorie (Tous, Plantes, Remèdes, Pharmacopées)
          Container(
            width: double.infinity,
            color: isDark ? AppColors.darkSurface : Colors.white,
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.space16,
              AppDimensions.space8,
              AppDimensions.space16,
              AppDimensions.space12,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(
                    label: 'Tous',
                    count: state.counts.total,
                    icon: Icons.favorite_rounded,
                    isSelected: _selectedFilter == null,
                    isDark: isDark,
                    onTap: () => setState(() => _selectedFilter = null),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: 'Plantes',
                    count: state.counts.totalPlantes,
                    icon: Icons.eco_rounded,
                    isSelected: _selectedFilter == TypeFavori.plante,
                    isDark: isDark,
                    onTap: () =>
                        setState(() => _selectedFilter = TypeFavori.plante),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: 'Remèdes',
                    count: state.counts.totalProduits,
                    icon: Icons.medication_liquid_rounded,
                    isSelected: _selectedFilter == TypeFavori.produit,
                    isDark: isDark,
                    onTap: () =>
                        setState(() => _selectedFilter = TypeFavori.produit),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: 'Pharmacopées',
                    count: state.counts.totalPharmacopees,
                    icon: Icons.storefront_rounded,
                    isSelected: _selectedFilter == TypeFavori.pharmacopee,
                    isDark: isDark,
                    onTap: () => setState(
                        () => _selectedFilter = TypeFavori.pharmacopee),
                  ),
                ],
              ),
            ),
          ),

          // Contenu principal
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () =>
                  ref.read(favorisProvider.notifier).chargerFavoris(),
              child: state.isLoading && state.items.isEmpty
                  ? const Center(child: AppLoadingIndicator())
                  : filteredItems.isEmpty
                      ? _buildEmptyState(isDark)
                      : ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          padding: const EdgeInsets.all(AppDimensions.space16),
                          itemCount: filteredItems.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: AppDimensions.space12),
                          itemBuilder: (context, index) {
                            final item = filteredItems[index];
                            return _buildFavoriCard(item, isDark);
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required int count,
    required IconData icon,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final activeColor = isDark ? AppColors.darkPrimary : AppColors.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor
              : (isDark ? AppColors.darkBackground : const Color(0xFFF3F6F4)),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? activeColor
                : (isDark ? AppColors.darkBorder : Colors.grey.shade300),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? Colors.white
                  : (isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white : AppColors.textPrimary),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.22)
                    : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? Colors.white
                      : (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    String title = 'Aucun favori enregistré';
    String subtitle =
        'Explorez les plantes médicinales, remèdes traditionnels et pharmacopées agréées puis appuyez sur le cœur pour les retrouver ici.';

    if (_selectedFilter == TypeFavori.plante) {
      title = 'Aucune plante favorite';
      subtitle =
          'Ajoutez des plantes médicinales à votre herbier personnel depuis leur fiche détaillée.';
    } else if (_selectedFilter == TypeFavori.produit) {
      title = 'Aucun remède favori';
      subtitle =
          'Marquez vos remèdes traditionnels préférés pour les commander plus rapidement.';
    } else if (_selectedFilter == TypeFavori.pharmacopee) {
      title = 'Aucune pharmacopée favorite';
      subtitle =
          'Enregistrez vos pharmacopées agréées de confiance pour accéder rapidement à leur catalogue.';
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppDimensions.space32),
      children: [
        const SizedBox(height: 60),
        Center(
          child: Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: AppColors.danger.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite_border_rounded,
              size: 42,
              color: AppColors.danger,
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.space20),
        Text(
          title,
          textAlign: TextAlign.center,
          style: isDark ? AppTextStyles.h3Dark : AppTextStyles.h3,
        ),
        const SizedBox(height: AppDimensions.space8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: isDark
              ? AppTextStyles.bodySecondaryDark
              : AppTextStyles.bodySecondary,
        ),
      ],
    );
  }

  Widget _buildFavoriCard(FavoriItemModel item, bool isDark) {
    switch (item.type) {
      case TypeFavori.plante:
        if (item.plante != null) {
          return _buildPlanteCard(item, item.plante!, isDark);
        }
        break;
      case TypeFavori.produit:
        if (item.produit != null) {
          return _buildProduitCard(item, item.produit!, isDark);
        }
        break;
      case TypeFavori.pharmacopee:
        if (item.pharmacopee != null) {
          return _buildPharmacopeeCard(item, item.pharmacopee!, isDark);
        }
        break;
    }
    return const SizedBox.shrink();
  }

  Widget _buildPlanteCard(
    FavoriItemModel item,
    FavoriPlanteSummary plante,
    bool isDark,
  ) {
    return InkWell(
      onTap: () {
        context.push(
          RouteNames.citizenPlanteDetailPath.replaceFirst(':id', '${plante.id}'),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: _cardDecoration(isDark),
        child: Row(
          children: [
            _buildThumbnail(
              imageUrl: plante.photoUrl,
              fallbackIcon: Icons.eco_rounded,
              isDark: isDark,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTypeBadge(
                    label: 'Plante médicinale',
                    color: AppColors.primary,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    plante.nomsVernaculaires.isNotEmpty
                        ? plante.nomsVernaculaires.first
                        : plante.nomScientifique,
                    style: (isDark ? AppTextStyles.h4Dark : AppTextStyles.h4)
                        .copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    plante.nomScientifique,
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (plante.maladies.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      plante.maladies.take(2).join(' • '),
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.darkTextMuted
                            : AppColors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.favorite_rounded,
                color: AppColors.danger,
              ),
              tooltip: 'Retirer des favoris',
              onPressed: () => _handleRemoveFavori(item),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProduitCard(
    FavoriItemModel item,
    FavoriProduitSummary produit,
    bool isDark,
  ) {
    return InkWell(
      onTap: () {
        ProduitDetailModal.show(
          context,
          produit: PharmacopeeProduitItemModel(
            disponibiliteId: 0,
            produitId: produit.id,
            nom: produit.nom,
            description: produit.description,
            forme: produit.forme,
            prix: produit.prixIndicatif ?? 0,
            photoUrl: produit.photoUrl,
            categorieId: produit.categorieId,
            categorieNom: produit.categorieNom,
            disponible: true,
            quantiteStock: 10,
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: _cardDecoration(isDark),
        child: Row(
          children: [
            _buildThumbnail(
              imageUrl: produit.photoUrl,
              fallbackIcon: Icons.medication_liquid_rounded,
              isDark: isDark,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTypeBadge(
                    label: produit.categorieNom ?? 'Remède traditionnel',
                    color: const Color(0xFF0D9488),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    produit.nom,
                    style: (isDark ? AppTextStyles.h4Dark : AppTextStyles.h4)
                        .copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (produit.forme != null &&
                      produit.forme!.trim().isNotEmpty) ...[
                    Text(
                      'Forme : ${produit.forme}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    _formatPrix(produit.prixIndicatif),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkPrimary : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.favorite_rounded,
                color: AppColors.danger,
              ),
              tooltip: 'Retirer des favoris',
              onPressed: () => _handleRemoveFavori(item),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPharmacopeeCard(
    FavoriItemModel item,
    FavoriPharmacopeeSummary pharmacopee,
    bool isDark,
  ) {
    return InkWell(
      onTap: () {
        context.push(
          RouteNames.citizenPharmacopeeDetailPath
              .replaceFirst(':id', '${pharmacopee.id}'),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: _cardDecoration(isDark),
        child: Row(
          children: [
            _buildThumbnail(
              imageUrl: pharmacopee.photoUrl,
              fallbackIcon: Icons.storefront_rounded,
              isDark: isDark,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTypeBadge(
                    label: 'Pharmacopée agréée',
                    color: AppColors.accent,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pharmacopee.nom,
                    style: (isDark ? AppTextStyles.h4Dark : AppTextStyles.h4)
                        .copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 13,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          pharmacopee.adresseCourte,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (pharmacopee.nombreProduits > 0) ...[
                    const SizedBox(height: 3),
                    Text(
                      '${pharmacopee.nombreProduits} remèdes disponibles',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color:
                            isDark ? AppColors.darkPrimary : AppColors.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.favorite_rounded,
                color: AppColors.danger,
              ),
              tooltip: 'Retirer des favoris',
              onPressed: () => _handleRemoveFavori(item),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration(bool isDark) {
    return BoxDecoration(
      color: isDark ? AppColors.darkSurface : Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isDark ? AppColors.darkBorder : Colors.grey.shade200,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  Widget _buildThumbnail({
    required String? imageUrl,
    required IconData fallbackIcon,
    required bool isDark,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 68,
        height: 68,
        color: isDark
            ? AppColors.darkPrimaryContainer
            : const Color(0xFFE8F5E9),
        child: imageUrl != null && imageUrl.trim().isNotEmpty
            ? CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Icon(
                  fallbackIcon,
                  color: isDark ? AppColors.darkPrimary : AppColors.primary,
                  size: 30,
                ),
              )
            : Icon(
                fallbackIcon,
                color: isDark ? AppColors.darkPrimary : AppColors.primary,
                size: 30,
              ),
      ),
    );
  }

  Widget _buildTypeBadge({
    required String label,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : color,
        ),
      ),
    );
  }
}
