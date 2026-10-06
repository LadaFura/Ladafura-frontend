import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/feedback/app_loading_indicator.dart';
import '../../providers/commande_provider.dart';
import '../widgets/commande_card.dart';

/// Page d'historique des commandes (Page secondaire avec bouton retour).
class CommandesScreen extends ConsumerWidget {
  const CommandesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final commandesAsync = ref.watch(mesCommandesProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.surface,
      appBar: AppBar(
        title: const Text('Mes Commandes'),
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
      body: commandesAsync.when(
        loading: () => const Center(child: AppLoadingIndicator()),
        error: (err, _) => Center(
          child: Text(
            'Erreur lors du chargement des commandes',
            style: isDark ? AppTextStyles.bodyDark : AppTextStyles.body,
          ),
        ),
        data: (commandes) {
          if (commandes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(height: AppDimensions.space16),
                  Text(
                    'Aucune commande enregistrée',
                    style: isDark ? AppTextStyles.h3Dark : AppTextStyles.h3,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppDimensions.space16),
            itemCount: commandes.length,
            itemBuilder: (context, index) {
              return CommandeCard(commande: commandes[index]);
            },
          );
        },
      ),
    );
  }
}
