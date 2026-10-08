import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';

/// Timeline visuelle illustrant les étapes d'acheminement d'une commande selon son statut backend.
class CommandeTimelineWidget extends StatelessWidget {
  final String statut;
  final bool isLivraison;

  const CommandeTimelineWidget({
    super.key,
    required this.statut,
    required this.isLivraison,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;

    final steps = _getTimelineSteps(statut, isLivraison);
    final isAnnulee = statut.toUpperCase() == 'ANNULEE';

    if (isAnnulee) {
      return Container(
        padding: const EdgeInsets.all(AppDimensions.space12),
        decoration: BoxDecoration(
          color: Colors.red.withAlpha(20),
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          border: Border.all(color: Colors.red.withAlpha(50)),
        ),
        child: const Row(
          children: [
            Icon(Icons.cancel_rounded, color: Colors.redAccent, size: 24),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Cette commande a été annulée. Les produits ont été réintégrés aux stocks de l\'officine.',
                style: TextStyle(color: Colors.redAccent, fontSize: 13),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space16,
        vertical: AppDimensions.space16,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusModal),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
          width: AppDimensions.cardBorderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 16 : 4),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Suivi d\'avancement',
            style: (isDark ? AppTextStyles.h4Dark : AppTextStyles.h4)
                .copyWith(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(steps.length * 2 - 1, (index) {
              if (index.isOdd) {
                // Trait de liaison
                final stepIndex = index ~/ 2;
                final isPassed = steps[stepIndex + 1].isCompleted;
                return Expanded(
                  child: Container(
                    height: 3,
                    color: isPassed
                        ? Colors.green
                        : (isDark ? Colors.grey[800] : Colors.grey[300]),
                  ),
                );
              } else {
                // Pastille étape
                final step = steps[index ~/ 2];
                return _buildStepIcon(step, primaryColor, isDark);
              }
            }),
          ),
          const SizedBox(height: 12),
          // Libellé de l'étape courante
          Center(
            child: Text(
              _getCurrentStepDescription(statut, isLivraison),
              style: (isDark ? AppTextStyles.bodyDark : AppTextStyles.body)
                  .copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIcon(
      _TimelineStep step, Color primaryColor, bool isDark) {
    if (step.isCompleted) {
      return Container(
        width: 32,
        height: 32,
        decoration: const BoxDecoration(
          color: Colors.green,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, color: Colors.white, size: 18),
      );
    } else if (step.isCurrent) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: primaryColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: primaryColor.withAlpha(80),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(step.icon, color: Colors.white, size: 16),
      );
    } else {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.grey[300],
          shape: BoxShape.circle,
        ),
        child: Icon(
          step.icon,
          color: isDark ? Colors.grey[600] : Colors.grey[500],
          size: 16,
        ),
      );
    }
  }

  List<_TimelineStep> _getTimelineSteps(String statut, bool isLivraison) {
    final s = statut.toUpperCase();

    final is1Done = s != 'EN_ATTENTE';
    final is1Current = s == 'EN_ATTENTE';

    final is2Done = ['PREPAREE', 'EN_LIVRAISON', 'DISPONIBLE_PICKUP', 'LIVREE', 'RETIREE'].contains(s);
    final is2Current = s == 'CONFIRMEE';

    final is3Done = ['EN_LIVRAISON', 'DISPONIBLE_PICKUP', 'LIVREE', 'RETIREE'].contains(s);
    final is3Current = s == 'PREPAREE';

    final is4Done = ['LIVREE', 'RETIREE'].contains(s);
    final is4Current = ['EN_LIVRAISON', 'DISPONIBLE_PICKUP'].contains(s);

    final is5Done = ['LIVREE', 'RETIREE'].contains(s);
    final is5Current = is5Done;

    return [
      _TimelineStep(
        title: 'Reçue',
        icon: Icons.hourglass_top_rounded,
        isCompleted: is1Done,
        isCurrent: is1Current,
      ),
      _TimelineStep(
        title: 'Confirmée',
        icon: Icons.check_rounded,
        isCompleted: is2Done,
        isCurrent: is2Current,
      ),
      _TimelineStep(
        title: 'Préparée',
        icon: Icons.inventory_2_outlined,
        isCompleted: is3Done,
        isCurrent: is3Current,
      ),
      _TimelineStep(
        title: isLivraison ? 'En route' : 'Prête',
        icon: isLivraison ? Icons.delivery_dining_rounded : Icons.storefront_rounded,
        isCompleted: is4Done,
        isCurrent: is4Current,
      ),
      _TimelineStep(
        title: isLivraison ? 'Livrée' : 'Retirée',
        icon: Icons.verified_rounded,
        isCompleted: is5Done,
        isCurrent: is5Current,
      ),
    ];
  }

  String _getCurrentStepDescription(String statut, bool isLivraison) {
    return switch (statut.toUpperCase()) {
      'EN_ATTENTE' => 'Étape 1/5 : En attente de validation par l\'officine',
      'CONFIRMEE' => 'Étape 2/5 : Commande confirmée par la pharmacopée',
      'PREPAREE' => 'Étape 3/5 : Préparation des remèdes terminée',
      'EN_LIVRAISON' => 'Étape 4/5 : Colis confié au livreur vers votre adresse',
      'DISPONIBLE_PICKUP' => 'Étape 4/5 : Disponible au comptoir de l\'officine',
      'LIVREE' => 'Étape 5/5 : Commande livrée avec succès',
      'RETIREE' => 'Étape 5/5 : Commande retirée en officine',
      _ => statut,
    };
  }
}

class _TimelineStep {
  final String title;
  final IconData icon;
  final bool isCompleted;
  final bool isCurrent;

  const _TimelineStep({
    required this.title,
    required this.icon,
    required this.isCompleted,
    required this.isCurrent,
  });
}

