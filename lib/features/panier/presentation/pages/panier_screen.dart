import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../providers/panier_provider.dart';
import '../widgets/panier_item_card.dart';

/// Page Panier (Navigation principale Citoyen).
class PanierScreen extends ConsumerWidget {
  const PanierScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final items = ref.watch(panierProvider);
    final notifier = ref.read(panierProvider.notifier);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.surface,
      appBar: AppBar(
        title: const Text('Mon Panier'),
        automaticallyImplyLeading:
            false, // Pas d'icône retour sur page principale
        actions: [
          if (items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Vider le panier',
              onPressed: () => notifier.vider(),
            ),
        ],
      ),
      body: items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 72,
                    color: (isDark ? AppColors.darkAccent : AppColors.primary)
                        .withAlpha(80),
                  ),
                  const SizedBox(height: AppDimensions.space16),
                  Text(
                    'Votre panier est vide',
                    style: isDark ? AppTextStyles.h3Dark : AppTextStyles.h3,
                  ),
                  const SizedBox(height: AppDimensions.space8),
                  Text(
                    'Ajoutez des produits de la pharmacopée malienne pour commander.',
                    style: (isDark
                            ? AppTextStyles.captionDark
                            : AppTextStyles.caption)
                        .copyWith(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppDimensions.space16),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return PanierItemCard(
                        item: item,
                        onQuantityChanged: (qty) =>
                            notifier.modifierQuantite(item.produit.id, qty),
                        onRemove: () =>
                            notifier.retirerProduit(item.produit.id),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(AppDimensions.space16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(15),
                        blurRadius: 10,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total estimé :',
                              style: isDark
                                  ? AppTextStyles.h3Dark
                                  : AppTextStyles.h3,
                            ),
                            Text(
                              '${notifier.montantTotal.toStringAsFixed(0)} FCFA',
                              style: (isDark
                                      ? AppTextStyles.h2Dark
                                      : AppTextStyles.h2)
                                  .copyWith(
                                color: isDark
                                    ? AppColors.darkAccent
                                    : AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.space12),
                        PrimaryButton(
                          label: 'Passer la commande',
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Fonctionnalité de commande en cours de déploiement'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
