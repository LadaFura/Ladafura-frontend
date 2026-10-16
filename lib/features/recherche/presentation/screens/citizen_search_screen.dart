import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_colors.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_dimensions.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_text_styles.dart';
import 'package:ladafura_frontend_flutter/features/auth/providers/auth_state_provider.dart';
import 'package:ladafura_frontend_flutter/core/services/services_providers.dart';
import 'package:ladafura_frontend_flutter/features/recherche/providers/recent_searches_provider.dart';
import 'package:ladafura_frontend_flutter/features/recherche/providers/recherche_provider.dart';
import 'package:ladafura_frontend_flutter/shared/enums/user_role.dart';
import '../widgets/widgets.dart';

/// Écran principal de Recherche universelle LADAFURA.
///
/// Recherche intelligente :
/// - Par Maladie/Symptôme -> retourne les Pharmacopées proposant ces remèdes
/// - Par Produit -> retourne les Pharmacopées proposant ce produit
/// - Par Plante -> affiche les infos botaniques + les Pharmacopées associées
/// - Par Pharmacopée -> affiche directement la fiche de la pharmacopée
class CitizenSearchScreen extends ConsumerStatefulWidget {
  const CitizenSearchScreen({super.key});

  @override
  ConsumerState<CitizenSearchScreen> createState() =>
      _CitizenSearchScreenState();
}

