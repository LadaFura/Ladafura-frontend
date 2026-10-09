import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ladafura_frontend_flutter/features/agent/providers/dashboard_provider.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../../../core/routing/route_names.dart';
import '../../../../../core/theme/theme_provider.dart';

/// Retourne la couleur correspondant au statut d'une collecte.
Color getStatusColor(String status) {
  switch (status.toUpperCase()) {
    case 'BROUILLON':
      return Colors.grey;

    case 'EN_ATTENTE':
      return AppColors.darkAccent;

    case 'SOUMISE':
      return AppColors.primary;

    case 'EN_EXAMEN':
      return Colors.orange;

    case 'VALIDEE':
      return AppColors.success;

    case 'REJETEE':
      return AppColors.danger;

    default:
      return AppColors.textSecondary;
  }
}

/// Écran principal du Tableau de bord de l'Agent de Collecte Terrain.
class AgentDashboardScreen extends ConsumerWidget {
  const AgentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final dashboardAsync = ref.watch(dashboardAgentProvider);

    final dashboard = dashboardAsync.value;

    final agent = dashboard?.agent;
    final statistiques = dashboard?.statistiques;
    final notifications = dashboard?.notifications;
    final dernieresCollectes = dashboard?.dernieresCollectes;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.surface,

      // ============================================================
      // APP BAR
      // ============================================================

      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.darkSurface : Colors.white,
        elevation: 0.5,

