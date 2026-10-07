import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../models/commande_model.dart';
import '../../models/paiement_model.dart';
import '../widgets/commande_confirmation_receipt_card.dart';

/// Page de Confirmation de Commande avec animation légère et récapitulatif.
class CommandeConfirmationScreen extends StatelessWidget {
  final CommandeDetailModel commande;
  final PaiementResponseModel paiement;

  const CommandeConfirmationScreen({
    super.key,
    required this.commande,
    required this.paiement,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.surface,
      appBar: AppBar(
        title: const Text('Confirmation de commande'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.space24),
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Animation / Icône de succès
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: child,
                  );
                },
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.green.withAlpha(25),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: Colors.green,
                      size: 64,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.space20),
              Text(
                'Commande confirmée !',
                style: (isDark ? AppTextStyles.h1Dark : AppTextStyles.h1)
                    .copyWith(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Merci pour votre confiance. Votre commande a été transmise à l\'officine.',
                style: (isDark ? AppTextStyles.bodyDark : AppTextStyles.body)
                    .copyWith(
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppDimensions.space24),

              // Carte récapitulative
              CommandeConfirmationReceiptCard(
                commande: commande,
                paiement: paiement,
              ),

              const SizedBox(height: AppDimensions.space32),

              // Boutons d'action
              PrimaryButton(
                label: 'Voir ma commande',
                icon: Icons.receipt_long_rounded,
                onPressed: () {
                  context.push(
                    '/citizen/commandes/detail/${commande.id}',
                  );
                },
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
                  ),
                ),
                icon: const Icon(Icons.home_rounded),
                label: const Text('Retour à l\'accueil'),
                onPressed: () => context.go(RouteNames.citizenHomePath),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

