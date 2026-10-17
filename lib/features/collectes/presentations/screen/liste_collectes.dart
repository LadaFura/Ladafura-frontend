import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_colors.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_dimensions.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_text_styles.dart';
import 'package:ladafura_frontend_flutter/core/routing/route_names.dart';
import 'package:ladafura_frontend_flutter/features/agent/providers/agent_providers.dart';
import 'package:ladafura_frontend_flutter/features/agent/presentation/collectes/widgets/collecte_card_widget.dart';
import 'package:ladafura_frontend_flutter/features/collectes/models/agent_collecte_summary_response.dart';
import 'package:ladafura_frontend_flutter/shared/widgets/inputs/search_bar_widget.dart';

/// Écran listant l'ensemble des collectes de terrain de l'agent avec recherche dynamique et filtres par statut.
class ListeCollectes extends ConsumerStatefulWidget {
  const ListeCollectes({super.key});

  @override
  ConsumerState<ListeCollectes> createState() => _ListeCollectesState();
}

class _ListeCollectesState extends ConsumerState<ListeCollectes> {
  late final TextEditingController _searchController;
  String _searchQuery = '';

  final List<Map<String, String>> _filtres = const [
    {'id': 'TOUTES', 'label': 'Toutes'},
    {'id': 'BROUILLON', 'label': 'Brouillons'},
    {'id': 'SOUMISE', 'label': 'En examen'},
    {'id': 'VALIDEE', 'label': 'Validées'},
    {'id': 'REJETEE', 'label': 'À corriger'},
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _normalize(String input) {
    return input
        .toLowerCase()
        .replaceAll('é', 'e')
        .replaceAll('è', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('ë', 'e')
        .replaceAll('à', 'a')
        .replaceAll('â', 'a')
        .replaceAll('î', 'i')
        .replaceAll('ï', 'i')
        .replaceAll('ô', 'o')
        .replaceAll('ù', 'u')
        .replaceAll('û', 'u')
        .replaceAll('ç', 'c');
  }

  List<AgentCollecteSummaryResponse> _filterCollectes(
    List<AgentCollecteSummaryResponse> collectes,
    String query,
  ) {
    if (query.trim().isEmpty) return collectes;
    final q = _normalize(query.trim());

    return collectes.where((c) {
      final plante = _normalize(c.nomScientifiquePlante ?? '');
      final source = _normalize(c.nomSource ?? '');
      final localite = _normalize(c.localite ?? '');
      final cercle = _normalize(c.cercle ?? '');
      final region = _normalize(c.region ?? '');
      final desc = _normalize(c.description ?? '');
      final idStr = c.id.toString();
      final hashId = '#$idStr';
      final statutStr = _normalize(c.statut?.toString() ?? '');

      return plante.contains(q) ||
          source.contains(q) ||
          localite.contains(q) ||
          cercle.contains(q) ||
          region.contains(q) ||
          desc.contains(q) ||
          idStr == q ||
          hashId == q ||
          statutStr.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedFilter = ref.watch(agentCollectesFilterProvider);
    final collectesAsync = ref.watch(agentCollectesListProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.surface,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        elevation: 0.5,
        title: Text(
          'Mes Collectes',
          style: (isDark ? AppTextStyles.h3Dark : AppTextStyles.h3).copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Barre supérieure : Recherche + Filtres
            Container(
              color: isDark ? AppColors.darkSurface : Colors.white,
              child: Column(
                children: [
                  // Widget de recherche
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimensions.space16,
                      AppDimensions.space8,
                      AppDimensions.space16,
                      AppDimensions.space8,
                    ),
                    child: SearchBarWidget(
                      controller: _searchController,
                      hintText: 'Rechercher (plante, localité, source...)',
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                      onClear: () {
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    ),
                  ),

                  // Barre de filtres horizontaux
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.space16,
                      vertical: AppDimensions.space4,
                    ),
                    child: Row(
                      children: _filtres.map((f) {
                        final isSel = selectedFilter == f['id'];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: FilterChip(
                            label: Text(f['label']!),
                            selected: isSel,
                            checkmarkColor: Colors.white,
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: isSel
                                  ? Colors.white
                                  : (isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.textPrimary),
                              fontWeight:
                                  isSel ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12,
                            ),
                            backgroundColor: isDark
                                ? AppColors.darkSurfaceVariant
                                : Colors.grey.shade100,
                            side: BorderSide(
                              color: isSel
                                  ? AppColors.primary
                                  : (isDark
                                      ? AppColors.darkBorder
                                      : AppColors.border),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            onSelected: (selected) {
                              ref
                                  .read(agentCollectesFilterProvider.notifier)
                                  .state = f['id']!;
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.space8),
                ],
              ),
            ),

            // Indicateur de résultat de recherche active
            if (_searchQuery.trim().isNotEmpty)
              collectesAsync.maybeWhen(
                data: (allCollectes) {
                  final matches = _filterCollectes(allCollectes, _searchQuery);
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.space16,
                      vertical: AppDimensions.space8,
                    ),
                    color: (isDark ? AppColors.darkPrimary : AppColors.primary)
                        .withValues(alpha: 0.08),
                    child: Row(
                      children: [
                        Icon(
                          Icons.filter_list_rounded,
                          size: 16,
                          color:
                              isDark ? AppColors.darkPrimary : AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${matches.length} collecte${matches.length > 1 ? 's' : ''} trouvée${matches.length > 1 ? 's' : ''} pour « $_searchQuery »',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.darkPrimary
                                  : AppColors.primary,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                          child: const Text(
                            'Effacer',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.danger,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                orElse: () => const SizedBox.shrink(),
              ),

            // Liste de résultats
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async {
                  ref.invalidate(agentCollectesListProvider);
                },
                child: collectesAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.6,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(AppDimensions.space20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 48, color: Colors.orange),
                          const SizedBox(height: 12),
                          Text(
                            'Impossible de charger les collectes.',
                            style: isDark
                                ? AppTextStyles.bodyDark
                                : AppTextStyles.body,
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () =>
                                ref.invalidate(agentCollectesListProvider),
                            child: const Text('Réessayer'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  data: (collectes) {
                    if (collectes.isEmpty) {
                      return SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.5,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(AppDimensions.space24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.spa_outlined,
                                size: 56,
                                color: isDark
                                    ? AppColors.darkTextMuted
                                    : Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Aucune collecte trouvée pour ce filtre.',
                                style: (isDark
                                        ? AppTextStyles.h3Dark
                                        : AppTextStyles.h3)
                                    .copyWith(fontSize: 16),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Appuyez sur "Nouvelle collecte" pour débuter un enregistrement.',
                                textAlign: TextAlign.center,
                                style: (isDark
                                        ? AppTextStyles.captionDark
                                        : AppTextStyles.caption)
                                    .copyWith(
                                  color: isDark
                                      ? AppColors.darkTextMuted
                                      : AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final filtered = _filterCollectes(collectes, _searchQuery);

                    if (filtered.isEmpty) {
                      return SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.5,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(AppDimensions.space24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding:
                                    const EdgeInsets.all(AppDimensions.space16),
                                decoration: BoxDecoration(
                                  color: AppColors.warning.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.search_off_rounded,
                                  size: 48,
                                  color: AppColors.warning,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Aucun résultat pour « $_searchQuery »',
                                style: (isDark
                                        ? AppTextStyles.h3Dark
                                        : AppTextStyles.h3)
                                    .copyWith(fontSize: 16),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Vérifiez l\'orthographe du nom de la plante, du lieu ou de l\'informateur.',
                                textAlign: TextAlign.center,
                                style: (isDark
                                        ? AppTextStyles.captionDark
                                        : AppTextStyles.caption)
                                    .copyWith(
                                  color: isDark
                                      ? AppColors.darkTextMuted
                                      : AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 16),
                              OutlinedButton.icon(
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                label: const Text('Effacer la recherche'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(AppDimensions.space16),
                      itemCount: filtered.length,
                      separatorBuilder: (ctx, i) => const SizedBox(height: 12),
                      itemBuilder: (ctx, index) {
                        final c = filtered[index];
                        return CollecteCardWidget(
                          collecte: c,
                          onTap: () {
                            context.push(
                                '${RouteNames.agentCollectesPath}/${c.id}');
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.border,
            ),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 58,
            child: Row(
              children: [
                Expanded(
                  child: _CollecteNavItem(
                    icon: Icons.home_outlined,
                    label: 'Accueil',
                    isDark: isDark,
                    onTap: () => context.go(RouteNames.agentDashboardPath),
                  ),
                ),
                Expanded(
                  child: _CollecteNavItem(
                    icon: Icons.folder_rounded,
                    label: 'Collectes',
                    isDark: isDark,
                    selected: true,
                    onTap: () {},
                  ),
                ),
                Expanded(
                  child: Center(
                    child: SizedBox(
                      width: 42,
                      height: 42,
                      child: FloatingActionButton(
                        heroTag: 'agent_collectes_nav_fab',
                        tooltip: 'Nouvelle collecte',
                        onPressed: () {
                          ref
                              .read(nouvelleCollecteWizardProvider.notifier)
                              .reset();
                          context.push(RouteNames.agentNouvelleCollectePath);
                        },
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: const CircleBorder(),
                        child: const Icon(Icons.add, size: 25),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _CollecteNavItem(
                    icon: Icons.notifications_none_outlined,
                    label: 'Notif.',
                    isDark: isDark,
                    onTap: () => context.go(RouteNames.agentNotificationsPath),
                  ),
                ),
                Expanded(
                  child: _CollecteNavItem(
                    icon: Icons.person_outline,
                    label: 'Profil',
                    isDark: isDark,
                    onTap: () => context.go(RouteNames.agentProfilPath),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CollecteNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final bool selected;
  final VoidCallback onTap;

  const _CollecteNavItem({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? AppColors.primary
        : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary);
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 19, color: color),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
