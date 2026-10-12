import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_colors.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_dimensions.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_text_styles.dart';
import 'package:ladafura_frontend_flutter/features/agent/models/agent_maladie_model.dart';
import 'package:ladafura_frontend_flutter/features/agent/providers/agent_providers.dart';

/// Étape 2 du Wizard : Recherche par autocomplete, sélection multiple et ajout de pathologies/symptômes.
class StepMaladiesSymptomesWidget extends ConsumerStatefulWidget {
  const StepMaladiesSymptomesWidget({super.key});

  @override
  ConsumerState<StepMaladiesSymptomesWidget> createState() =>
      _StepMaladiesSymptomesWidgetState();
}

class _StepMaladiesSymptomesWidgetState
    extends ConsumerState<StepMaladiesSymptomesWidget> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  Timer? _debounceTimer;
  List<AgentMaladieModel> _suggestions = [];
  bool _isSearching = false;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    _debounceTimer?.cancel();

    if (query.length < 2) {
      if (mounted) {
        setState(() {
          _suggestions = [];
          _isSearching = false;
        });
      }
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      if (!mounted) return;
      setState(() => _isSearching = true);
      try {
        final api = ref.read(agentApiServiceProvider);
        final results = await api.searchMaladies(search: query);
        if (mounted) {
          setState(() {
            _suggestions = results;
            _isSearching = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _suggestions = [];
            _isSearching = false;
          });
        }
      }
    });
  }

  Future<void> _handleCreateNewMaladie() async {
    final rawNom = _searchController.text.trim();
    if (rawNom.isEmpty) return;

    final draftState = ref.read(nouvelleCollecteWizardProvider);
    // Vérifier si déjà dans les sélectionnées
    if (draftState.selectedMaladies
        .any((m) => m.nom.trim().toLowerCase() == rawNom.toLowerCase())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cette affection est déjà dans votre liste.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isCreating = true);
    try {
      final api = ref.read(agentApiServiceProvider);
      final created = await api.createMaladie(nom: rawNom);

      ref.read(nouvelleCollecteWizardProvider.notifier).addMaladie(created);
      _searchController.clear();
      _focusNode.unfocus();
      setState(() {
        _suggestions = [];
        _isCreating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Affection "${created.nom}" ajoutée avec succès !'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      setState(() => _isCreating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la création : $e'),
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
    final selectedMaladies = draftState.selectedMaladies;
    final query = _searchController.text.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // En-tête explicatif
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.medical_services_outlined,
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
                    'Maladies & Symptômes ciblés',
                    style: (isDark ? AppTextStyles.h3Dark : AppTextStyles.h3)
                        .copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Associez une ou plusieurs affections traitées traditionnellement.',
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

        // Avertissement déontologique
        Container(
          padding: const EdgeInsets.all(AppDimensions.space12),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurfaceVariant
                : Colors.amber.shade50,
            borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : Colors.amber.shade200,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: Colors.amber.shade800,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Note : Ces associations représentent les usages rapportés par la tradition orale et ne constituent pas des allégations médicales prouvées.',
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.4,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : Colors.amber.shade900,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppDimensions.space16),

        // Champ de recherche / autocomplete
        TextField(
          controller: _searchController,
          focusNode: _focusNode,
          style: isDark ? AppTextStyles.bodyDark : AppTextStyles.body,
          decoration: InputDecoration(
            hintText: 'Rechercher (ex: Paludisme, Fièvre, Ulcère)...',
            hintStyle: (isDark ? AppTextStyles.bodyDark : AppTextStyles.body)
                .copyWith(color: isDark ? AppColors.darkTextMuted : AppColors.textMuted),
            prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
            suffixIcon: _isSearching
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
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _suggestions = []);
                        },
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

        // Menu de suggestions
        if (query.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(maxHeight: 220),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.inputBorder,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              children: [
                // Suggestions trouvées
                ..._suggestions.map((maladie) {
                  final isAlreadySelected = selectedMaladies.any((m) => m.id == maladie.id);
                  return ListTile(
                    dense: true,
                    leading: Icon(
                      isAlreadySelected
                          ? Icons.check_circle_rounded
                          : Icons.add_circle_outline_rounded,
                      color: isAlreadySelected ? Colors.green : AppColors.primary,
                      size: 20,
                    ),
                    title: Text(
                      maladie.nom,
                      style: (isDark ? AppTextStyles.bodyDark : AppTextStyles.body)
                          .copyWith(
                        fontWeight: FontWeight.w600,
                        color: isAlreadySelected
                            ? (isDark ? AppColors.darkTextMuted : AppColors.textMuted)
                            : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                      ),
                    ),
                    subtitle: maladie.description != null && maladie.description!.isNotEmpty
                        ? Text(
                            maladie.description!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: (isDark
                                    ? AppTextStyles.captionDark
                                    : AppTextStyles.caption)
                                .copyWith(fontSize: 11),
                          )
                        : null,
                    trailing: isAlreadySelected
                        ? const Text('Ajouté', style: TextStyle(color: Colors.green, fontSize: 11))
                        : null,
                    onTap: isAlreadySelected
                        ? null
                        : () {
                            ref
                                .read(nouvelleCollecteWizardProvider.notifier)
                                .addMaladie(maladie);
                            _searchController.clear();
                            _focusNode.unfocus();
                            setState(() => _suggestions = []);
                          },
                  );
                }),

                // Option d'ajout d'une nouvelle maladie inexistante
                if (query.length >= 2 &&
                    !_suggestions.any((m) => m.nom.trim().toLowerCase() == query.toLowerCase()))
                  ListTile(
                    dense: true,
                    leading: _isCreating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.add_rounded, color: AppColors.primary),
                    title: Text(
                      'Créer la maladie "$query"',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: const Text(
                      'Enregistrer une nouvelle affection de terrain',
                      style: TextStyle(fontSize: 11),
                    ),
                    onTap: _isCreating ? null : _handleCreateNewMaladie,
                  ),
              ],
            ),
          ),
        ],

        const SizedBox(height: AppDimensions.space20),

        // Section Badges des maladies sélectionnées
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Affections retenues (${selectedMaladies.length})',
              style: (isDark ? AppTextStyles.captionDark : AppTextStyles.caption)
                  .copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
            if (selectedMaladies.isNotEmpty)
              Text(
                'Cliquez sur × pour retirer',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppDimensions.space8),

        if (selectedMaladies.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: AppDimensions.space24,
              horizontal: AppDimensions.space16,
            ),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurface.withValues(alpha: 0.5)
                  : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : Colors.grey.shade300,
                style: BorderStyle.solid,
              ),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.bubble_chart_outlined,
                    size: 36,
                    color: isDark ? AppColors.darkTextMuted : Colors.grey.shade400,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Aucune maladie ou symptôme associé pour le moment.',
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
                  const SizedBox(height: 4),
                  Text(
                    'Utilisez la barre ci-dessus pour rechercher ou ajouter.',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.darkTextMuted
                          : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: selectedMaladies.map((m) {
              return Chip(
                backgroundColor: isDark
                    ? AppColors.darkSurfaceVariant
                    : AppColors.primary.withValues(alpha: 0.08),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                avatar: const CircleAvatar(
                  backgroundColor: AppColors.primary,
                  radius: 10,
                  child: Icon(Icons.check, size: 12, color: Colors.white),
                ),
                label: Text(
                  m.nom,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                ),
                deleteIcon: const Icon(Icons.close_rounded, size: 16),
                deleteIconColor: AppColors.danger,
                onDeleted: () {
                  ref
                      .read(nouvelleCollecteWizardProvider.notifier)
                      .removeMaladie(m.id);
                },
              );
            }).toList(),
          ),
      ],
    );
  }
}
