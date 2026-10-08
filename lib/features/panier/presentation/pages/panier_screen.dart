import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../auth/auth.dart';
import '../../../commandes/presentation/widgets/pharmacopee_selection_modal.dart';
import '../../../commandes/providers/commande_provider.dart';
import '../../../plantes/providers/plante_provider.dart';
import '../../../../shared/widgets/feedback/app_confirmation_dialog.dart';
import '../../providers/panier_provider.dart';
import '../widgets/panier_bottom_bar.dart';
import '../widgets/panier_item_card.dart';

/// Page Panier d'achat LADAFURA moderne et dynamique connectée à l'API.
class PanierScreen extends ConsumerStatefulWidget {
  const PanierScreen({super.key});

  @override
  ConsumerState<PanierScreen> createState() => _PanierScreenState();
}

class _PanierScreenState extends ConsumerState<PanierScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(panierStateProvider.notifier).chargerPanier();
    });
  }

  bool _isCheckingOut = false;

  void _onValiderCommande() async {
    final authState = ref.read(authStateProvider);
    if (!authState.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez vous connecter pour valider votre panier.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.push(RouteNames.loginPath);
      return;
    }

    final panierState = ref.read(panierStateProvider);
    if (panierState.estVide || _isCheckingOut) return;

    // 1. Si la pharmacopée est déjà connue grâce au contexte où les produits ont été sélectionnés :
    final checkout = ref.read(checkoutProvider);
    final knownPharmacopeeId =
        checkout.pharmacopeeId ?? panierState.pharmacopeeId;
    final knownPharmacopeeNom =
        checkout.nomPharmacopee ?? panierState.nomPharmacopee;

    if (knownPharmacopeeId != null && knownPharmacopeeNom != null) {
      ref.read(checkoutProvider.notifier).initCheckout(
            pharmacopeeId: knownPharmacopeeId,
            nomPharmacopee: knownPharmacopeeNom,
          );
      context.push(RouteNames.citizenCommandeValidationPath);
      return;
    }

    // 2. Sinon (fallback si le produit a été ajouté hors du catalogue d'une pharmacopée)
    final premierProduitId = panierState.lignes.first.produitId;
    final premierProduitNom = panierState.lignes.first.nomProduit;

    setState(() => _isCheckingOut = true);

    try {
      final planteService = ref.read(planteServiceProvider);
      final produitDetail =
          await planteService.getProduitDetail(premierProduitId);

      if (!mounted) return;
      setState(() => _isCheckingOut = false);

      final offres = produitDetail?.offresPharmacopees ?? [];

      if (offres.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Aucune pharmacopée agréée ne propose actuellement ce remède.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      if (offres.length == 1) {
        // Une seule officine disponible, sélection directe automatique
        final offre = offres.first;
        ref.read(checkoutProvider.notifier).initCheckout(
              pharmacopeeId: offre.pharmacopeeId,
              nomPharmacopee: offre.nomPharmacopee,
            );
        ref.read(panierStateProvider.notifier).setPharmacopeeSource(
              offre.pharmacopeeId,
              offre.nomPharmacopee,
            );
        context.push(RouteNames.citizenCommandeValidationPath);
      } else {
        // Plusieurs officines proposent ce produit : choix par l'utilisateur
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (modalContext) => PharmacopeeSelectionModal(
            nomProduit: premierProduitNom,
            offres: offres
                .map((o) => {
                      'pharmacopeeId': o.pharmacopeeId,
                      'nomPharmacopee': o.nomPharmacopee,
                      'prix': o.prix,
                      'telephone': o.telephone,
                      'commune': o.commune,
                      'quantiteStock': o.quantiteStock,
                    })
                .toList(),
            onPharmacopeeSelected: (id, nom) {
              ref.read(checkoutProvider.notifier).initCheckout(
                    pharmacopeeId: id,
                    nomPharmacopee: nom,
                  );
              ref.read(panierStateProvider.notifier).setPharmacopeeSource(
                    id,
                    nom,
                  );
              context.push(RouteNames.citizenCommandeValidationPath);
            },
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCheckingOut = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur de préparation : $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;
    final panierState = ref.watch(panierStateProvider);
    final notifier = ref.read(panierStateProvider.notifier);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.surface,
      appBar: AppBar(
        title: const Text('Mon Panier'),
        automaticallyImplyLeading: false,
        leading: context.canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => context.pop(),
              )
            : null,
        actions: [
          if (!panierState.estVide)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Vider le panier',
              onPressed: () => _confirmViderPanier(context, notifier),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => notifier.chargerPanier(),
        child: _buildBody(context, panierState, notifier, isDark, primaryColor),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    PanierState panierState,
    PanierNotifier notifier,
    bool isDark,
    Color primaryColor,
  ) {
    if (panierState.isLoading && panierState.panier.lignes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (panierState.errorMessage != null &&
        panierState.panier.lignes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.space24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 64, color: Colors.orange),
              const SizedBox(height: AppDimensions.space16),
              Text(
                'Impossible de charger votre panier',
                style: isDark ? AppTextStyles.h3Dark : AppTextStyles.h3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.space8),
              Text(
                panierState.errorMessage!,
                style: (isDark
                        ? AppTextStyles.captionDark
                        : AppTextStyles.caption)
                    .copyWith(fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.space20),
              ElevatedButton.icon(
                onPressed: () => notifier.chargerPanier(),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    if (panierState.estVide) {
      return Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppDimensions.space32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: primaryColor.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.shopping_bag_outlined,
                  size: 54,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: AppDimensions.space24),
              Text(
                'Votre panier est vide',
                style: isDark ? AppTextStyles.h2Dark : AppTextStyles.h2,
              ),
              const SizedBox(height: AppDimensions.space8),
              Text(
                'Explorez notre catalogue de plantes et remèdes traditionnels maliens pour débuter votre commande.',
                style: (isDark
                        ? AppTextStyles.captionDark
                        : AppTextStyles.caption)
                    .copyWith(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.space24),
              PrimaryButton(
                label: 'Découvrir la pharmacopée',
                icon: Icons.search_rounded,
                onPressed: () => context.go(RouteNames.citizenRecherchePath),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // En-tête informatif du panier
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: isDark ? AppColors.darkSurface : Colors.grey[100],
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: primaryColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${panierState.nombreArticles} article(s) dans votre panier',
                  style: (isDark
                          ? AppTextStyles.captionDark
                          : AppTextStyles.caption)
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),

        // Liste des articles avec séparateurs fins
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.space16,
              vertical: AppDimensions.space12,
            ),
            itemCount: panierState.lignes.length,
            separatorBuilder: (_, __) => Divider(
              height: AppDimensions.space24,
              thickness: 0.8,
              color: isDark ? AppColors.darkBorder : const Color(0xFFF1F5F9),
            ),
            itemBuilder: (context, index) {
              final ligne = panierState.lignes[index];
              return PanierItemCard(
                ligne: ligne,
                isUpdating: panierState.updatingLigneId == ligne.ligneId,
                onQuantityChanged: (qty) =>
                    notifier.modifierQuantite(ligne.ligneId, qty),
                onRemove: () => notifier.supprimerLigne(ligne.ligneId),
              );
            },
          ),
        ),

        // Récapitulatif et passage de commande fixé en bas
        PanierBottomBar(
          montantTotalFormate: panierState.panier.montantTotalFormate,
          isLoading: panierState.isLoading || _isCheckingOut,
          onValider: _onValiderCommande,
        ),
      ],
    );
  }

  void _confirmViderPanier(BuildContext context, PanierNotifier notifier) {
    AppConfirmationDialog.show(
      context,
      title: 'Vider le panier ?',
      message:
          'Êtes-vous sûr de vouloir supprimer tous les articles présents dans votre panier ?',
      confirmLabel: 'Vider le panier',
      cancelLabel: 'Annuler',
      icon: Icons.delete_sweep_outlined,
      isDestructive: true,
      onConfirm: () {
        notifier.vider();
      },
    );
  }
}
