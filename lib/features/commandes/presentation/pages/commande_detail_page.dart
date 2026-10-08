import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../models/commande_model.dart';
import '../../providers/commande_provider.dart';
import '../../services/commande_service.dart';
import '../widgets/commande_detail_header_card.dart';
import '../widgets/commande_detail_lignes_list.dart';
import '../widgets/commande_detail_mode_retrait_card.dart';
import '../widgets/commande_detail_pharmacopee_card.dart';
import '../widgets/commande_detail_total_card.dart';
import '../widgets/commande_timeline_widget.dart';

/// Page de Détail d'une Commande avec Timeline, Produits, Mode de Retrait et Annulation éventuelle.
class CommandeDetailPage extends ConsumerWidget {
  final int commandeId;

  const CommandeDetailPage({super.key, required this.commandeId});

  void _annulerCommande(
      BuildContext context, WidgetRef ref, CommandeDetailModel commande) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Annuler la commande ?'),
        content: Text(
            'Êtes-vous sûr de vouloir annuler la commande #${commande.numero} ? Les stocks seront réintégrés.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Non, garder'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                final service = ref.read(commandeServiceProvider);
                await service.annulerCommande(commande.id);
                ref.invalidate(commandeDetailProvider(commande.id));
                ref.invalidate(commandesHistoriqueProvider(null));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Commande annulée avec succès.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur : $e')),
                  );
                }
              }
            },
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final commandeAsync = ref.watch(commandeDetailProvider(commandeId));

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: Text(
          'Détail de la commande',
          style: (isDark ? AppTextStyles.h3Dark : AppTextStyles.h3).copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            tooltip: 'Actualiser',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.invalidate(commandeDetailProvider(commandeId));
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(commandeDetailProvider(commandeId));
          await ref.read(commandeDetailProvider(commandeId).future);
        },
        child: commandeAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => ListView(
            children: [
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.6,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline_rounded,
                            size: 48, color: Colors.orange),
                        const SizedBox(height: 12),
                        Text('Erreur de chargement : $err',
                            textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () =>
                              ref.invalidate(commandeDetailProvider(commandeId)),
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          data: (cmd) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppDimensions.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. En-tête : Numéro, date, statut et paiement
                  CommandeDetailHeaderCard(commande: cmd),
                  const SizedBox(height: AppDimensions.space16),

                  // 2. Timeline moderne
                  CommandeTimelineWidget(
                    statut: cmd.statut,
                    isLivraison: cmd.isLivraison,
                  ),
                  const SizedBox(height: AppDimensions.space16),

                  // 3. Fournisseur / Pharmacopée
                  CommandeDetailPharmacopeeCard(commande: cmd),
                  const SizedBox(height: AppDimensions.space16),

                  // 4. Articles commandés
                  Text(
                    'Articles commandés (${cmd.lignes.length})',
                    style: (isDark ? AppTextStyles.h3Dark : AppTextStyles.h3)
                        .copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  CommandeDetailLignesList(lignes: cmd.lignes),
                  const SizedBox(height: AppDimensions.space16),

                  // 5. Informations d'acheminement / Livraison
                  CommandeDetailModeRetraitCard(commande: cmd),
                  const SizedBox(height: AppDimensions.space16),

                  // 6. Total chiffré
                  CommandeDetailTotalCard(commande: cmd),
                  const SizedBox(height: AppDimensions.space24),

                  // 7. Bouton annulation si disponible
                  if (cmd.annulable) ...[
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.redAccent),
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusButton),
                        ),
                      ),
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text('Annuler cette commande'),
                      onPressed: () => _annulerCommande(context, ref, cmd),
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
