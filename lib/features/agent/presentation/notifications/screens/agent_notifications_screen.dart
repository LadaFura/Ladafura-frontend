import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../../../core/routing/route_names.dart';
import '../../../models/agent_notification_response.dart';
import '../../../providers/agent_providers.dart';
import '../../../providers/dashboard_provider.dart';

/// Écran du centre de notifications de l'Agent de Collecte Terrain.
class AgentNotificationsScreen extends ConsumerWidget {
  const AgentNotificationsScreen({super.key});

  static const List<Map<String, String>> _filters = [
    {'id': 'TOUTES', 'label': 'Toutes'},
    {'id': 'NON_LUES', 'label': 'Non lues'},
    {'id': 'COLLECTE_VALIDEE', 'label': 'Validées'},
    {'id': 'COLLECTE_CORRECTION', 'label': 'À corriger'},
    {'id': 'COLLECTE_REJETEE', 'label': 'Rejetées'},
  ];

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return "À l'instant";
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours} h';
    if (diff.inDays == 1) return 'Hier';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays} j';
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m/${date.year}';
  }

  Color _typeColor(String type, String niveau) {
    switch (type.toUpperCase()) {
      case 'COLLECTE_VALIDEE':
        return AppColors.success;
      case 'COLLECTE_REJETEE':
        return AppColors.danger;
      case 'COLLECTE_CORRECTION':
        return Colors.orange;
      case 'COLLECTE_STATUT':
        return AppColors.primary;
    }
    switch (niveau.toUpperCase()) {
      case 'SUCCES':
        return AppColors.success;
      case 'URGENT':
        return AppColors.danger;
      case 'ATTENTION':
        return Colors.orange;
      default:
        return AppColors.primary;
    }
  }

  IconData _typeIcon(String type) {
    switch (type.toUpperCase()) {
      case 'COLLECTE_VALIDEE':
        return Icons.verified_rounded;
      case 'COLLECTE_REJETEE':
        return Icons.cancel_outlined;
      case 'COLLECTE_CORRECTION':
        return Icons.edit_note_rounded;
      case 'COLLECTE_STATUT':
        return Icons.sync_alt_rounded;
      default:
        return Icons.notifications_active_outlined;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeFilter = ref.watch(agentNotificationsFilterProvider);
    final notificationsAsync = ref.watch(agentNotificationsListProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.surface,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        elevation: 0.5,
        title: Text(
          'Notifications',
          style: (isDark ? AppTextStyles.h3Dark : AppTextStyles.h3).copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Tout marquer comme lu',
            icon: Icon(
              Icons.done_all_rounded,
              color: isDark ? Colors.white : AppColors.primary,
            ),
            onPressed: () async {
              try {
                await ref
                    .read(agentApiServiceProvider)
                    .markAllNotificationsAsRead();
                ref.invalidate(agentNotificationsListProvider);
                ref.invalidate(dashboardAgentProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Toutes les notifications ont été marquées comme lues.',
                      ),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur : $e'),
                      backgroundColor: AppColors.danger,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Barre de filtres
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.space16,
                vertical: AppDimensions.space8,
              ),
              color: isDark ? AppColors.darkSurface : Colors.white,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _filters.map((f) {
                    final isSelected = activeFilter == f['id'];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(f['label']!),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : (isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.textPrimary),
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                        backgroundColor: isDark
                            ? AppColors.darkSurfaceVariant
                            : Colors.grey.shade100,
                        onSelected: (_) {
                          ref
                              .read(agentNotificationsFilterProvider.notifier)
                              .state = f['id']!;
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            Divider(
              height: 1,
              color: isDark ? AppColors.darkBorder : AppColors.border,
            ),

            // Liste des notifications
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async {
                  ref.invalidate(agentNotificationsListProvider);
                  ref.invalidate(dashboardAgentProvider);
                },
                child: notificationsAsync.when(
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
                            Icons.notifications_off_outlined,
                            size: 52,
                            color: AppColors.danger,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Impossible de charger les notifications.',
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
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () =>
                                ref.invalidate(agentNotificationsListProvider),
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
                  data: (notifications) {
                    if (notifications.isEmpty) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.55,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.12),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.notifications_none_rounded,
                                      size: 48,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Aucune notification',
                                    style: (isDark
                                            ? AppTextStyles.h3Dark
                                            : AppTextStyles.h3)
                                        .copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Vos alertes de validation et retours de collectes apparaîtront ici.',
                                    textAlign: TextAlign.center,
                                    style: isDark
                                        ? AppTextStyles.captionDark
                                        : AppTextStyles.caption,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    return ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(AppDimensions.space16),
                      itemCount: notifications.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppDimensions.space12),
                      itemBuilder: (context, index) {
                        final notif = notifications[index];
                        return _NotificationTile(
                          notif: notif,
                          isDark: isDark,
                          color: _typeColor(notif.type, notif.niveau),
                          icon: _typeIcon(notif.type),
                          formattedDate: _formatDate(notif.dateNotification),
                          onTap: () async {
                            if (!notif.lue) {
                              try {
                                await ref
                                    .read(agentApiServiceProvider)
                                    .markNotificationAsRead(notif.id);
                                ref.invalidate(agentNotificationsListProvider);
                                ref.invalidate(dashboardAgentProvider);
                              } catch (_) {}
                            }
                            if (!context.mounted) return;
                            final refId = notif.referenceId;
                            if (refId != null &&
                                refId.isNotEmpty &&
                                int.tryParse(refId) != null) {
                              context.push(
                                RouteNames.agentCollecteDetailUrl(refId),
                              );
                            }
                          },
                          onDelete: () async {
                            try {
                              await ref
                                  .read(agentApiServiceProvider)
                                  .deleteNotification(notif.id);
                              ref.invalidate(agentNotificationsListProvider);
                              ref.invalidate(dashboardAgentProvider);
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Erreur : $e')),
                                );
                              }
                            }
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
                      heroTag: 'agent_notif_fab',
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
                  icon: Icons.notifications_rounded,
                  label: 'Notif.',
                  isDark: isDark,
                  selected: true,
                  onTap: () {},
                ),
              ),
              Expanded(
                child: _NavButton(
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

class _NotificationTile extends StatelessWidget {
  final AgentNotificationResponse notif;
  final bool isDark;
  final Color color;
  final IconData icon;
  final String formattedDate;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NotificationTile({
    required this.notif,
    required this.isDark,
    required this.color,
    required this.icon,
    required this.formattedDate,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final unread = !notif.lue;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.space16),
        decoration: BoxDecoration(
          color: unread
              ? (isDark
                  ? AppColors.primary.withValues(alpha: 0.14)
                  : AppColors.primary.withValues(alpha: 0.06))
              : (isDark ? AppColors.darkSurface : Colors.white),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: unread
                ? color.withValues(alpha: 0.45)
                : (isDark ? AppColors.darkBorder : AppColors.border),
            width: unread ? 1.3 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: AppDimensions.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notif.titre,
                          style: (isDark
                                  ? AppTextStyles.bodyDark
                                  : AppTextStyles.body)
                              .copyWith(
                            fontWeight:
                                unread ? FontWeight.w700 : FontWeight.w600,
                          ),
                        ),
                      ),
                      if (unread)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 6),
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notif.message,
                    style: (isDark
                            ? AppTextStyles.captionDark
                            : AppTextStyles.caption)
                        .copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : Colors.grey.shade600,
                        ),
                      ),
                      if (notif.referenceId != null &&
                          notif.referenceId!.isNotEmpty)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Voir la collecte #${notif.referenceId}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: color,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 10,
                              color: color,
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              tooltip: 'Supprimer',
              icon: Icon(
                Icons.delete_outline_rounded,
                size: 18,
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
              ),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
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

