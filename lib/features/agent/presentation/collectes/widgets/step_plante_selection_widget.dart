import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_colors.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_dimensions.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_text_styles.dart';
import 'package:ladafura_frontend_flutter/features/agent/models/agent_plante_model.dart';
import 'package:ladafura_frontend_flutter/features/agent/providers/agent_providers.dart';

/// Étape 1 du Wizard : Sélection ou création d'une plante médicinale de référence.
class StepPlanteSelectionWidget extends ConsumerStatefulWidget {
  const StepPlanteSelectionWidget({super.key});

  @override
  ConsumerState<StepPlanteSelectionWidget> createState() =>
      _StepPlanteSelectionWidgetState();
}

class _StepPlanteSelectionWidgetState
    extends ConsumerState<StepPlanteSelectionWidget> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  List<AgentPlanteModel> _plantes = [];
  bool _isLoading = false;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _loadInitialPlantes();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialPlantes([String? query]) async {
    setState(() => _isLoading = true);
    try {
      final api = ref.read(agentApiServiceProvider);
      final results = await api.searchPlantes(search: query);
      if (mounted) {
        setState(() {
          _plantes = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _plantes = [];
          _isLoading = false;
        });
      }
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      _loadInitialPlantes(query.isNotEmpty ? query : null);
    });
  }

  Future<void> _handleCreatePlante() async {
    final nom = _searchController.text.trim();
    if (nom.isEmpty) return;

    setState(() => _isCreating = true);
    try {
      final api = ref.read(agentApiServiceProvider);
      final newPlante = await api.createPlante(nomScientifique: nom);
      ref.read(nouvelleCollecteWizardProvider.notifier).selectPlante(newPlante);
      _searchController.clear();
      setState(() => _isCreating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Plante "$nom" créée en statut brouillon et sélectionnée.'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      setState(() => _isCreating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur création plante : $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final draftState = ref.watch(nouvelleCollecteWizardProvider);
    final selectedPlante = draftState.selectedPlante;
    final query = _searchController.text.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // En-tête
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.eco_rounded,
                color: AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: AppDimensions.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Identification Botanique',
                    style: (isDark ? AppTextStyles.h3Dark : AppTextStyles.h3)
                        .copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Recherchez le spécimen par nom scientifique ou local.',
                    style: (isDark
                            ? AppTextStyles.captionDark
                            : AppTextStyles.caption)
                        .copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: AppDimensions.space16),

        // Carte de la plante actuellement sélectionnée
        if (selectedPlante != null) ...[
          Container(
            padding: const EdgeInsets.all(AppDimensions.space16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceVariant : Colors.green.shade50,
              borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
              border: Border.all(
                color: isDark ? AppColors.darkPrimary : AppColors.primary,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                  child: const Icon(Icons.check_circle_rounded, color: AppColors.primary),
                ),
                const SizedBox(width: AppDimensions.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PLANTE SÉLECTIONNÉE',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        selectedPlante.nomScientifique,
                        style: (isDark ? AppTextStyles.h3Dark : AppTextStyles.h3)
                            .copyWith(fontSize: 15, fontStyle: FontStyle.italic),
                      ),
                      if (selectedPlante.nomsVernaculaires.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          selectedPlante.nomsVernaculaires.join(', '),
                          style: (isDark
                                  ? AppTextStyles.captionDark
                                  : AppTextStyles.caption)
                              .copyWith(fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                  tooltip: 'Changer de plante',
                  onPressed: () {
                    ref
                        .read(nouvelleCollecteWizardProvider.notifier)
                        .selectPlante(const AgentPlanteModel(id: 0, nomScientifique: ''));
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.space16),
        ],

        // Champ de recherche
        TextField(
          controller: _searchController,
          style: isDark ? AppTextStyles.bodyDark : AppTextStyles.body,
          decoration: InputDecoration(
            hintText: 'Rechercher une plante (ex: Moringa, Ziziphus)...',
            hintStyle: (isDark ? AppTextStyles.bodyDark : AppTextStyles.body)
                .copyWith(color: isDark ? AppColors.darkTextMuted : AppColors.textMuted),
            prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
            suffixIcon: _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
            filled: true,
            fillColor: isDark ? AppColors.darkSurface : Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.space16,
              vertical: AppDimensions.space12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
              borderSide: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.inputBorder,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
              borderSide: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.inputBorder,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),

        const SizedBox(height: AppDimensions.space12),

        // Liste des résultats
        if (_plantes.isEmpty && !_isLoading) ...[
          Container(
            padding: const EdgeInsets.all(AppDimensions.space20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : Colors.grey.shade200,
              ),
            ),
            child: Column(
              children: [
                const Icon(Icons.search_off_rounded, size: 36, color: Colors.grey),
                const SizedBox(height: 8),
                Text(
                  query.isNotEmpty
                      ? 'Aucune plante trouvée pour "$query".'
                      : 'Aucune plante disponible.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                  ),
                ),
                if (query.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _isCreating ? null : _handleCreatePlante,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    icon: _isCreating
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.add_rounded, size: 18),
                    label: Text('Créer "$query"'),
                  ),
                ],
              ],
            ),
          ),
        ] else ...[
          Expanded(
            child: ListView.separated(
              itemCount: _plantes.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 8),
              itemBuilder: (ctx, index) {
                final plante = _plantes[index];
                final isSelected = selectedPlante?.id == plante.id;

                return InkWell(
                  onTap: () {
                    ref
                        .read(nouvelleCollecteWizardProvider.notifier)
                        .selectPlante(plante);
                  },
                  borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                  child: Container(
                    padding: const EdgeInsets.all(AppDimensions.space12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark
                              ? AppColors.darkSurfaceVariant
                              : Colors.green.shade50)
                          : (isDark ? AppColors.darkSurface : Colors.white),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusCard),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : (isDark
                                ? AppColors.darkBorder
                                : AppColors.inputBorder),
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.eco_rounded,
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.space12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                plante.nomScientifique,
                                style: (isDark
                                        ? AppTextStyles.bodyDark
                                        : AppTextStyles.body)
                                    .copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              if (plante.nomsVernaculaires.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  plante.nomsVernaculaires.take(3).join(', '),
                                  style: (isDark
                                          ? AppTextStyles.captionDark
                                          : AppTextStyles.caption)
                                      .copyWith(fontSize: 11),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.primary,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
