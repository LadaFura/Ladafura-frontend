import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../models/commande_model.dart';
import '../../models/paiement_model.dart';
import '../../providers/commande_provider.dart';
import '../../services/commande_service.dart';
import '../widgets/commande_cash_info_card.dart';
import '../widgets/commande_methode_paiement_tile.dart';
import '../widgets/commande_mobile_money_form.dart';
import '../widgets/commande_paiement_header.dart';

/// Page de Paiement moderne et sécurisée pour régler une commande.
class CommandePaiementScreen extends ConsumerStatefulWidget {
  final CommandeDetailModel commande;

  const CommandePaiementScreen({super.key, required this.commande});

  @override
  ConsumerState<CommandePaiementScreen> createState() =>
      _CommandePaiementScreenState();
}

class _CommandePaiementScreenState
    extends ConsumerState<CommandePaiementScreen> {
  MethodePaiementModel? _selectedMethode;
  String? _selectedOperateur;
  final _telephoneController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _telephoneController.dispose();
    super.dispose();
  }

  void _onConfirmerPaiement() async {
    if (_selectedMethode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un moyen de règlement.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedMethode!.isMobileMoney) {
      if (_telephoneController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez renseigner votre numéro Mobile Money.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }

    setState(() => _isProcessing = true);

    try {
      final service = ref.read(commandeServiceProvider);
      final paiement = await service.payerCommande(
        commandeId: widget.commande.id,
        methode: _selectedMethode!.code,
        operateur: _selectedOperateur,
        telephoneMobileMoney: _telephoneController.text.trim(),
        simulerSucces: true,
      );

      setState(() => _isProcessing = false);

      if (mounted) {
        // Rediriger vers l'écran de Confirmation de Commande
        context.go(
          '/citizen/commandes/confirmation',
          extra: {
            'commande': widget.commande,
            'paiement': paiement,
          },
        );
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Échec du règlement : $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final methodesAsync = ref.watch(methodesPaiementProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.surface,
      appBar: AppBar(
        title: const Text('Règlement de la commande'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: methodesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text('Erreur lors du chargement des moyens de paiement : $err'),
        ),
        data: (methodes) {
          if (_selectedMethode == null && methodes.isNotEmpty) {
            _selectedMethode = methodes.first;
            if (_selectedMethode!.operateurs.isNotEmpty) {
              _selectedOperateur = _selectedMethode!.operateurs.first;
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. En-tête de la commande à payer
                CommandePaiementHeader(
                  commande: widget.commande,
                ),
                const SizedBox(height: AppDimensions.space20),

                // 2. Sélection du moyen de paiement
                Text(
                  'Choisissez votre moyen de paiement',
                  style: (isDark ? AppTextStyles.h3Dark : AppTextStyles.h3)
                      .copyWith(fontSize: 16),
                ),
                const SizedBox(height: 10),
                ...methodes.map((m) => CommandeMethodePaiementTile(
                      methode: m,
                      isSelected: _selectedMethode?.code == m.code,
                      onTap: () {
                        setState(() {
                          _selectedMethode = m;
                          if (m.operateurs.isNotEmpty) {
                            _selectedOperateur = m.operateurs.first;
                          }
                        });
                      },
                    )),

                const SizedBox(height: AppDimensions.space16),

                // 3. Formulaire spécifique Mobile Money
                if (_selectedMethode?.isMobileMoney ?? false) ...[
                  CommandeMobileMoneyForm(
                    operateurs: _selectedMethode?.operateurs ?? [],
                    selectedOperateur: _selectedOperateur,
                    onOperateurSelected: (op) {
                      setState(() => _selectedOperateur = op);
                    },
                    telephoneController: _telephoneController,
                    instructions: _selectedMethode?.instructions,
                  ),
                  const SizedBox(height: AppDimensions.space20),
                ] else if (_selectedMethode?.isCash ?? false) ...[
                  CommandeCashInfoCard(
                    montantTotalFormate: widget.commande.montantTotalFormate,
                  ),
                  const SizedBox(height: AppDimensions.space20),
                ],

                // 4. Bouton de confirmation
                PrimaryButton(
                  label: _selectedMethode?.isCash ?? false
                      ? 'Confirmer le règlement en espèces'
                      : 'Payer ${widget.commande.montantTotalFormate}',
                  icon: Icons.lock_rounded,
                  isLoading: _isProcessing,
                  onPressed: _onConfirmerPaiement,
                ),
                const SizedBox(height: 12),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.security_rounded,
                          size: 14,
                          color: isDark ? Colors.grey[400] : Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        'Transaction sécurisée et chiffrée SSL',
                        style: (isDark
                                ? AppTextStyles.captionDark
                                : AppTextStyles.caption)
                            .copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
