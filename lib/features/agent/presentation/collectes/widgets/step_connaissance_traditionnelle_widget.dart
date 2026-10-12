import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_colors.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_dimensions.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_text_styles.dart';
import 'package:ladafura_frontend_flutter/features/agent/providers/agent_providers.dart';

/// Étape 3 du Wizard : Recueil des savoirs traditionnels (partie de la plante, préparation, posologie, précautions).
class StepConnaissanceTraditionnelleWidget extends ConsumerStatefulWidget {
  const StepConnaissanceTraditionnelleWidget({super.key});

  @override
  ConsumerState<StepConnaissanceTraditionnelleWidget> createState() =>
      _StepConnaissanceTraditionnelleWidgetState();
}

class _StepConnaissanceTraditionnelleWidgetState
    extends ConsumerState<StepConnaissanceTraditionnelleWidget> {
  late final TextEditingController _usageController;
  late final TextEditingController _preparationController;
  late final TextEditingController _precautionController;

  String _selectedPartie = 'Feuilles';

  final List<String> _partiesSuggestions = [
    'Feuilles',
    'Écorce de tronc',
    'Écorce de racine',
    'Racines entières',
    'Fleurs',
    'Fruits',
    'Graines',
    'Tige',
    'Plante entière',
  ];

  final List<String> _preparationSuggestions = [
    'Décoction aqueuse',
    'Infusion chaude',
    'Macération à froid',
    'Poudre sèche (broyage)',
    'Cataplasme ou friction',
    'Fumigation',
    'Bain de vapeur',
  ];

  @override
  void initState() {
    super.initState();
    final draft = ref.read(nouvelleCollecteWizardProvider);
    _usageController = TextEditingController(text: draft.usageRapporte);
    _preparationController = TextEditingController(text: draft.preparation);
    _precautionController = TextEditingController(text: draft.precaution);

    if (draft.partieUtilisee.isNotEmpty) {
      _selectedPartie = draft.partieUtilisee;
    }

    _usageController.addListener(_sync);
    _preparationController.addListener(_sync);
    _precautionController.addListener(_sync);
  }

  @override
  void dispose() {
    _usageController.dispose();
    _preparationController.dispose();
    _precautionController.dispose();
    super.dispose();
  }

  void _sync() {
    ref.read(nouvelleCollecteWizardProvider.notifier).setConnaissances(
          usageRapporte: _usageController.text.trim(),
          partieUtilisee: _selectedPartie,
          preparation: _preparationController.text.trim(),
          precaution: _precautionController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Column(
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
                  Icons.auto_stories_rounded,
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
                      'Savoirs & Récits Traditionnels',
                      style: (isDark ? AppTextStyles.h3Dark : AppTextStyles.h3)
                          .copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Documentez l’usage thérapeutique, la recette et les précautions.',
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

          const SizedBox(height: AppDimensions.space20),

          // 1. Organe ou Partie de la plante
          Text(
            'Partie de la plante utilisée *',
            style: (isDark ? AppTextStyles.bodyDark : AppTextStyles.body)
                .copyWith(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _partiesSuggestions.map((partie) {
              final isSel = _selectedPartie == partie;
              return ChoiceChip(
                label: Text(partie),
                selected: isSel,
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSel
                      ? Colors.white
                      : (isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary),
                  fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
                backgroundColor:
                    isDark ? AppColors.darkSurface : Colors.grey.shade100,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _selectedPartie = partie);
                    _sync();
                  }
                },
              );
            }).toList(),
          ),

          const SizedBox(height: AppDimensions.space20),

          // 2. Usages rapportés
          Text(
            'Usage traditionnel rapporté *',
            style: (isDark ? AppTextStyles.bodyDark : AppTextStyles.body)
                .copyWith(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _usageController,
            maxLines: 3,
            style: isDark ? AppTextStyles.bodyDark : AppTextStyles.body,
            decoration: InputDecoration(
              hintText: 'Décrivez l’indication principale telle que transmise par le praticien...',
              hintStyle: (isDark ? AppTextStyles.bodyDark : AppTextStyles.body)
                  .copyWith(color: isDark ? AppColors.darkTextMuted : AppColors.textMuted),
              filled: true,
              fillColor: isDark ? AppColors.darkSurface : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
                borderSide: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.inputBorder,
                ),
              ),
            ),
          ),

          const SizedBox(height: AppDimensions.space20),

          // 3. Mode de préparation
          Text(
            'Mode de préparation & Administration *',
            style: (isDark ? AppTextStyles.bodyDark : AppTextStyles.body)
                .copyWith(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 6),
          // Suggestions rapides
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _preparationSuggestions.map((prep) {
                return Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: ActionChip(
                    label: Text(prep, style: const TextStyle(fontSize: 11)),
                    backgroundColor: isDark
                        ? AppColors.darkSurfaceVariant
                        : AppColors.primary.withValues(alpha: 0.08),
                    onPressed: () {
                      _preparationController.text = prep;
                      _sync();
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _preparationController,
            maxLines: 2,
            style: isDark ? AppTextStyles.bodyDark : AppTextStyles.body,
            decoration: InputDecoration(
              hintText: 'Ex: Faire bouillir 1 poignée de feuilles séchées dans 1L d’eau pendant 15 min.',
              hintStyle: (isDark ? AppTextStyles.bodyDark : AppTextStyles.body)
                  .copyWith(color: isDark ? AppColors.darkTextMuted : AppColors.textMuted),
              filled: true,
              fillColor: isDark ? AppColors.darkSurface : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
                borderSide: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.inputBorder,
                ),
              ),
            ),
          ),

          const SizedBox(height: AppDimensions.space20),

          // 4. Précautions et contre-indications
          Text(
            'Précautions, posologie & contre-indications',
            style: (isDark ? AppTextStyles.bodyDark : AppTextStyles.body)
                .copyWith(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _precautionController,
            maxLines: 2,
            style: isDark ? AppTextStyles.bodyDark : AppTextStyles.body,
            decoration: InputDecoration(
              hintText: 'Ex: Déconseillé aux femmes enceintes et aux nourrissons. Ne pas dépasser 2 verres/jour.',
              hintStyle: (isDark ? AppTextStyles.bodyDark : AppTextStyles.body)
                  .copyWith(color: isDark ? AppColors.darkTextMuted : AppColors.textMuted),
              filled: true,
              fillColor: isDark ? AppColors.darkSurface : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
                borderSide: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.inputBorder,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
