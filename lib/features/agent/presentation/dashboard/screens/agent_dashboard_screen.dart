import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../../../core/routing/route_names.dart';
import '../../../../../core/theme/theme_provider.dart';
import '../../../../auth/providers/auth_state_provider.dart';

/// Écran principal du Tableau de bord de l'Agent de Collecte Terrain.
class AgentDashboardScreen extends ConsumerWidget {
  const AgentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authStateProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.surface,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        elevation: 0.5,
        title: Text(
          'Espace Agent',
          style: (isDark ? AppTextStyles.h3Dark : AppTextStyles.h3).copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          // Bascule Thème Clair / Sombre
          IconButton(
            tooltip: isDark ? 'Mode clair' : 'Mode sombre',
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_outlined,
              color: isDark ? AppColors.darkAccent : AppColors.primary,
            ),
            onPressed: () {
              ref
                  .read(themeModeProvider.notifier)
                  .toggleTheme(currentIsDark: isDark);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppDimensions.paddingScreenMobile,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bonjour, Awa',
                style: isDark ? AppTextStyles.h2Dark : AppTextStyles.h2,
              ),
              Text(
                'Prête pour votre prochaine collecte ?',
                style: isDark ? AppTextStyles.bodyDark : AppTextStyles.body,
              ),
              const SizedBox(height: AppDimensions.space16),
              Container(
                padding: const EdgeInsets.all(AppDimensions.space16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkAccent : AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Cette semaine",
                      style: isDark
                          ? AppTextStyles.bodyDark
                          : TextStyle(color: AppColors.surface),
                    ),
                    SizedBox(height: AppDimensions.space16),
                    Row(
                      children: [
                        Text("12",
                            style: isDark
                                ? AppTextStyles.h1Dark
                                : TextStyle(
                                    color: AppColors.surface,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                    height: 1.25,
                                  )),
                        SizedBox(width: AppDimensions.space8),
                        Text("fiches collectées",
                            style: isDark
                                ? AppTextStyles.bodyDark
                                : TextStyle(color: AppColors.surface)),
                      ],
                    ),
                    SizedBox(height: AppDimensions.space16),
                    ProgressIndicatorTheme(
                      data: ProgressIndicatorTheme.of(context).copyWith(
                        linearMinHeight: 5,
                        linearTrackColor:
                            isDark ? AppColors.darkSurface : Colors.grey[300],
                        color:
                            isDark ? AppColors.darkAccent : AppColors.primary,
                      ),
                      child: const LinearProgressIndicator(value: 0.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.space20),
              ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isDark ? AppColors.darkPrimary : AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppDimensions.space12,
                      horizontal: AppDimensions.space24,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.add_circle,
                            size: 30,
                          ),
                          SizedBox(width: AppDimensions.space8),
                          Text(
                            'Nouvelle collecte',
                            style: isDark
                                ? AppTextStyles.bodyDark
                                : TextStyle(color: AppColors.surface),
                          ),
                        ],
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: isDark ? AppColors.darkSurface : Colors.white,
                      ),
                    ],
                  )),
              const SizedBox(height: AppDimensions.space20),

              // text
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Votre activité',
                    style: isDark ? AppTextStyles.h4Dark : AppTextStyles.h4,
                  ),
                  Text(
                    'Ce mois-ci',
                    style:
                        (isDark ? AppTextStyles.bodyDark : AppTextStyles.body)
                            .copyWith(color: Colors.grey),
                  ),
                ],
              ),

              SizedBox(height: AppDimensions.space8),

              Row(
                children: [
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        padding: const EdgeInsets.all(AppDimensions.space16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "03",
                              style: (isDark
                                      ? AppTextStyles.h1Dark
                                      : AppTextStyles.h1)
                                  .copyWith(color: AppColors.darkAccent),
                            ),
                            SizedBox(height: AppDimensions.space16),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Brouillons",
                                style: (isDark
                                        ? AppTextStyles.bodyDark
                                        : AppTextStyles.body)
                                    .copyWith(color: Colors.black87),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.space12),
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        padding: const EdgeInsets.all(AppDimensions.space16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "07",
                              style: (isDark
                                      ? AppTextStyles.h1Dark
                                      : AppTextStyles.h1)
                                  .copyWith(color: AppColors.primary),
                            ),
                            SizedBox(height: AppDimensions.space16),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "En validation",
                                style: (isDark
                                        ? AppTextStyles.bodyDark
                                        : AppTextStyles.body)
                                    .copyWith(color: Colors.black87),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.space12),
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        padding: const EdgeInsets.all(AppDimensions.space16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "02",
                              style: (isDark
                                      ? AppTextStyles.h1Dark
                                      : AppTextStyles.h1)
                                  .copyWith(color: AppColors.darkAccent),
                            ),
                            SizedBox(height: AppDimensions.space16),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "A complèter",
                                style: (isDark
                                        ? AppTextStyles.bodyDark
                                        : AppTextStyles.body)
                                    .copyWith(color: Colors.black87),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppDimensions.space16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Collectes récentes',
                    style: isDark ? AppTextStyles.h4Dark : AppTextStyles.h4,
                  ),
                  TextButton(
                    onPressed: () => context.go(RouteNames.agentCollectesPath),
                    child: Text(
                      'Voir tout',
                      style:
                          (isDark ? AppTextStyles.bodyDark : AppTextStyles.body)
                              .copyWith(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.space8),
              _RecentCollectionCard(
                id: 'F-0241',
                details: 'Hier · Koulikoro',
                status: 'En validation',
                statusColor: AppColors.success,
              ),
              const SizedBox(height: AppDimensions.space12),
              _RecentCollectionCard(
                id: 'F-0238',
                details: '12 juin · Ségou',
                status: 'À compléter',
                statusColor: AppColors.warning,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        height: 62,
        padding: EdgeInsets.zero,
        color: isDark ? AppColors.darkSurface : Colors.white,
        surfaceTintColor: isDark ? AppColors.darkSurface : Colors.white,
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
                  onTap: () => context.go(RouteNames.agentDashboardPath),
                ),
              ),
              Expanded(
                child: _AgentNavItem(
                  icon: Icons.description_outlined,
                  label: 'Collectes',
                  isDark: isDark,
                  onTap: () => context.go(RouteNames.agentCollectesPath),
                ),
              ),
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: 42,
                    height: 42,
                    child: FloatingActionButton(
                      tooltip: 'Nouvelle collecte',
                      onPressed: () =>
                          context.go(RouteNames.agentNouvelleCollectePath),
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: const CircleBorder(),
                      child: const Icon(Icons.add, size: 25),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _AgentNavItem(
                  icon: Icons.notifications_none_outlined,
                  label: 'Notif.',
                  isDark: isDark,
                  onTap: () => context.go(RouteNames.agentNotificationsPath),
                ),
              ),
              Expanded(
                child: _AgentNavItem(
                  icon: Icons.person_outline,
                  label: 'Profil',
                  isDark: isDark,
                  onTap: () => context.go(RouteNames.agentProfilPath),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 19, color: color),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 9,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.space12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primaryLight,
            child: Icon(
              Icons.description_outlined,
              size: 18,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppDimensions.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fiche de collecte',
                  style: AppTextStyles.body.copyWith(
                    color: isDark ? Colors.black : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$id · $details',
                  style: AppTextStyles.caption.copyWith(
                    color: isDark ? Colors.black : AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.space8,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