class _CitizenSearchScreenState extends ConsumerState<CitizenSearchScreen> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final currentQuery = ref.read(rechercheProvider).query;
    _controller = TextEditingController(text: currentQuery);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    final userLocation = ref.read(userLocationProvider).valueOrNull;
    ref
        .read(rechercheProvider.notifier)
        .onQueryChanged(value, userLocation: userLocation);
  }

  void _onCategorySelected(SearchCategory category) {
    final userLocation = ref.read(userLocationProvider).valueOrNull;
    ref
        .read(rechercheProvider.notifier)
        .setCategory(category, userLocation: userLocation);
  }

  void _triggerSearch(String term) {
    _controller.text = term;
    final userLocation = ref.read(userLocationProvider).valueOrNull;
    ref.read(recentSearchesProvider.notifier).addSearch(term);
    ref
        .read(rechercheProvider.notifier)
        .search(term, userLocation: userLocation);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ref.listen<RechercheState>(rechercheProvider, (prev, next) {
      if (next.query != _controller.text) {
        _controller.text = next.query;
      }
    });

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Barre de saisie universelle
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.space16,
                AppDimensions.space12,
                AppDimensions.space16,
                AppDimensions.space8,
              ),
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: _controller,
                builder: (context, textValue, _) {
                  final searchState = ref.watch(rechercheProvider);
                  final isFirstPage =
                      searchState.status == RechercheStatus.idle &&
                      textValue.text.trim().isEmpty;

                  return SearchBarInput(
                    key: const ValueKey('citizen_search_bar_input'),
                    controller: _controller,
                    focusNode: _focusNode,
                    showBackButton: !isFirstPage,
                    onBack: !isFirstPage
                        ? () {
                            _focusNode.unfocus();
                            _controller.clear();
                            ref.read(rechercheProvider.notifier).reset();
                          }
                        : null,
                    onChanged: _onSearchChanged,
                    onSubmitted: (val) {
                      if (val.trim().isNotEmpty) {
                        ref.read(recentSearchesProvider.notifier).addSearch(val);
                      }
                      final userLocation =
                          ref.read(userLocationProvider).valueOrNull;
                      ref
                          .read(rechercheProvider.notifier)
                          .search(val, userLocation: userLocation);
                    },
                    onClear: () {
                      _controller.clear();
                      ref.read(rechercheProvider.notifier).reset();
                    },
                    isDark: isDark,
                  );
                },
              ),
            ),

            // 2. Zone de contenu dynamique (idle, chargement, vide, erreur, résultats)
            Expanded(
              child: Consumer(
                builder: (context, ref, _) {
                  final searchState = ref.watch(rechercheProvider);
                  final userLocation =
                      ref.watch(userLocationProvider).valueOrNull;
                  final authState = ref.watch(authStateProvider);
                  final isCitizen = authState.isAuthenticated &&
                      authState.role == UserRole.population;

                  return _buildBody(
                    context: context,
                    isDark: isDark,
                    state: searchState,
                    userLocation: userLocation,
                    isCitizen: isCitizen,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleRefresh() async {
    final state = ref.read(rechercheProvider);
    final userLocation = ref.read(userLocationProvider).valueOrNull;

    ref.invalidate(maladiesSuggestionsProvider);

    if (state.query.trim().isNotEmpty) {
      await ref
          .read(rechercheProvider.notifier)
          .search(state.query, userLocation: userLocation);
    } else if (state.status != RechercheStatus.idle) {
      await ref
          .read(rechercheProvider.notifier)
          .exploreCategory(state.selectedCategory, userLocation: userLocation);
    } else {
      try {
        await ref.read(maladiesSuggestionsProvider.future);
      } catch (_) {}
    }
  }

  Widget _buildBody({
    required BuildContext context,
    required bool isDark,
    required RechercheState state,
    required dynamic userLocation,
    required bool isCitizen,
  }) {
    // État 1 : Recherche en cours
    if (state.isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: AppDimensions.space16),
            Text(
              'Recherche dans la pharmacopée malienne...',
              style: TextStyle(
                color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    Widget content;

    // État 2 : Erreur réseau / serveur
    if (state.status == RechercheStatus.error) {
      content = LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.space24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.cloud_off_rounded,
                      size: 64,
                      color: AppColors.accent,
                    ),
                    const SizedBox(height: AppDimensions.space16),
                    Text(
                      state.errorMessage ?? 'Erreur lors de la recherche',
                      textAlign: TextAlign.center,
                      style: isDark ? AppTextStyles.h3Dark : AppTextStyles.h3,
                    ),
                    const SizedBox(height: AppDimensions.space16),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Réessayer'),
                      onPressed: () {
                        if (state.query.isNotEmpty) {
                          ref.read(rechercheProvider.notifier).search(state.query);
                        } else {
                          ref
                              .read(rechercheProvider.notifier)
                              .exploreCategory(state.selectedCategory);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
    // État 3 : Aucun résultat trouvé
    else if (state.isEmpty ||
        (state.status == RechercheStatus.success &&
            (state.results == null || state.results!.isEmpty))) {
      content = LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.space24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.search_off_rounded,
                        size: 64, color: AppColors.textMuted),
                    const SizedBox(height: AppDimensions.space16),
                    Text(
                      state.query.isNotEmpty
                          ? 'Aucun résultat pour "${state.query}"'
                          : 'Aucun élément disponible.',
                      style: isDark ? AppTextStyles.h3Dark : AppTextStyles.h3,
                    ),
                    const SizedBox(height: AppDimensions.space8),
                    Text(
                      'Essayez avec un nom de plante, une maladie (ex: Paludisme) ou le nom d\'une localité.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
    // État 4 : Résultats disponibles
    else if (state.hasResults && state.results != null) {
      content = SearchResultsList(
        results: state.results!,
        category: state.selectedCategory,
        userLocation: userLocation,
        isCitizen: isCitizen,
        isDark: isDark,
        onCategorySelected: _onCategorySelected,
      );
    }
    // État 5 : En attente de saisie (Idle)
    else {
      final recentSearches = ref.watch(recentSearchesProvider);
      final maladiesAsync = ref.watch(maladiesSuggestionsProvider);
      final maladies = maladiesAsync.valueOrNull ??
          const [
            'Diabète',
            'Hypertension',
            'Fatigue',
            'Digestion',
            'Anémie',
            'Toux',
            'Paludisme',
          ];

      content = SearchIdleSuggestions(
        recentSearches: recentSearches,
        maladies: maladies,
        onRemoveRecent: (term) =>
            ref.read(recentSearchesProvider.notifier).removeSearch(term),
        onClearAllRecent: () =>
            ref.read(recentSearchesProvider.notifier).clearAll(),
        onSelectTerm: _triggerSearch,
        onSelectCategory: _onCategorySelected,
        selectedCategory: state.selectedCategory,
        isDark: isDark,
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _handleRefresh,
      child: content,
    );
  }
}
