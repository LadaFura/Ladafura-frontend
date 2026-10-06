import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/services/location_service.dart';
import '../../../../shared/widgets/feedback/app_loading_indicator.dart';
import '../../../home/providers/home_discovery_provider.dart';
import '../../../pharmacopees/models/pharmacopee_model.dart';
import '../../models/carte_filter_model.dart';
import '../../providers/carte_provider.dart';
import '../widgets/carte_pharmacopee_detail_card.dart';

/// Écran Carte Interactive basé sur OpenStreetMap (100% libre et gratuit).
///
/// Intègre :
/// - Une barre de recherche supérieure ("Rechercher une pharmacopée, un produit...")
/// - Des filtres rapides ("Filtres", "Distance", "Ouvert", "Livraison")
/// - Carte OpenStreetMap interactive (tuiles gratuites OSM)
/// - Marqueurs stylisés avec icône feuille verte
/// - Bouton de recentrage GPS sur la position de l'utilisateur
/// - Fiche inférieure détaillée interactive avec bouton "Voir la pharmacopée"
class CarteScreen extends ConsumerStatefulWidget {
  const CarteScreen({super.key});

  @override
  ConsumerState<CarteScreen> createState() => _CarteScreenState();
}

class _CarteScreenState extends ConsumerState<CarteScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  // Coordonnées par défaut : Bamako, Mali (Place de l'Indépendance / Fleuve Niger)
  static const LatLng _bamakoCenter = LatLng(12.6392, -8.0029);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestUserLocation();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _requestUserLocation({bool showFeedbackOnDenied = false}) async {
    final notifier = ref.read(userLocationProvider.notifier);
    final coords = await notifier.requestLocationWithPermission();
    if (mounted) {
      if (coords != null) {
        _mapController.animateTo(
          LatLng(coords.latitude, coords.longitude),
          zoom: 14.5,
        );
      } else if (showFeedbackOnDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Position inaccessible. Vérifiez que la localisation GPS est activée et autorisée.',
            ),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _onMarkerTap(PharmacopeeModel pharmacopee) {
    ref.read(selectedCartePharmacopeeProvider.notifier).state = pharmacopee;
    _mapController.animateTo(
      LatLng(pharmacopee.latitude, pharmacopee.longitude),
      zoom: 14.5,
    );
  }

  void _recenterMap(GeoCoordinates? userCoords) {
    if (userCoords != null) {
      _mapController.animateTo(
        LatLng(userCoords.latitude, userCoords.longitude),
        zoom: 14.5,
      );
    } else {
      _requestUserLocation(showFeedbackOnDenied: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pharmacopeesAsync = ref.watch(cartePharmacopeesProvider);
    final selectedPharmacopee = ref.watch(selectedCartePharmacopeeProvider);
    final filter = ref.watch(carteFilterProvider);
    final userLocationAsync = ref.watch(userLocationProvider);
    final userLocation = userLocationAsync.valueOrNull;

    final currentPath = GoRouterState.of(context).uri.toString();
    final isCitizen = currentPath.startsWith('/citizen');

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.surface,
      body: Stack(
        children: [
          // 1. FOND DE CARTE OPENSTREETMAP (Gratuit, interactif, tuiles OSM officielles)
          pharmacopeesAsync.when(
            loading: () => const Center(child: AppLoadingIndicator()),
            error: (err, stack) => _buildMapFallback(
              context: context,
              isDark: isDark,
              pharmacopees: const [],
              userLocation: userLocation,
            ),
            data: (pharmacopees) {
              return _buildOpenStreetMap(
                context: context,
                isDark: isDark,
                pharmacopees: pharmacopees,
                selectedPharmacopee: selectedPharmacopee,
                userLocation: userLocation,
              );
            },
          ),

          // 2. BARRE SUPÉRIEURE : RECHERCHE & FILTRES RAPIDES
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.space16,
                vertical: AppDimensions.space8,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Champ de recherche
                  _buildSearchBar(context, isDark),
                  const SizedBox(height: AppDimensions.space8),

                  // Ligne des filtres horizontaux
                  _buildFilterChips(context, isDark, filter),
                ],
              ),
            ),
          ),

          // 3. BOUTON FLOTTANT DE RECENTRAGE GPS
          Positioned(
            right: AppDimensions.space16,
            top: MediaQuery.of(context).padding.top + 120,
            child: Material(
              color: isDark ? AppColors.darkSurface : AppColors.surface,
              elevation: 4,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => _recenterMap(userLocation),
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.space12),
                  child: Icon(
                    Icons.my_location_rounded,
                    color: isDark ? AppColors.darkPrimary : AppColors.primary,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),

          // 4. FICHE INFÉRIEURE RÉTRACTABLE (PHARMACOPÉE SÉLECTIONNÉE)
          if (selectedPharmacopee != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: CartePharmacopeeDetailCard(
                pharmacopee: selectedPharmacopee,
                userCoordinates: userLocation,
                onViewDetail: () {
                  final idStr = selectedPharmacopee.id.toString();
                  final detailPath = isCitizen
                      ? RouteNames.citizenPharmacopeeDetailUrl(idStr)
                      : RouteNames.visitorPharmacopeeDetailUrl(idStr);
                  context.push(detailPath);
                },
                onClose: () {
                  ref.read(selectedCartePharmacopeeProvider.notifier).state =
                      null;
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOpenStreetMap({
    required BuildContext context,
    required bool isDark,
    required List<PharmacopeeModel> pharmacopees,
    required PharmacopeeModel? selectedPharmacopee,
    required GeoCoordinates? userLocation,
  }) {
    // Calcul de la position initiale de la carte
    final initialCenter = selectedPharmacopee != null
        ? LatLng(selectedPharmacopee.latitude, selectedPharmacopee.longitude)
        : (userLocation != null
            ? LatLng(userLocation.latitude, userLocation.longitude)
            : (pharmacopees.isNotEmpty
                ? LatLng(
                    pharmacopees.first.latitude, pharmacopees.first.longitude)
                : _bamakoCenter));

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: initialCenter,
        initialZoom: 13.2,
        minZoom: 5.0,
        maxZoom: 18.0,
        onTap: (_, __) {
          // Désélectionne la carte si l'utilisateur clique sur la carte vide
          if (ref.read(selectedCartePharmacopeeProvider) != null) {
            ref.read(selectedCartePharmacopeeProvider.notifier).state = null;
          }
        },
      ),
      children: [
        // Tuiles OpenStreetMap gratuites
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'ml.ladafura.mobile',
        ),

        // Marqueur de l'utilisateur (point bleu GPS pulsé avec halo) si géolocalisé
        if (userLocation != null)
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(userLocation.latitude, userLocation.longitude),
                width: 36,
                height: 36,
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Halo translucide
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.info.withValues(alpha: 0.22),
                        ),
                      ),
                      // Point GPS bleu vif avec bordure blanche
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.5),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      // Noyau central blanc
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

        // Marqueurs des pharmacopées
        MarkerLayer(
          markers: pharmacopees.map((pharma) {
            final isSelected = selectedPharmacopee?.id == pharma.id;
            return Marker(
              point: LatLng(pharma.latitude, pharma.longitude),
              width: isSelected ? 62 : 46,
              height: isSelected ? 62 : 46,
              child: GestureDetector(
                onTap: () => _onMarkerTap(pharma),
                child: _buildPinWidget(isSelected: isSelected, isDark: isDark),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMapFallback({
    required BuildContext context,
    required bool isDark,
    required List<PharmacopeeModel> pharmacopees,
    required GeoCoordinates? userLocation,
  }) {
    return Container(
      color: isDark ? AppColors.darkSurface : AppColors.primaryLight,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.map_rounded, size: 54, color: AppColors.primary),
            const SizedBox(height: AppDimensions.space8),
            Text(
              'Carte interactive indisponible hors-ligne',
              style: isDark ? AppTextStyles.bodyDark : AppTextStyles.body,
            ),
          ],
        ),
      ),
    );
  }

  /// Épingle circulaire verte avec icône feuille et ombre conforme à la maquette
  Widget _buildPinWidget({required bool isSelected, required bool isDark}) {
    final size = isSelected ? 56.0 : 42.0;
    final iconSize = isSelected ? 30.0 : 22.0;
    final pinColor = isSelected
        ? (isDark ? AppColors.darkPrimaryDark : AppColors.primaryDark)
        : (isDark ? AppColors.darkPrimary : AppColors.primary);

    return Stack(
      alignment: Alignment.center,
      children: [
        // Cercle extérieur avec halo si sélectionné
        if (isSelected)
          Container(
            width: size + 6,
            height: size + 6,
            decoration: BoxDecoration(
              color: pinColor.withValues(alpha: 0.25),
              shape: BoxShape.circle,
            ),
          ),

        // Badge principal circulaire vert foncé
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: pinColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: isSelected ? 2.5 : 2.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.eco_rounded,
              color: Colors.white,
              size: iconSize,
            ),
          ),
        ),

        // Petit point vert sous l'épingle pour pointer précisément le sol
        Positioned(
          bottom: 0,
          child: Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: pinColor,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  /// Barre de recherche avec style épuré et arrondi
  Widget _buildSearchBar(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCapsule),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
          width: AppDimensions.cardBorderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: isDark ? AppTextStyles.bodyDark : AppTextStyles.body,
        onChanged: (val) {
          ref.read(carteSearchQueryProvider.notifier).state = val;
        },
        decoration: InputDecoration(
          hintText: 'Rechercher une pharmacopée, maladie, produit...',
          hintStyle: (isDark
                  ? AppTextStyles.bodySecondaryDark
                  : AppTextStyles.bodySecondary)
              .copyWith(color: AppColors.textMuted),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            size: 22,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(carteSearchQueryProvider.notifier).state = '';
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space16,
            vertical: AppDimensions.space12,
          ),
        ),
      ),
    );
  }

  /// Puces de filtre horizontales : Filtres (avec indicateur actif), Ouvert, Livraison, Retrait sur place, Mieux notées
  Widget _buildFilterChips(
      BuildContext context, bool isDark, CarteFilterModel filter) {
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // 1. Bouton "Filtres" (Ouvre la feuille modale des filtres avancés ou réinitialise)
          _buildFilterChip(
            icon: Icons.tune_rounded,
            label: filter.hasActiveFilters ? 'Filtres actifs' : 'Filtres',
            isSelected: filter.hasActiveFilters,
            isDark: isDark,
            onTap: () => _showFilterBottomSheet(context, isDark, filter),
          ),
          const SizedBox(width: AppDimensions.space8),

          // 2. Puce "Ouvert"
          _buildFilterChip(
            icon: Icons.access_time_filled_rounded,
            label: 'Ouvert',
            isSelected: filter.showOnlyOpen,
            isDark: isDark,
            onTap: () {
              ref.read(carteFilterProvider.notifier).state = filter.copyWith(
                showOnlyOpen: !filter.showOnlyOpen,
              );
            },
          ),
          const SizedBox(width: AppDimensions.space8),

          // 3. Puce "Livraison"
          _buildFilterChip(
            icon: Icons.local_shipping_rounded,
            label: 'Livraison',
            isSelected: filter.showOnlyWithDelivery,
            isDark: isDark,
            onTap: () {
              ref.read(carteFilterProvider.notifier).state = filter.copyWith(
                showOnlyWithDelivery: !filter.showOnlyWithDelivery,
              );
            },
          ),
          const SizedBox(width: AppDimensions.space8),

          // 4. Puce "Retrait sur place"
          _buildFilterChip(
            icon: Icons.storefront_rounded,
            label: 'Retrait sur place',
            isSelected: filter.showOnlyPickup,
            isDark: isDark,
            onTap: () {
              ref.read(carteFilterProvider.notifier).state = filter.copyWith(
                showOnlyPickup: !filter.showOnlyPickup,
              );
            },
          ),
          const SizedBox(width: AppDimensions.space8),

          // 5. Puce "Mieux notées (★ 4.5+)"
          _buildFilterChip(
            icon: Icons.star_rounded,
            label: 'Mieux notées',
            isSelected: filter.showOnlyTopRated,
            isDark: isDark,
            onTap: () {
              ref.read(carteFilterProvider.notifier).state = filter.copyWith(
                showOnlyTopRated: !filter.showOnlyTopRated,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    IconData? icon,
    required String label,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final bgColor = isSelected
        ? (isDark ? AppColors.darkPrimaryDark : AppColors.primary)
        : (isDark ? AppColors.darkSurface : AppColors.surface);
    final textColor = isSelected
        ? Colors.white
        : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary);
    final borderColor = isSelected
        ? (isDark ? AppColors.darkPrimaryDark : AppColors.primary)
        : (isDark ? AppColors.darkBorder : AppColors.border);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusCapsule),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppDimensions.radiusCapsule),
          border: Border.all(color: borderColor, width: AppDimensions.cardBorderWidth),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: textColor),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: AppTextStyles.badge.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Boîte de dialogue modale élégante pour les filtres avancés (Région, Services, Notation)
  void _showFilterBottomSheet(
    BuildContext context,
    bool isDark,
    CarteFilterModel currentFilter,
  ) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final activeFilter = ref.watch(carteFilterProvider);

            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppDimensions.radiusBottomSheet),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 16,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // En-tête fixe
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppDimensions.space20,
                        AppDimensions.space12,
                        AppDimensions.space20,
                        0,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Center(
                            child: Container(
                              width: 44,
                              height: 4,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.darkBorder
                                    : const Color(0xFFD6D6D6),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppDimensions.space16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Filtres de la carte',
                                style: (isDark
                                        ? AppTextStyles.h3Dark
                                        : AppTextStyles.h3)
                                    .copyWith(fontSize: 18),
                              ),
                              if (activeFilter.hasActiveFilters)
                                TextButton(
                                  onPressed: () {
                                    ref
                                        .read(carteFilterProvider.notifier)
                                        .state = const CarteFilterModel();
                                    setModalState(() {});
                                  },
                                  child: const Text(
                                    'Réinitialiser',
                                    style: TextStyle(
                                      color: AppColors.danger,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const Divider(height: AppDimensions.space20),
                        ],
                      ),
                    ),

                    // Contenu défilable
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.space20,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [

                  // Section 1 : Services disponibles
                  Text(
                    'SERVICES DISPONIBLES',
                    style: (isDark
                            ? AppTextStyles.captionDark
                            : AppTextStyles.caption)
                        .copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: isDark ? AppColors.darkPrimary : AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.space8),

                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Livraison disponible'),
                    subtitle: const Text('Pharmacopées proposant l\'expédition à domicile'),
                    value: activeFilter.showOnlyWithDelivery,
                    activeTrackColor: isDark ? AppColors.darkPrimary : AppColors.primary,
                    onChanged: (val) {
                      ref.read(carteFilterProvider.notifier).state =
                          activeFilter.copyWith(showOnlyWithDelivery: val);
                      setModalState(() {});
                    },
                  ),

                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Retrait sur place (Pickup)'),
                    subtitle: const Text('Commande prête à retirer sur place'),
                    value: activeFilter.showOnlyPickup,
                    activeTrackColor: isDark ? AppColors.darkPrimary : AppColors.primary,
                    onChanged: (val) {
                      ref.read(carteFilterProvider.notifier).state =
                          activeFilter.copyWith(showOnlyPickup: val);
                      setModalState(() {});
                    },
                  ),

                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Mieux notées uniquement (★ 4.5+)'),
                    subtitle: const Text('Pharmacopées les mieux recommandées par la population'),
                    value: activeFilter.showOnlyTopRated,
                    activeTrackColor: isDark ? AppColors.darkPrimary : AppColors.primary,
                    onChanged: (val) {
                      ref.read(carteFilterProvider.notifier).state =
                          activeFilter.copyWith(showOnlyTopRated: val);
                      setModalState(() {});
                    },
                  ),

                  const SizedBox(height: AppDimensions.space16),

                  // Section 2 : Filtrer par Région
                  Text(
                    'RÉGION DU MALI',
                    style: (isDark
                            ? AppTextStyles.captionDark
                            : AppTextStyles.caption)
                        .copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: isDark ? AppColors.darkPrimary : AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.space8),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      'Bamako',
                      'Koulikoro',
                      'Sikasso',
                      'Ségou',
                      'Mopti',
                      'Kayes',
                    ].map((region) {
                      final isSelected = activeFilter.selectedRegion == region;
                      return ChoiceChip(
                        label: Text(region),
                        selected: isSelected,
                        selectedColor: isDark
                            ? AppColors.darkPrimaryContainer
                            : AppColors.primaryLight,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? (isDark
                                  ? AppColors.darkPrimary
                                  : AppColors.primaryDark)
                              : (isDark ? Colors.white70 : Colors.black87),
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (selected) {
                          ref.read(carteFilterProvider.notifier).state =
                              activeFilter.copyWith(
                            selectedRegion: selected ? region : null,
                          );
                          setModalState(() {});
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppDimensions.space16),
                ],
              ),
            ),
          ),

          // Barre d'action inférieure fixe, bien remontée au-dessus de tout et protégée des marges
          Container(
            padding: EdgeInsets.fromLTRB(
              AppDimensions.space20,
              AppDimensions.space12,
              AppDimensions.space20,
              MediaQuery.of(context).viewInsets.bottom + AppDimensions.space20,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.surface,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                  width: 1,
                ),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isDark ? AppColors.darkPrimary : AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusButton),
                  ),
                  elevation: 2,
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Appliquer les filtres',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
          },
        );
      },
    );
  }
}

/// Extension d'animation de recentrage souple pour MapController
extension MapControllerAnimated on MapController {
  void animateTo(LatLng destCenter, {double? zoom}) {
    move(destCenter, zoom ?? camera.zoom);
  }
}