        title: Text(
          'Espace Agent',
          style: (isDark
                  ? AppTextStyles.h3Dark
                  : AppTextStyles.h3)
              .copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        centerTitle: false,

        actions: [
          // Nombre de notifications non lues
          Stack(
            children: [
              IconButton(
                tooltip: 'Notifications',
                icon: Icon(
                  Icons.notifications_none_outlined,
                  color: isDark
                      ? Colors.white
                      : AppColors.primary,
                ),
                onPressed: () {
                  context.go(
                    RouteNames.agentNotificationsPath,
                  );
                },
              ),
              if ((notifications?.nonLues ?? 0) > 0)
                Positioned(
                  right: 8,
                  top: 7,
                  child: Container(
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.danger,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${notifications?.nonLues ?? 0}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),

          // Bascule thème clair / sombre
          IconButton(
            tooltip:
                isDark ? 'Mode clair' : 'Mode sombre',
            icon: Icon(
              isDark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_outlined,
              color: isDark
                  ? Colors.white
                  : AppColors.primary,
            ),
            onPressed: () {
              ref
                  .read(themeModeProvider.notifier)
                  .toggleTheme(
                    currentIsDark: isDark,
                  );
            },
          ),
        ],
      ),

      // ============================================================
      // BODY
      // ============================================================

      body: SafeArea(
        child: dashboardAsync.when(
          // --------------------------------------------------------
          // CHARGEMENT
          // --------------------------------------------------------

          loading: () {
            return const Center(
              child: CircularProgressIndicator(),
            );
          },

          // --------------------------------------------------------
          // ERREUR
          // --------------------------------------------------------

          error: (error, stackTrace) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 50,
                      color: AppColors.danger,
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      'Impossible de charger le tableau de bord.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      error.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 20),

                    ElevatedButton.icon(
                      onPressed: () {
                        ref.invalidate(
                          dashboardAgentProvider,
                        );
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            );
          },

          // --------------------------------------------------------
          // DONNÉES CHARGÉES
          // --------------------------------------------------------

          data: (dashboard) {
            return SingleChildScrollView(
              padding:
                  AppDimensions.paddingScreenMobile,

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  // =================================================
                  // SALUTATION
                  // =================================================

                  Text(
                    'Bonjour, ${agent?.prenom ?? 'Agent'}',
                    style: isDark
                        ? AppTextStyles.h2Dark
                        : AppTextStyles.h2,
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'Prête pour votre prochaine collecte ?',
                    style: isDark
                        ? AppTextStyles.bodyDark
                        : AppTextStyles.body,
                  ),

                  const SizedBox(
                    height: AppDimensions.space16,
                  ),

                  // =================================================
                  // STATISTIQUE DE LA SEMAINE
                  // =================================================

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(
                      AppDimensions.space16,
                    ),

                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkAccent
                          : AppColors.primary,

                      borderRadius:
                          BorderRadius.circular(12),
                    ),

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [
                        Text(
                          'Cette semaine',
                          style: isDark
                              ? AppTextStyles.bodyDark
                              : const TextStyle(
                                  color:
                                      AppColors.surface,
                                ),
                        ),

                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Text(
                              '${statistiques?.total ?? 0}',
                              style: isDark
                                  ? AppTextStyles.h1Dark
                                  : const TextStyle(
                                      color:
                                          AppColors.surface,
                                      fontSize: 28,
                                      fontWeight:
                                          FontWeight.w700,
                                      height: 1.25,
                                    ),
                            ),

                            const SizedBox(
                              width:
                                  AppDimensions.space8,
                            ),

                            Text(
                              'fiches collectées',
                              style: isDark
                                  ? AppTextStyles.bodyDark
                                  : const TextStyle(
                                      color:
                                          AppColors.surface,
                                    ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Taux de validation
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [
                            Text(
                              'Taux de validation',
                              style: isDark
                                  ? AppTextStyles.bodyDark
                                  : const TextStyle(
                                      color:
                                          AppColors.surface,
                                    ),
                            ),

                            Text(
                              '${statistiques?.tauxValidation.toStringAsFixed(1) ?? '0.0'} %',
                              style: isDark
                                  ? AppTextStyles.bodyDark
                                  : const TextStyle(
                                      color:
                                          AppColors.surface,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        LinearProgressIndicator(
                          value:
                              (statistiques
                                          ?.tauxValidation ??
                                      0) /
                                  100,

                          minHeight: 5,

                          backgroundColor: isDark
                              ? AppColors.darkSurface
                              : Colors.white
                                  .withValues(
                                      alpha: 0.3),

                          color: Colors.white,

                          borderRadius:
                              BorderRadius.circular(10),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: AppDimensions.space20,
                  ),

                  // =================================================
                  // NOUVELLE COLLECTE
                  // =================================================

                  SizedBox(
                    width: double.infinity,

                    child: ElevatedButton(
                      onPressed: () {
                        context.go(
                          RouteNames
                              .agentNouvelleCollectePath,
                        );
                      },

                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor: isDark
                            ? AppColors.darkPrimary
                            : AppColors.primary,

                        foregroundColor:
                            Colors.white,

                        padding:
                            const EdgeInsets.symmetric(
                          vertical:
                              AppDimensions.space12,
                          horizontal:
                              AppDimensions.space24,
                        ),

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(8),
                        ),
                      ),

                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .spaceBetween,

                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.add_circle,
                                size: 30,
                              ),

                              const SizedBox(
                                width:
                                    AppDimensions.space8,
                              ),

                              Text(
                                'Nouvelle collecte',
                                style: isDark
                                    ? AppTextStyles
                                        .bodyDark
                                    : const TextStyle(
                                        color:
                                            Colors.white,
                                      ),
                              ),
                            ],
                          ),

                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: AppDimensions.space20,
                  ),

                  // =================================================
                  // VOTRE ACTIVITÉ
                  // =================================================

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,

                    children: [
                      Text(
                        'Votre activité',
                        style: isDark
                            ? AppTextStyles.h4Dark
                            : AppTextStyles.h4,
                      ),

                      Text(
                        'Ce mois-ci',
                        style: (isDark
                                ? AppTextStyles.bodyDark
                                : AppTextStyles.body)
                            .copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: AppDimensions.space8,
                  ),

                  // =================================================
                  // CARTES STATISTIQUES
                  // =================================================

                  Row(
                    children: [
                      Expanded(
                        child: _ActivityCard(
                          value:
                              statistiques?.brouillons ??
                                  0,
                          label: 'Brouillons',
                          color:
                              AppColors.darkAccent,
                          isDark: isDark,
                        ),
                      ),

                      const SizedBox(
                        width: AppDimensions.space12,
                      ),

                      Expanded(
                        child: _ActivityCard(
                          value:
                              statistiques?.validees ??
                                  0,
                          label: 'Validées',
                          color:
                              AppColors.success,
                          isDark: isDark,
                        ),
                      ),

                      const SizedBox(
                        width: AppDimensions.space12,
                      ),

                      Expanded(
                        child: _ActivityCard(
                          value:
                              statistiques?.enAttente ??
                                  0,
                          label: 'À compléter',
                          color:
                              AppColors.darkAccent,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: AppDimensions.space20,
                  ),

                  // =================================================
                  // COLLECTES RÉCENTES
                  // =================================================

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,

                    children: [
                      Text(
                        'Collectes récentes',
                        style: isDark
                            ? AppTextStyles.h4Dark
                            : AppTextStyles.h4,
                      ),

                      TextButton(
                        onPressed: () {
                          context.go(
                            RouteNames
                                .agentCollectesPath,
                          );
                        },

                        child: Text(
                          'Voir tout',
                          style: (isDark
                                  ? AppTextStyles.bodyDark
                                  : AppTextStyles.body)
                              .copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: AppDimensions.space8,
                  ),

                  // =================================================
                  // LISTE DES COLLECTES
                  // =================================================

                  if (dernieresCollectes != null &&
                      dernieresCollectes.isNotEmpty)

                    ListView.separated(
                      shrinkWrap: true,

                      physics:
                          const NeverScrollableScrollPhysics(),

                      itemCount:
                          dernieresCollectes.length,

                      separatorBuilder:
                          (_, __) => const SizedBox(
                        height: 10,
                      ),

                      itemBuilder:
                          (context, index) {
                        final collecte =
                            dernieresCollectes[index];

                        return _RecentCollectionCard(
                          id: collecte.id.toString(),
                          details: collecte.description,
                          status: collecte.statut,

                          // ⭐ Couleur dynamique
                          statusColor:
                              getStatusColor(
                            collecte.statut,
                          ),
                        );
                      },
                    )

                  else

                    Container(
                      width: double.infinity,

                      padding:
                          const EdgeInsets.all(24),

                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurface
                            : Colors.white,

                        borderRadius:
                            BorderRadius.circular(12),

                        border: Border.all(
                          color: AppColors.border,
                        ),
                      ),

                      child: Column(
                        children: [
                          Icon(
                            Icons.description_outlined,
                            size: 40,
                            color: Colors.grey
                                .withValues(alpha: 0.6),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            'Aucune collecte récente',
                            style: isDark
                                ? AppTextStyles.bodyDark
                                : AppTextStyles.body,
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),

      // ============================================================
      // BOTTOM NAVIGATION
      // ============================================================

      bottomNavigationBar: BottomAppBar(
        height: 62,
        padding: EdgeInsets.zero,

        color:
            isDark ? AppColors.darkSurface : Colors.white,

        surfaceTintColor:
            isDark ? AppColors.darkSurface : Colors.white,

        elevation: 3,

        shape: const CircularNotchedRectangle(),

        notchMargin: 6,

        child: SafeArea(
          top: false,

          child: Row(
            children: [
              Expanded(
                child: _AgentNavItem(
                  icon: Icons.home_outlined,
                  label: 'Accueil',
                  selected: true,
                  isDark: isDark,
                  onTap: () {
                    context.go(
                      RouteNames.agentDashboardPath,
                    );
                  },
                ),
              ),

              Expanded(
                child: _AgentNavItem(
                  icon: Icons.description_outlined,
                  label: 'Collectes',
                  isDark: isDark,
                  onTap: () {
                    context.go(
                      RouteNames.agentCollectesPath,
                    );
                  },
                ),
              ),

              Expanded(
                child: Center(
                  child: SizedBox(
                    width: 42,
                    height: 42,

                    child: FloatingActionButton(
                      tooltip: 'Nouvelle collecte',

                      onPressed: () {
                        context.go(
                          RouteNames
                              .agentNouvelleCollectePath,
                        );
                      },

                      backgroundColor:
                          AppColors.primary,

                      foregroundColor: Colors.white,

                      elevation: 0,

                      shape: const CircleBorder(),

                      child: const Icon(
                        Icons.add,
                        size: 25,
                      ),
                    ),
                  ),
                ),
              ),

              Expanded(
                child: _AgentNavItem(
                  icon:
                      Icons.notifications_none_outlined,
                  label: 'Notif.',
                  isDark: isDark,
                  onTap: () {
                    context.go(
                      RouteNames
                          .agentNotificationsPath,
                    );
                  },
                ),
              ),

              Expanded(
                child: _AgentNavItem(
                  icon: Icons.person_outline,
                  label: 'Profil',
                  isDark: isDark,
                  onTap: () {
                    context.go(
                      RouteNames.agentProfilPath,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================================================================
// CARTE ACTIVITÉ
// ==================================================================

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.value,
    required this.label,
    required this.color,
    required this.isDark,
  });

  final int value;
  final String label;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,

      child: Container(
        padding:
            const EdgeInsets.all(AppDimensions.space16),

        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkSurface
              : Colors.white,

          borderRadius:
              BorderRadius.circular(12),

          border: Border.all(
            color: isDark
                ? AppColors.darkBorder
                : Colors.grey.shade300,
          ),
        ),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            Text(
              value.toString(),

              style: (isDark
                      ? AppTextStyles.h1Dark
                      : AppTextStyles.h1)
                  .copyWith(
                color: color,
              ),
            ),

            const SizedBox(height: 16),

            FittedBox(
              fit: BoxFit.scaleDown,

              alignment: Alignment.centerLeft,

              child: Text(
                label,

                style: (isDark
                        ? AppTextStyles.bodyDark
                        : AppTextStyles.body)
                    .copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================================================================
// BOTTOM NAVIGATION ITEM
// ==================================================================

class _AgentNavItem extends StatelessWidget {
  const _AgentNavItem({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final bool isDark;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? AppColors.primary
        : isDark
            ? AppColors.darkTextSecondary
            : AppColors.textSecondary;

    return Semantics(
      button: true,
      selected: selected,
      label: label,

      child: InkWell(
        onTap: onTap,

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            Icon(
              icon,
              size: 19,
              color: color,
            ),

            const SizedBox(height: 3),

            Text(
              label,

              style: TextStyle(
                color: color,
                fontSize: 9,
                fontWeight: selected
                    ? FontWeight.w700
                    : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================================================================
// CARTE COLLECTE RÉCENTE
// ==================================================================

class _RecentCollectionCard extends StatelessWidget {
  const _RecentCollectionCard({
    required this.id,
    required this.details,
    required this.status,
    required this.statusColor,
  });

  final String id;
  final String details;
  final String status;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    return Container(
      padding:
          const EdgeInsets.all(AppDimensions.space12),

      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurface
            : Colors.white,

        borderRadius:
            BorderRadius.circular(12),

        border: Border.all(
          color: isDark
              ? AppColors.darkBorder
              : AppColors.border,
        ),
      ),

      child: Row(
        children: [
          // --------------------------------------------------------
          // ICÔNE
          // --------------------------------------------------------

          const CircleAvatar(
            radius: 16,

            backgroundColor:
                AppColors.primaryLight,

            child: Icon(
              Icons.description_outlined,
              size: 18,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(
            width: AppDimensions.space12,
          ),

          // --------------------------------------------------------
          // INFORMATIONS
          // --------------------------------------------------------

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  'Fiche de collecte',

                  style: (isDark
                          ? AppTextStyles.bodyDark
                          : AppTextStyles.body)
                      .copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  '$id · $details',

                  style: (isDark
                          ? AppTextStyles.captionDark
                          : AppTextStyles.caption)
                      .copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),

                  overflow:
                      TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // --------------------------------------------------------
          // STATUT DYNAMIQUE
          // --------------------------------------------------------

          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal:
                  AppDimensions.space8,
              vertical: 6,
            ),

            decoration: BoxDecoration(
              color: statusColor.withValues(
                alpha: 0.12,
              ),

              borderRadius:
                  BorderRadius.circular(20),
            ),

            child: Text(
              status,

              style: TextStyle(
                color: statusColor,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),

              maxLines: 1,

              overflow:
                  TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}