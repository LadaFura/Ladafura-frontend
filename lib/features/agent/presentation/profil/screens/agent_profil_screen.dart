import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../../../core/routing/route_names.dart';
import '../../../../../core/theme/theme_provider.dart';
import '../../../../auth/providers/auth_state_provider.dart';
import '../../../../profil/presentation/widgets/profil_logout_dialog.dart';
import '../../../models/agent_profile_model.dart';
import '../../../providers/agent_providers.dart';
import '../../../providers/dashboard_provider.dart';

/// Écran de Profil et Paramètres dédié à l'Agent de Collecte Terrain.
class AgentProfilScreen extends ConsumerWidget {
  const AgentProfilScreen({super.key});

  String _formatDate(DateTime? date) {
    if (date == null) return 'Non renseignée';
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m/${date.year}';
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final shouldLogout = await ProfilLogoutDialog.show(context);
    if (shouldLogout == true && context.mounted) {
      await ref.read(authStateProvider.notifier).logout();
      if (context.mounted) {
        context.go(RouteNames.loginPath);
      }
    }
  }

  void _showEditProfileSheet(
    BuildContext context,
    WidgetRef ref,
    AgentProfileModel profile,
  ) {
    final prenomCtrl = TextEditingController(text: profile.prenom);
    final nomCtrl = TextEditingController(text: profile.nom);
    final telCtrl = TextEditingController(text: profile.telephone ?? '');
    final zoneCtrl = TextEditingController(
      text: profile.zoneCouverture == 'Zone non renseignée'
          ? ''
          : profile.zoneCouverture,
    );
    bool isSaving = false;
    String? errorMsg;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        final isDark = Theme.of(sheetCtx).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Modifier mes coordonnées',
                          style: (isDark
                                  ? AppTextStyles.h3Dark
                                  : AppTextStyles.h3)
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          onPressed:
                              isSaving ? null : () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (errorMsg != null) ...[
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          errorMsg!,
                          style: const TextStyle(
                            color: AppColors.danger,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: prenomCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Prénom *',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: nomCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Nom *',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: telCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Téléphone professionnel',
                        hintText: '+223 70 00 00 00',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: zoneCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Zone de couverture terrain',
                        hintText: 'Ex: Région de Sikasso - Cercle de Koutiala',
                        prefixIcon: Icon(Icons.map_outlined),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: isSaving
                          ? null
                          : () async {
                              final prenom = prenomCtrl.text.trim();
                              final nom = nomCtrl.text.trim();
                              if (prenom.length < 2 || nom.length < 2) {
                                setModalState(() {
                                  errorMsg =
                                      'Le prénom et le nom doivent comporter au moins 2 caractères.';
                                });
                                return;
                              }
                              setModalState(() {
                                isSaving = true;
                                errorMsg = null;
                              });
                              try {
                                await ref
                                    .read(agentApiServiceProvider)
                                    .updateProfile(
                                      nom: nom,
                                      prenom: prenom,
                                      telephone: telCtrl.text.trim(),
                                      zoneCouverture: zoneCtrl.text.trim(),
                                    );
                                ref.invalidate(agentProfileProvider);
                                ref.invalidate(dashboardAgentProvider);
                                if (ctx.mounted) {
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Profil mis à jour avec succès.',
                                      ),
                                      backgroundColor: AppColors.success,
                                    ),
                                  );
                                }
                              } catch (e) {
                                setModalState(() {
                                  isSaving = false;
                                  errorMsg =
                                      'Impossible de mettre à jour le profil : $e';
                                });
                              }
                            },
                      icon: isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check_circle_outline),
                      label: Text(
                        isSaving ? 'Enregistrement...' : 'Enregistrer',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profileAsync = ref.watch(agentProfileProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.surface,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        elevation: 0.5,
        title: Text(
          'Mon Profil Agent',
          style: (isDark ? AppTextStyles.h3Dark : AppTextStyles.h3).copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            ref.invalidate(agentProfileProvider);
          },
          child: profileAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            error: (err, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.space24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 52,
                      color: AppColors.danger,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Impossible de charger votre profil agent.',
                      textAlign: TextAlign.center,
                      style: (isDark
                              ? AppTextStyles.bodyDark
                              : AppTextStyles.body)
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      err.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => ref.invalidate(agentProfileProvider),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Réessayer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            data: (profile) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppDimensions.space16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Carte d'identité officielle de l'Agent
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.space20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? const [
                                  AppColors.darkSurfaceVariant,
                                  AppColors.darkPrimaryContainer,
                                ]
                              : const [
                                  AppColors.primaryDark,
                                  AppColors.primary,
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 34,
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.2),
                                child: Text(
                                  profile.initials,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppDimensions.space16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white
                                                .withValues(alpha: 0.2),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: const Text(
                                            'AGENT TERRAIN',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.7,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.success
                                                .withValues(alpha: 0.25),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            profile.statut,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      profile.fullName.isNotEmpty
                                          ? profile.fullName
                                          : 'Agent de Collecte',
                                      style: AppTextStyles.h3.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      profile.email,
                                      style: AppTextStyles.caption.copyWith(
                                        color:
                                            Colors.white.withValues(alpha: 0.85),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _BadgeStat(
                                  label: 'Matricule',
                                  value: profile.matricule,
                                ),
                                Container(
                                  width: 1,
                                  height: 28,
                                  color: Colors.white.withValues(alpha: 0.25),
                                ),
                                _BadgeStat(
                                  label: 'Collectes totales',
                                  value: '${profile.nombreTotalCollectes}',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppDimensions.space20),

                    // 2. Informations Professionnelles & Coordonnées
                    _SectionContainer(
                      title: 'Informations professionnelles',
                      isDark: isDark,
                      trailing: TextButton.icon(
                        onPressed: () =>
                            _showEditProfileSheet(context, ref, profile),
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: const Text('Modifier'),
                      ),
                      children: [
                        _InfoRow(
                          icon: Icons.map_outlined,
                          label: 'Zone de couverture',
                          value: profile.zoneCouverture.isNotEmpty
                              ? profile.zoneCouverture
                              : 'Non renseignée',
                          isDark: isDark,
                        ),
                        _InfoRow(
                          icon: Icons.phone_outlined,
                          label: 'Téléphone',
                          value: (profile.telephone != null &&
                                  profile.telephone!.isNotEmpty)
                              ? profile.telephone!
                              : 'Non renseigné',
                          isDark: isDark,
                        ),
                        _InfoRow(
                          icon: Icons.calendar_today_outlined,
                          label: 'Membre depuis',
                          value: _formatDate(profile.dateCreation),
                          isDark: isDark,
                          showDivider: false,
                        ),
                      ],
                    ),

                    const SizedBox(height: AppDimensions.space20),

                    // 3. Répertoire Terrain
                    _SectionContainer(
                      title: 'Activités de terrain',
                      isDark: isDark,
                      children: [
                        _ActionTile(
                          icon: Icons.people_outline_rounded,
                          title: 'Informateurs & Tradipraticiens',
                          subtitle: 'Répertoire des sources de terrain',
                          isDark: isDark,
                          showDivider: false,
                          onTap: () => context.push(RouteNames.agentSourcesPath),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppDimensions.space20),

                    // 4. Préférences & Compte
                    _SectionContainer(
                      title: 'Préférences & Sécurité',
                      isDark: isDark,
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              isDark
                                  ? Icons.dark_mode_rounded
                                  : Icons.light_mode_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            'Mode sombre',
                            style: (isDark
                                    ? AppTextStyles.bodyDark
                                    : AppTextStyles.body)
                                .copyWith(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            isDark ? 'Activé' : 'Désactivé',
                            style: isDark
                                ? AppTextStyles.captionDark
                                : AppTextStyles.caption,
                          ),
                          trailing: Switch.adaptive(
                            value: isDark,
                            activeTrackColor: AppColors.primary,
                            onChanged: (_) {
                              ref
                                  .read(themeModeProvider.notifier)
                                  .toggleTheme(currentIsDark: isDark);
                            },
                          ),
                        ),
                        Divider(
                          color:
                              isDark ? AppColors.darkBorder : AppColors.border,
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.danger.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.logout_rounded,
                              color: AppColors.danger,
                              size: 20,
                            ),
                          ),
                          title: const Text(
                            'Se déconnecter',
                            style: TextStyle(
                              color: AppColors.danger,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            'Fermer la session agent sur cet appareil',
                            style: isDark
                                ? AppTextStyles.captionDark
                                : AppTextStyles.caption,
                          ),
                          onTap: () => _handleLogout(context, ref),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppDimensions.space24),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context, isDark),
    );
  }

  Widget _buildBottomNav(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.border,
          ),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 58,
          child: Row(
            children: [
              Expanded(
                child: _NavButton(
                  icon: Icons.home_outlined,
                  label: 'Accueil',
                  isDark: isDark,
                  onTap: () => context.go(RouteNames.agentDashboardPath),
                ),
              ),
              Expanded(
                child: _NavButton(
                  icon: Icons.folder_open,
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
                      heroTag: 'agent_profil_fab',
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
                child: _NavButton(
                  icon: Icons.notifications_none_outlined,
                  label: 'Notif.',
                  isDark: isDark,
                  onTap: () => context.go(RouteNames.agentNotificationsPath),
                ),
              ),
              Expanded(
                child: _NavButton(
                  icon: Icons.person_rounded,
                  label: 'Profil',
                  isDark: isDark,
                  selected: true,
                  onTap: () {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BadgeStat extends StatelessWidget {
  final String label;
  final String value;

  const _BadgeStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.75),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _SectionContainer extends StatelessWidget {
  final String title;
  final bool isDark;
  final Widget? trailing;
  final List<Widget> children;

  const _SectionContainer({
    required this.title,
    required this.isDark,
    required this.children,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.space16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: (isDark ? AppTextStyles.h3Dark : AppTextStyles.h3)
                    .copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;
  final bool showDivider;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: isDark
                          ? AppTextStyles.captionDark
                          : AppTextStyles.caption,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style:
                          (isDark ? AppTextStyles.bodyDark : AppTextStyles.body)
                              .copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            color: isDark ? AppColors.darkBorder : AppColors.border,
          ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;
  final bool showDivider;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
    required this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          onTap: onTap,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          title: Text(
            title,
            style: (isDark ? AppTextStyles.bodyDark : AppTextStyles.body)
                .copyWith(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            subtitle,
            style: isDark ? AppTextStyles.captionDark : AppTextStyles.caption,
          ),
          trailing: const Icon(Icons.chevron_right_rounded, size: 20),
        ),
        if (showDivider)
          Divider(
            height: 1,
            color: isDark ? AppColors.darkBorder : AppColors.border,
          ),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final bool selected;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? AppColors.primary
        : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary);
    return InkWell(
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
    );
  }
}

