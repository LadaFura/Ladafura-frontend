import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_colors.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_dimensions.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_text_styles.dart';
import 'package:ladafura_frontend_flutter/features/agent/models/agent_plante_model.dart';
import 'package:ladafura_frontend_flutter/features/agent/providers/agent_providers.dart';
import 'formatting_toolbar_widget.dart';

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
  final TextEditingController _nomScientifiqueController =
      TextEditingController();
  final TextEditingController _nomVernaculaireController =
      TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _selectedLangue = 'Bambara';
  static const List<String> _languesLocales = [
    'Bambara',
    'Peulh',
    'Dogon',
    'Soninké',
    'Songhaï',
    'Français',
  ];

  Timer? _debounceTimer;
  List<AgentPlanteModel> _plantes = [];
  bool _isLoading = false;
  bool _isCreating = false;
  bool _showAddForm = false;

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
    _nomScientifiqueController.dispose();
    _nomVernaculaireController.dispose();
    _descriptionController.dispose();
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

  void _openAddFormWithQuery([String? prefill]) {
    final text = (prefill ?? _searchController.text).trim();
    if (text.isNotEmpty && _nomScientifiqueController.text.trim().isEmpty) {
      _nomScientifiqueController.text = text;
    }
    setState(() => _showAddForm = true);
  }

  Future<void> _handleCreatePlanteFromForm() async {
    final nomSci = _nomScientifiqueController.text.trim();
    final nomVern = _nomVernaculaireController.text.trim();
    final description = _descriptionController.text.trim();

    if (nomSci.isEmpty && nomVern.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Veuillez renseigner le nom scientifique ou le nom vernaculaire de la plante.',
          ),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final effectiveNomScientifique = nomSci.isNotEmpty ? nomSci : nomVern;

    setState(() => _isCreating = true);
    try {
      final api = ref.read(agentApiServiceProvider);
      final newPlante = await api.createPlante(
        nomScientifique: effectiveNomScientifique,
        description: description.isNotEmpty ? description : null,
        nomVernaculaire: nomVern.isNotEmpty ? nomVern : null,
        langueVernaculaire: _selectedLangue,
      );
      ref.read(nouvelleCollecteWizardProvider.notifier).selectPlante(newPlante);
      _searchController.clear();
      _nomScientifiqueController.clear();
      _nomVernaculaireController.clear();
      _descriptionController.clear();
      setState(() {
        _isCreating = false;
        _showAddForm = false;
      });
      _loadInitialPlantes();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Plante "${newPlante.nomScientifique}" créée et sélectionnée.',
            ),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      setState(() => _isCreating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la création de la plante : $e'),
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
        // Carte de la plante actuellement sélectionnée
        if (selectedPlante != null && selectedPlante.id > 0) ...[
          Container(
            padding: const EdgeInsets.all(AppDimensions.space16),
            decoration: BoxDecoration(
              color:
                  isDark ? AppColors.darkSurfaceVariant : Colors.green.shade50,
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
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.primary,
                  ),
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
                            .copyWith(
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                        ),
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
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.danger,
                  ),
                  tooltip: 'Changer de plante',
                  onPressed: () {
                    ref
                        .read(nouvelleCollecteWizardProvider.notifier)
                        .selectPlante(null);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.space12),
        ],

        // Section Title
        Text(
          _showAddForm
              ? 'Nouvelle plante médicinale'
              : 'Sélectionner parmi les plantes répertoriées',
          style: (isDark ? AppTextStyles.bodyDark : AppTextStyles.body)
              .copyWith(fontWeight: FontWeight.bold, fontSize: 13),
        ),

        const SizedBox(height: 6),

        if (_showAddForm) ...[
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(AppDimensions.space16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.inputBorder,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _nomScientifiqueController,
                      style: isDark ? AppTextStyles.bodyDark : AppTextStyles.body,
                      decoration: const InputDecoration(
                        labelText: 'Nom scientifique (ou nom de référence) *',
                        hintText: 'Ex: Combretum micranthum, Moringa oleifera...',
                        prefixIcon: Icon(
                          Icons.science_outlined,
                          color: AppColors.primary,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _nomVernaculaireController,
                      style: isDark ? AppTextStyles.bodyDark : AppTextStyles.body,
                      decoration: const InputDecoration(
                        labelText: 'Nom vernaculaire / local (optionnel)',
                        hintText: 'Ex: Kinkéliba, Tomon, Nébédaye...',
                        prefixIcon: Icon(
                          Icons.translate_rounded,
                          color: AppColors.primary,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Langue du nom local :',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _languesLocales.map((langue) {
                        final isSelected = _selectedLangue == langue;
                        return ChoiceChip(
                          label: Text(langue),
                          selected: isSelected,
                          checkmarkColor: Colors.white,
                          selectedColor: AppColors.primary,
                          backgroundColor: isDark
                              ? AppColors.darkSurfaceVariant
                              : Colors.grey.shade100,
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.primary
                                : (isDark
                                    ? AppColors.darkBorder
                                    : AppColors.border),
                          ),
                          labelStyle: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? Colors.white
                                : (isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.textPrimary),
                          ),
                          onSelected: (_) =>
                              setState(() => _selectedLangue = langue),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Description botanique (optionnel) :',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    FormattingToolbarWidget(
                      controller: _descriptionController,
                    ),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 3,
                      style: isDark ? AppTextStyles.bodyDark : AppTextStyles.body,
                      decoration: const InputDecoration(
                        hintText:
                            'Ex: Arbuste buissonnant à feuilles opposées, fleurs blanches...',
                        alignLabelWithHint: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed:
                            _isCreating ? null : _handleCreatePlanteFromForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: _isCreating
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.check_circle_outline_rounded, size: 20),
                        label: const Text(
                          'Enregistrer et Sélectionner la plante',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: OutlinedButton(
                        onPressed: () => setState(() => _showAddForm = false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                          side: BorderSide(
                            color: isDark ? AppColors.darkBorder : Colors.grey.shade300,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Retour à la liste des plantes existantes'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ] else ...[
          // Champ de recherche
          TextField(
            controller: _searchController,
            style: isDark ? AppTextStyles.bodyDark : AppTextStyles.body,
            decoration: InputDecoration(
              hintText: 'Rechercher une plante (ex: Moringa, Ziziphus)...',
              hintStyle: (isDark ? AppTextStyles.bodyDark : AppTextStyles.body)
                  .copyWith(
                color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppColors.primary,
              ),
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
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
          ),

          const SizedBox(height: AppDimensions.space12),

          // Liste des résultats ou état vide
          if (_plantes.isEmpty && !_isLoading) ...[
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(AppDimensions.space20),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : Colors.grey.shade200,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.search_off_rounded,
                        size: 36,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        query.isNotEmpty
                            ? 'Aucune plante trouvée pour "$query".'
                            : 'Aucune plante disponible.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color:
                              isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
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
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusCard),
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

          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () => _openAddFormWithQuery(query),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark
                    ? AppColors.darkSurfaceVariant
                    : const Color(0xFFE8F5E9),
                foregroundColor: AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.primary, width: 1.2),
                ),
              ),
              icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
              label: Text(
                query.isNotEmpty
                    ? 'Ajouter la plante "$query"'
                    : 'Ajouter une nouvelle plante',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
