import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/feedback/app_loading_indicator.dart';
import '../../providers/plante_provider.dart';
import '../widgets/connaissances_traditionnelles_card.dart';
import '../widgets/etudes_scientifiques_card.dart';
import '../widgets/plante_header_card.dart';

class PlanteDetailPage extends ConsumerWidget {
  final int planteId;

  const PlanteDetailPage({
    super.key,
    required this.planteId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final planteAsync = ref.watch(planteDetailProvider(planteId));

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.surface,
      appBar: AppBar(
        title: const Text('Fiche Botanique & Santé'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              Navigator.of(context).maybePop();
            }
          },
        ),
      ),
      body: planteAsync.when(
        loading: () => const Center(child: AppLoadingIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.space24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded,
                    color: AppColors.danger, size: 48),
                const SizedBox(height: AppDimensions.space12),
                Text(
                  'Impossible de charger la fiche de cette plante',
                  style: isDark ? AppTextStyles.h3Dark : AppTextStyles.h3,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.space16),
                ElevatedButton.icon(
                  onPressed: () => ref.refresh(planteDetailProvider(planteId)),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        ),
        data: (plante) {
          if (plante == null) {
            return const Center(child: Text('Plante introuvable'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header (Photo, Nom scientifique, Avertissement)
                PlanteHeaderCard(plante: plante),

                const SizedBox(height: AppDimensions.space24),

                // 2. Connaissances traditionnelles
                ConnaissancesTraditionnellesCard(
                  connaissances: plante.connaissancesTraditionnelles,
                ),

                const SizedBox(height: AppDimensions.space24),

                // 3. Études scientifiques
                EtudesScientifiquesCard(
                  etudes: plante.etudesScientifiques,
                ),

                const SizedBox(height: AppDimensions.space32),
              ],
            ),
          );
        },
      ),
    );
  }
}
