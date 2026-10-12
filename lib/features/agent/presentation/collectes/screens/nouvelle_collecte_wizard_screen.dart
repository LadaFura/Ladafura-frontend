import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_colors.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_dimensions.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_text_styles.dart';
import 'package:ladafura_frontend_flutter/features/agent/providers/agent_providers.dart';
import '../widgets/step_plante_selection_widget.dart';
import '../widgets/step_maladies_symptomes_widget.dart';
import '../widgets/step_connaissance_traditionnelle_widget.dart';
import '../widgets/step_source_terrain_widget.dart';
import '../widgets/step_localisation_medias_widget.dart';
import '../widgets/step_recapitulatif_widget.dart';

/// Écran principal du parcours "Nouvelle Collecte Terrain" sous forme de Stepper/Wizard à 6 étapes.
class NouvelleCollecteWizardScreen extends ConsumerStatefulWidget {
  const NouvelleCollecteWizardScreen({super.key});

  @override
  ConsumerState<NouvelleCollecteWizardScreen> createState() =>
      _NouvelleCollecteWizardScreenState();
}

class _NouvelleCollecteWizardScreenState
    extends ConsumerState<NouvelleCollecteWizardScreen> {
  final List<String> _stepTitles = [
    'Plante',
    'Maladies',
    'Savoirs',
    'Source',
    'Localisation',
    'Validation',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final draft = ref.watch(nouvelleCollecteWizardProvider);
    final notifier = ref.read(nouvelleCollecteWizardProvider.notifier);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.surface,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () {
            if (draft.currentStep > 0) {
              notifier.setStep(draft.currentStep - 1);
            } else {
              context.pop();
            }
          },
        ),
        title: Text(
          'Nouvelle Collecte',
          style: (isDark ? AppTextStyles.h3Dark : AppTextStyles.h3).copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Bouton Sauvegarder Brouillon
          TextButton.icon(
            onPressed: draft.isLoading
                ? null
                : () async {
                    final ok = await notifier.saveDraft();
                    if (ok && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Brouillon sauvegardé avec succès.'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
            icon: const Icon(Icons.save_outlined, size: 18),
            label: const Text('Brouillon'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Indicateur d'étapes (Stepper horizontal)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.space16,
                vertical: AppDimensions.space12,
              ),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.inputBorder,
                  ),
                ),
              ),
              child: Row(
                children: List.generate(_stepTitles.length, (index) {
                  final isCurrent = index == draft.currentStep;
                  final isDone = index < draft.currentStep;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => notifier.setStep(index),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              if (index > 0)
                                Expanded(
                                  child: Container(
                                    height: 2,
                                    color: isDone
                                        ? AppColors.primary
                                        : (isDark
                                            ? AppColors.darkBorder
                                            : Colors.grey.shade300),
                                  ),
                                ),
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isCurrent
                                      ? AppColors.primary
                                      : isDone
                                          ? AppColors.primary
                                          : (isDark
                                              ? AppColors.darkSurfaceVariant
                                              : Colors.grey.shade200),
                                ),
                                child: Center(
                                  child: isDone
                                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                                      : Text(
                                          '${index + 1}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: isCurrent
                                                ? Colors.white
                                                : (isDark
                                                    ? AppColors.darkTextSecondary
                                                    : Colors.grey.shade700),
                                          ),
                                        ),
                                ),
                              ),
                              if (index < _stepTitles.length - 1)
                                Expanded(
                                  child: Container(
                                    height: 2,
                                    color: isDone
                                        ? AppColors.primary
                                        : (isDark
                                            ? AppColors.darkBorder
                                            : Colors.grey.shade300),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _stepTitles[index],
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight:
                                  isCurrent ? FontWeight.bold : FontWeight.normal,
                              color: isCurrent
                                  ? AppColors.primary
                                  : (isDark
                                      ? AppColors.darkTextMuted
                                      : AppColors.textMuted),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Contenu de l'étape courante
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.space16),
                child: _buildStepBody(draft.currentStep),
              ),
            ),

            // Barre de navigation inférieure (Précédent / Suivant / Soumettre)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.space20,
                vertical: AppDimensions.space12,
              ),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.inputBorder,
                  ),
                ),
              ),
              child: Row(
                children: [
                  if (draft.currentStep > 0) ...[
                    OutlinedButton(
                      onPressed: draft.isLoading
                          ? null
                          : () => notifier.setStep(draft.currentStep - 1),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      child: const Text('Précédent'),
                    ),
                    const SizedBox(width: AppDimensions.space12),
                  ],
                  Expanded(
                    child: ElevatedButton(
                      onPressed: draft.isLoading
                          ? null
                          : () async {
                              if (draft.currentStep < _stepTitles.length - 1) {
                                // Passage à l'étape suivante avec auto-save
                                notifier.setStep(draft.currentStep + 1);
                              } else {
                                // Étape finale : Soumission
                                final success = await notifier.soumettre();
                                if (success && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Fiche de collecte transmise avec succès pour validation !',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  notifier.reset();
                                  context.pop();
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: draft.currentStep == _stepTitles.length - 1
                            ? Colors.green
                            : AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: draft.isLoading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              draft.currentStep == _stepTitles.length - 1
                                  ? 'Soumettre pour validation'
                                  : 'Étape suivante',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepBody(int step) {
    switch (step) {
      case 0:
        return const StepPlanteSelectionWidget();
      case 1:
        return const StepMaladiesSymptomesWidget();
      case 2:
        return const StepConnaissanceTraditionnelleWidget();
      case 3:
        return const StepSourceTerrainWidget();
      case 4:
        return const StepLocalisationMediasWidget();
      case 5:
        return const StepRecapitulatifWidget();
      default:
        return const SizedBox.shrink();
    }
  }
}
