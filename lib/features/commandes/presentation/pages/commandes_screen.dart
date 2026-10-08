import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/routing/route_names.dart';
import '../../../auth/auth.dart';
import '../../providers/commande_provider.dart';
import '../widgets/commande_summary_card.dart';

/// Page "Mes Commandes" affichant l'historique complet des commandes du citoyen connecté.
class CommandesScreen extends ConsumerStatefulWidget {
  const CommandesScreen({super.key});

  @override
  ConsumerState<CommandesScreen> createState() => _CommandesScreenState();
}

class _CommandesScreenState extends ConsumerState<CommandesScreen> {
  String? _selectedStatutFilter;

  final List<Map<String, String?>> _filtres = [
    {'label': 'Toutes', 'value': null},
    {'label': 'En attente', 'value': 'EN_ATTENTE'},
    {'label': 'Confirmées', 'value': 'CONFIRMEE'},
    {'label': 'En cours', 'value': 'PREPAREE'},
    {'label': 'Livrées', 'value': 'LIVREE'},
    {'label': 'Annulées', 'value': 'ANNULEE'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;
    final auth = ref.watch(authStateProvider);

    if (!auth.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mes Commandes')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('Veuillez vous connecter pour voir vos commandes.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.push(RouteNames.loginPath),
                child: const Text('Se connecter'),
              ),
            ],
          ),
        ),
      );
    }

    final commandesAsync =
        ref.watch(commandesHistoriqueProvider(_selectedStatutFilter));

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: Text(
          'Mes Commandes',
          style: (isDark ? AppTextStyles.h3Dark : AppTextStyles.h3).copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(RouteNames.citizenHomePath);
            }
          },
        ),
      ),
      body: Column(
        children: [
          // Filtres horizontaux par statut
          Container(
            height: 48,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filtres.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final f = _filtres[index];
                final isSelected = _selectedStatutFilter == f['value'];
                return ChoiceChip(
                  label: Text(
                    f['label']!,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.white70 : AppColors.textPrimary),
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: primaryColor,
                  backgroundColor: isDark
                      ? AppColors.darkSurfaceVariant
                      : Colors.grey.shade100,
                  checkmarkColor: Colors.white,
                  showCheckmark: false,
                  side: BorderSide(
                    color: isSelected
                        ? primaryColor
                        : (isDark ? AppColors.darkBorder : Colors.grey.shade300),
                    width: 1,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  onSelected: (selected) {
                    setState(() {
                      _selectedStatutFilter = f['value'];
                    });
                  },
                );
              },
            ),
          ),

          // Liste des commandes
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(commandesHistoriqueProvider(_selectedStatutFilter));
              },
              child: commandesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline_rounded,
                            size: 54, color: Colors.orange),
                        const SizedBox(height: 12),
                        Text(
                          'Erreur de chargement des commandes',
                          style:
                              isDark ? AppTextStyles.h3Dark : AppTextStyles.h3,
                        ),
                        const SizedBox(height: 8),
                        Text('$err', textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => ref.invalidate(
                              commandesHistoriqueProvider(_selectedStatutFilter)),
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (commandes) {
                  if (commandes.isEmpty) {
                    return Center(
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 72,
                              color: isDark ? Colors.grey[700] : Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _selectedStatutFilter == null
                                  ? 'Aucune commande enregistrée'
                                  : 'Aucune commande avec ce statut',
                              style: isDark
                                  ? AppTextStyles.h3Dark
                                  : AppTextStyles.h3,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Vos commandes passées auprès des officines de pharmacopée apparaîtront ici.',
                              style: (isDark
                                      ? AppTextStyles.captionDark
                                      : AppTextStyles.caption)
                                  .copyWith(fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(AppDimensions.space16),
                    itemCount: commandes.length,
                    itemBuilder: (context, index) {
                      final c = commandes[index];
                      return CommandeSummaryCard(
                        commande: c,
                        onTap: () {
                          context.push('/citizen/commandes/detail/${c.id}');
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
