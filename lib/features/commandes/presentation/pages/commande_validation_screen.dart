import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../auth/auth.dart';
import '../../providers/commande_provider.dart';
import '../widgets/commande_contact_phone_card.dart';
import '../widgets/commande_livraison_form.dart';
import '../widgets/commande_mode_retrait_selector.dart';
import '../widgets/commande_pharmacopee_header.dart';
import '../widgets/commande_pickup_info_card.dart';
import '../widgets/commande_recapitulatif_card.dart';

/// Page de Validation de Commande & Choix du Mode de Retrait.
class CommandeValidationScreen extends ConsumerStatefulWidget {
  const CommandeValidationScreen({super.key});

  @override
  ConsumerState<CommandeValidationScreen> createState() =>
      _CommandeValidationScreenState();
}

class _CommandeValidationScreenState
    extends ConsumerState<CommandeValidationScreen> {
  final _adresseController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _notesController = TextEditingController();

  String? _adresseError;
  String? _telephoneError;

  @override
  void initState() {
    super.initState();
    final authUser = ref.read(authStateProvider).user;
    if (authUser?.telephone != null && authUser!.telephone!.trim().isNotEmpty) {
      _telephoneController.text = authUser.telephone!.trim();
    }
  }

  @override
  void dispose() {
    _adresseController.dispose();
    _telephoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onPasserCommande() async {
    setState(() {
      _adresseError = null;
      _telephoneError = null;
    });

    final checkout = ref.read(checkoutProvider);
    final notifier = ref.read(checkoutProvider.notifier);

    if (checkout.selectedModeRetrait == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un mode de mise à disposition.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // 1. Validation stricte du numéro de téléphone obligatoire
    final telephone = _telephoneController.text.trim();
    if (telephone.isEmpty) {
      setState(() {
        _telephoneError = 'Le numéro de téléphone est obligatoire.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Veuillez renseigner un numéro de téléphone de contact obligatoire.',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // 2. Validation de l'adresse de livraison si mode Livraison
    final adresse = _adresseController.text.trim();
    if (checkout.selectedModeRetrait!.isLivraison && adresse.isEmpty) {
      setState(() {
        _adresseError = 'L\'adresse de livraison complète est obligatoire.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('L\'adresse de livraison complète est obligatoire.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Mise à jour de l'adresse et des notes avec inclusion du contact
    final fullAdresse = checkout.selectedModeRetrait!.isLivraison
        ? '$adresse (Contact: $telephone)'
        : null;
    final baseNotes = _notesController.text.trim();
    final fullNotes =
        'Contact : $telephone${baseNotes.isNotEmpty ? ' | $baseNotes' : ''}';

    notifier.updateAdresseLivraison(fullAdresse ?? '');
    notifier.updateNotes(fullNotes);

    final commande = await notifier.passerCommande();
    if (commande != null && mounted) {
      context.push(
        '/citizen/commandes/paiement',
        extra: commande,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final checkout = ref.watch(checkoutProvider);
    final notifier = ref.read(checkoutProvider.notifier);

    final pharmacopeeId = checkout.pharmacopeeId;

    if (pharmacopeeId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Validation de commande')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Aucune pharmacopée sélectionnée pour cette commande.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Retourner au panier'),
              ),
            ],
          ),
        ),
      );
    }

    final optionsAsync =
        ref.watch(pharmacopeeRetraitOptionsProvider(pharmacopeeId));

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.surface,
      appBar: AppBar(
        title: const Text('Validation de commande'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: optionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text('Erreur de chargement des options : $err'),
          ),
        ),
        data: (retraitOptions) {
          // Filtrer uniquement les modes de mise à disposition réellement actifs
          final activeOptions = retraitOptions.options.where((o) => o.actif).toList();

          // Si aucun mode n'est sélectionné, initialiser avec le premier mode actif
          if (checkout.selectedModeRetrait == null && activeOptions.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              notifier.selectModeRetrait(activeOptions.first);
            });
          }

          final recap = checkout.recapitulatif;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Pharmacopée concernée
                CommandePharmacopeeHeader(
                  nomOfficine: retraitOptions.nomPharmacopee,
                ),
                const SizedBox(height: AppDimensions.space16),

                // 2. Choix du mode de retrait
                Text(
                  'Mode de mise à disposition',
                  style: (isDark ? AppTextStyles.h3Dark : AppTextStyles.h3)
                      .copyWith(fontSize: 16),
                ),
                const SizedBox(height: 8),
                if (activeOptions.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.space16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                      border: Border.all(color: Colors.amber.shade300),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded,
                            color: Colors.amber, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Cette pharmacopée n\'a actuellement aucun mode de retrait ou livraison actif.',
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.amber.shade900,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  CommandeModeRetraitSelector(
                    options: activeOptions,
                    selected: checkout.selectedModeRetrait,
                    onSelected: (opt) => notifier.selectModeRetrait(opt),
                  ),
                const SizedBox(height: AppDimensions.space16),

                // 3. Formulaire de livraison conditionnel ou infos retrait
                if (checkout.selectedModeRetrait?.isLivraison ?? false) ...[
                  CommandeLivraisonForm(
                    adresseController: _adresseController,
                    telephoneController: _telephoneController,
                    notesController: _notesController,
                    adresseError: _adresseError,
                    telephoneError: _telephoneError,
                  ),
                  const SizedBox(height: AppDimensions.space16),
                ] else if (checkout.selectedModeRetrait?.isPickup ?? false) ...[
                  CommandePickupInfoCard(
                    adresseOfficine: retraitOptions.adressePharmacopee,
                  ),
                  const SizedBox(height: AppDimensions.space16),
                  CommandeContactPhoneCard(
                    telephoneController: _telephoneController,
                    telephoneError: _telephoneError,
                  ),
                  const SizedBox(height: AppDimensions.space16),
                ],

                // 4. Récapitulatif chiffré des articles et frais
                Text(
                  'Récapitulatif de la commande',
                  style: (isDark ? AppTextStyles.h3Dark : AppTextStyles.h3)
                      .copyWith(fontSize: 16),
                ),
                const SizedBox(height: 8),
                CommandeRecapitulatifCard(
                  recap: recap,
                  isLoading: checkout.isLoading,
                ),

                if (checkout.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withAlpha(50)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            checkout.errorMessage!,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: AppDimensions.space24),

                // 5. Bouton vers le Paiement
                PrimaryButton(
                  label: 'Procéder au paiement',
                  icon: Icons.payment_rounded,
                  isLoading: checkout.isLoading,
                  onPressed: _onPasserCommande,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
