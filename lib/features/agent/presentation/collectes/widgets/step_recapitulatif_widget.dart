import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_colors.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_dimensions.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_text_styles.dart';
import 'package:ladafura_frontend_flutter/features/agent/providers/agent_providers.dart';

/// Étape 6 du Wizard : Récapitulatif global, vérification de conformité et validation avant soumission.
class StepRecapitulatifWidget extends ConsumerStatefulWidget {
  const StepRecapitulatifWidget({super.key});

  @override
  ConsumerState<StepRecapitulatifWidget> createState() =>
      _StepRecapitulatifWidgetState();
}

class _StepRecapitulatifWidgetState extends ConsumerState<StepRecapitulatifWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(nouvelleCollecteWizardProvider.notifier).fetchRecapitulatif();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final draft = ref.watch(nouvelleCollecteWizardProvider);
    final recap = draft.recapitulatif;

    if (draft.isLoading && recap == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.space24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Génération de la synthèse de collecte...'),
            ],
          ),
        ),
      );
    }

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
                  Icons.assignment_turned_in_rounded,
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
                      'Récapitulatif & Validation',
                      style: (isDark ? AppTextStyles.h3Dark : AppTextStyles.h3)
                          .copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Vérifiez la conformité du dossier avant soumission.',
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

          // 1. Statut de conformité
          Builder(
            builder: (context) {
              final isConforme =
                  draft.isAllStepsValid || (recap?.conformePourSoumission ?? false);
              return Container(
                padding: const EdgeInsets.all(AppDimensions.space16),
                decoration: BoxDecoration(
                  color: isConforme
                      ? (isDark
                          ? AppColors.darkSurfaceVariant
                          : Colors.green.shade50)
                      : (isDark
                          ? AppColors.darkSurfaceVariant
                          : Colors.amber.shade50),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                  border: Border.all(
                    color: isConforme ? Colors.green : Colors.amber.shade700,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isConforme
                          ? Icons.check_circle_rounded
                          : Icons.warning_amber_rounded,
                      color: isConforme ? Colors.green : Colors.amber.shade800,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isConforme
                                ? 'Dossier Conforme pour Soumission'
                                : 'Vérification des étapes requise',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isConforme
                                  ? Colors.green.shade800
                                  : Colors.amber.shade900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isConforme
                                ? 'Tous les critères indispensables sont validés. Vous pouvez soumettre la fiche.'
                                : 'Appuyez sur une section ci-dessous pour compléter ou modifier ses informations.',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: AppDimensions.space16),

          // 2. Synthèse Plante
          _buildSummaryCard(
            context: context,
            isDark: isDark,
            title: 'Spécimen Botanique',
            icon: Icons.eco_rounded,
            isValid: draft.isStepValid(0),
            onEdit: () => ref.read(nouvelleCollecteWizardProvider.notifier).setStep(0),
            content: draft.selectedPlante != null
                ? draft.selectedPlante!.nomScientifique
                : 'Aucune plante sélectionnée',
            subtitle: draft.selectedPlante != null &&
                    draft.selectedPlante!.nomsVernaculaires.isNotEmpty
                ? 'Noms locaux : ${draft.selectedPlante!.nomsVernaculaires.join(", ")}'
                : null,
          ),

          const SizedBox(height: 12),

          // 3. Synthèse Maladies & Symptômes
          _buildSummaryCard(
            context: context,
            isDark: isDark,
            title: 'Pathologies & Symptômes associés',
            icon: Icons.medical_services_rounded,
            isValid: draft.isStepValid(1),
            onEdit: () => ref.read(nouvelleCollecteWizardProvider.notifier).setStep(1),
            content: draft.selectedMaladies.isNotEmpty
                ? draft.selectedMaladies.map((m) => m.nom).join(', ')
                : 'Aucune affection spécifiée',
          ),

          const SizedBox(height: 12),

          // 4. Synthèse Connaissances traditionnelles
          _buildSummaryCard(
            context: context,
            isDark: isDark,
            title: 'Savoir traditionnel & Recette',
            icon: Icons.auto_stories_rounded,
            isValid: draft.isStepValid(2),
            onEdit: () => ref.read(nouvelleCollecteWizardProvider.notifier).setStep(2),
            content: draft.usageRapporte.isNotEmpty
                ? draft.usageRapporte
                : 'Usage non renseigné',
            subtitle: 'Partie : ${draft.partieUtilisee} • Préparation : ${draft.preparation.isNotEmpty ? draft.preparation : "Non précisée"}',
          ),

          const SizedBox(height: 12),

          // 5. Synthèse Source
          _buildSummaryCard(
            context: context,
            isDark: isDark,
            title: 'Praticien / Informateur',
            icon: Icons.person_pin_circle_rounded,
            isValid: draft.isStepValid(3),
            onEdit: () => ref.read(nouvelleCollecteWizardProvider.notifier).setStep(3),
            content: draft.selectedSource != null
                ? draft.selectedSource!.nomComplet
                : 'Aucun praticien associé',
            subtitle: draft.selectedSource?.specialite,
          ),

          const SizedBox(height: 12),

          // 6. Synthèse Localisation & Médias
          _buildSummaryCard(
            context: context,
            isDark: isDark,
            title: 'Territoire & Médias',
            icon: Icons.pin_drop_rounded,
            isValid: draft.isStepValid(4),
            onEdit: () => ref.read(nouvelleCollecteWizardProvider.notifier).setStep(4),
            content: '${draft.region}${draft.cercle.isNotEmpty ? " / ${draft.cercle}" : ""}${draft.commune.isNotEmpty ? " • ${draft.commune}" : ""}${draft.localite.isNotEmpty ? " (${draft.localite})" : ""}',
            subtitle: 'GPS : ${draft.latitude != null ? "Enregistré" : "Non capturé"} • Photo : ${draft.photoFile != null ? "Présente" : "Absente"} • Audio : ${draft.audioFile != null ? "Présent" : "Absent"}',
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required BuildContext context,
    required bool isDark,
    required String title,
    required IconData icon,
    required bool isValid,
    required String content,
    required VoidCallback onEdit,
    String? subtitle,
  }) {
    return InkWell(
      onTap: onEdit,
      borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.space12),
        decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.inputBorder,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isValid ? AppColors.primary : Colors.grey)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isValid ? AppColors.primary : Colors.grey,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                    Icon(
                      isValid
                          ? Icons.check_circle_rounded
                          : Icons.cancel_outlined,
                      size: 16,
                      color: isValid ? Colors.green : Colors.grey,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  content,
                  style: (isDark ? AppTextStyles.bodyDark : AppTextStyles.body)
                      .copyWith(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: (isDark
                            ? AppTextStyles.captionDark
                            : AppTextStyles.caption)
                        .copyWith(fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}
