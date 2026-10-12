import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_colors.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_dimensions.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_text_styles.dart';
import 'package:ladafura_frontend_flutter/core/routing/route_names.dart';
import 'package:ladafura_frontend_flutter/features/agent/providers/agent_providers.dart';
import 'package:ladafura_frontend_flutter/features/agent/presentation/collectes/widgets/collecte_card_widget.dart';

/// Écran listant l'ensemble des collectes de terrain de l'agent avec filtres par statut.
class ListeCollectes extends ConsumerWidget {
  const ListeCollectes({super.key});

  final List<Map<String, String>> _filtres = const [
    {'id': 'TOUTES', 'label': 'Toutes'},
    {'id': 'BROUILLON', 'label': 'Brouillons'},
    {'id': 'SOUMISE', 'label': 'En examen'},
    {'id': 'VALIDEE', 'label': 'Validées'},
    {'id': 'REJETEE', 'label': 'À corriger'},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedFilter = ref.watch(agentCollectesFilterProvider);
    final collectesAsync = ref.watch(agentCollectesListProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.surface,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        elevation: 0.5,
        title: Text(
          'Mes Collectes Terrain',
          style: (isDark ? AppTextStyles.h3Dark : AppTextStyles.h3).copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Actualiser',
            onPressed: () => ref.invalidate(agentCollectesListProvider),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_location_alt_rounded),
        label: const Text('Nouvelle collecte'),
        onPressed: () {
          ref.read(nouvelleCollecteWizardProvider.notifier).reset();
          context.push(RouteNames.agentNouvelleCollectePath);
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Barre de filtres horizontaux
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.space16,
                vertical: AppDimensions.space8,
              ),
              color: isDark ? AppColors.darkSurface : Colors.white,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _filtres.map((f) {
                    final isSel = selectedFilter == f['id'];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text(f['label']!),
                        selected: isSel,
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
            ),

            // Liste de résultats
            Expanded(
              child: collectesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.space20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.orange),
                        const SizedBox(height: 12),
                        Text(
                          'Impossible de charger les collectes.',
                          style: isDark ? AppTextStyles.bodyDark : AppTextStyles.body,
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => ref.invalidate(agentCollectesListProvider),
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (collectes) {
                  if (collectes.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppDimensions.space24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.spa_outlined,
                              size: 56,
                              color: isDark ? AppColors.darkTextMuted : Colors.grey.shade400,
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
                              'Appuyez sur "Nouvelle collecte" pour débuter un enregistrement de terrain.',
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

                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(agentCollectesListProvider);
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.all(AppDimensions.space16),
                      itemCount: collectes.length,
                      separatorBuilder: (ctx, i) => const SizedBox(height: 12),
                      itemBuilder: (ctx, index) {
                        final c = collectes[index];
                        return CollecteCardWidget(
                          collecte: c,
                          onTap: () {
                            context.push('${RouteNames.agentCollectesPath}/${c.id}');
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
