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
          draft.collecteId != null
              ? 'Modifier la Collecte #${draft.collecteId}'
              : 'Nouvelle Collecte',
          style: (isDark ? AppTextStyles.h3Dark : AppTextStyles.h3).copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Bouton Sauvegarder Brouillon
          IconButton(
            tooltip: 'Enregistrer le brouillon',
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
            icon: draft.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    Icons.save_outlined,
                    size: 22,
                    color: isDark ? AppColors.darkPrimary : AppColors.primary,
                  ),
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
                  final isDone = index < draft.currentStep && draft.isStepValid(index);
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (index <= draft.currentStep) {
                          notifier.setStep(index);
                          return;
                        }
                        // Empêcher de sauter une étape non remplie
                        for (int s = 0; s < index; s++) {
                          if (!draft.isStepValid(s)) {
                            final msg = draft.stepValidationMessage(s) ??
                                'Veuillez compléter cette étape avant de continuer.';
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(
                                  content: Text(msg),
                                  backgroundColor: AppColors.info,
                                ),
                              );
                            notifier.setStep(s);
                            return;
                          }
                        }
                        notifier.setStep(index);
                      },
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

            // Bandeau d'indication si l'étape courante n'est pas encore complète
            if (!draft.isStepValid(draft.currentStep))
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.space16,
                  vertical: 8,
                ),
                color: isDark
                    ? AppColors.darkPrimaryContainer.withValues(alpha: 0.45)
                    : AppColors.primaryLight,
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 16,
                      color: isDark ? AppColors.darkPrimary : AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        draft.stepValidationMessage(draft.currentStep) ?? '',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ],
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
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (draft.currentStep > 0) ...[
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: draft.isLoading
                              ? null
                              : () => notifier.setStep(draft.currentStep - 1),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            foregroundColor: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
                            side: BorderSide(
                              color: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.inputBorder,
                            ),
                          ),
                          icon: const Icon(Icons.arrow_back_rounded, size: 16),
                          label: const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Précédent',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    flex: (draft.currentStep > 0 &&
                            draft.currentStep == _stepTitles.length - 1)
                        ? 2
                        : 1,
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: (draft.isLoading ||
                                !draft.isStepValid(draft.currentStep))
                            ? null
                            : () async {
                                if (draft.currentStep < _stepTitles.length - 1) {
                                  // Sauvegarde automatique transparente de l'étape sur le serveur
                                  notifier.saveDraft();
                                  notifier.setStep(draft.currentStep + 1);
                                } else {
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
                                  } else if (!success && context.mounted) {
                                    final err = ref
                                            .read(nouvelleCollecteWizardProvider)
                                            .errorMessage ??
                                        'Impossible de soumettre la collecte.';
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(err),
                                        backgroundColor: AppColors.danger,
                                      ),
                                    );
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              draft.currentStep == _stepTitles.length - 1
                                  ? Colors.green
                                  : AppColors.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: isDark
                              ? AppColors.darkSurfaceVariant
                              : Colors.grey.shade300,
                          disabledForegroundColor: isDark
                              ? AppColors.darkTextMuted
                              : Colors.grey.shade600,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        draft.currentStep ==
                                                _stepTitles.length - 1
                                            ? 'Soumettre pour validation'
                                            : (draft.currentStep == 0
                                                ? 'Étape suivante'
                                                : 'Suivant'),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (draft.currentStep <
                                      _stepTitles.length - 1) ...[
                                    const SizedBox(width: 6),
                                    const Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 16,
                                    ),
                                  ],
                                ],
                              ),
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
