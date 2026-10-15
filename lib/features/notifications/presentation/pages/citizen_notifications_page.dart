import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_colors.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_dimensions.dart';
import 'package:ladafura_frontend_flutter/core/routing/route_names.dart';
import 'package:ladafura_frontend_flutter/features/notifications/models/population_notification_model.dart';
import 'package:ladafura_frontend_flutter/features/notifications/providers/notification_provider.dart';

class CitizenNotificationsPage extends ConsumerWidget {
  const CitizenNotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notificationsAsync = ref.watch(populationNotificationsProvider);
    final activeFilter = ref.watch(notificationFilterProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF8F9FA),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Tout marquer comme lu',
            icon: const Icon(Icons.done_all_rounded),
            onPressed: () async {
              await ref.read(populationNotificationsProvider.notifier).markAllAsRead();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Toutes les notifications ont été marquées comme lues.'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtres (Chips)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.space16,
              vertical: AppDimensions.space8,
            ),
            color: isDark ? AppColors.darkSurface : Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'Toutes',
                    isSelected: activeFilter == NotificationFilter.toutes,
                    onTap: () {
                      ref.read(notificationFilterProvider.notifier).state =
                          NotificationFilter.toutes;
                      ref.read(populationNotificationsProvider.notifier).loadNotifications();
                    },
                  ),
                  const SizedBox(width: AppDimensions.space8),
                  _FilterChip(
                    label: 'Non lues',
                    isSelected: activeFilter == NotificationFilter.nonLues,
                    onTap: () {
                      ref.read(notificationFilterProvider.notifier).state =
                          NotificationFilter.nonLues;
                      ref.read(populationNotificationsProvider.notifier).loadNotifications();
                    },
                  ),
                  const SizedBox(width: AppDimensions.space8),
                  _FilterChip(
                    label: 'Commandes',
                    isSelected: activeFilter == NotificationFilter.commandes,
                    onTap: () {
                      ref.read(notificationFilterProvider.notifier).state =
                          NotificationFilter.commandes;
                      ref.read(populationNotificationsProvider.notifier).loadNotifications();
                    },
                  ),
                  const SizedBox(width: AppDimensions.space8),
                  _FilterChip(
                    label: 'Avis',
                    isSelected: activeFilter == NotificationFilter.avis,
                    onTap: () {
                      ref.read(notificationFilterProvider.notifier).state =
                          NotificationFilter.avis;
                      ref.read(populationNotificationsProvider.notifier).loadNotifications();
                    },
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE9ECEF)),

          // Liste des notifications avec pull-to-refresh
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () =>
                  ref.read(populationNotificationsProvider.notifier).refresh(),
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
                          size: 56,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: AppDimensions.space12),
                        const Text(
                          'Impossible de charger vos notifications',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.space8),
                        Text(
                          err.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: AppDimensions.space16),
                        ElevatedButton.icon(
                          onPressed: () => ref
                              .read(populationNotificationsProvider.notifier)
                              .refresh(),
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
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.notifications_none_rounded,
                                    size: 48,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: AppDimensions.space16),
                                const Text(
                                  'Aucune notification',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: AppDimensions.space8),
                                const Text(
                                  'Vous êtes à jour ! Aucune alerte récente.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
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
                    padding: const EdgeInsets.symmetric(
                      vertical: AppDimensions.space12,
                      horizontal: AppDimensions.space16,
                    ),
                    itemCount: notifications.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppDimensions.space8),
                    itemBuilder: (context, index) {
                      final item = notifications[index];
                      return _NotificationCard(
                        item: item,
                        onTap: () {
                          // Marquer comme lu
                          if (!item.lue) {
                            ref
                                .read(populationNotificationsProvider.notifier)
                                .markAsRead(item.id);
                          }
                          // Navigation contextuelle si lien présent
                          _handleNavigation(context, item);
                        },
                        onDelete: () {
                          ref
                              .read(populationNotificationsProvider.notifier)
                              .deleteNotification(item.id);
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

  void _handleNavigation(BuildContext context, PopulationNotificationModel item) {
    if (item.referenceId != null && item.type.contains('COMMANDE')) {
      // Rediriger vers le détail de la commande si referenceId numérique
      final cmdId = int.tryParse(item.referenceId!);
      if (cmdId != null) {
        context.push(RouteNames.citizenCommandeDetailUrl(cmdId.toString()));
        return;
      }
    }
    if (item.lien != null && item.lien!.isNotEmpty) {
      if (item.lien!.startsWith('/')) {
        context.push(item.lien!);
      }
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFDEE2E6),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final PopulationNotificationModel item;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NotificationCard({
    required this.item,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final d = item.dateNotification;
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    final year = d.year.toString();
    final hour = d.hour.toString().padLeft(2, '0');
    final minute = d.minute.toString().padLeft(2, '0');
    final dateStr = '$day/$month/$year à $hour:$minute';

    return Dismissible(
      key: Key('notif_${item.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark
                ? (item.lue ? AppColors.darkSurface : AppColors.darkSurface.withValues(alpha: 0.8))
                : (item.lue ? Colors.white : const Color(0xFFF1F8F4)),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: !item.lue ? AppColors.primary.withValues(alpha: 0.3) : const Color(0xFFE9ECEF),
              width: !item.lue ? 1.2 : 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icône selon type
              _buildLeadingIcon(item.type, item.niveau),
              const SizedBox(width: 12),

              // Contenu
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.titre,
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: item.lue ? FontWeight.w600 : FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF1E272E),
                            ),
                          ),
                        ),
                        if (!item.lue)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.message,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white70 : const Color(0xFF596275),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      dateStr,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white38 : const Color(0xFFA4B0BE),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeadingIcon(String type, NotificationNiveau niveau) {
    IconData icon;
    Color bg;
    Color fg;

    if (type.contains('COMMANDE')) {
      icon = Icons.shopping_bag_outlined;
      bg = const Color(0xFFE8F5E9);
      fg = AppColors.primary;
    } else if (type.contains('AVIS')) {
      icon = Icons.star_border_rounded;
      bg = const Color(0xFFFFF8E1);
      fg = Colors.amber.shade800;
    } else if (niveau == NotificationNiveau.urgent || type.contains('ALERTE')) {
      icon = Icons.warning_amber_rounded;
      bg = const Color(0xFFFFEBEE);
      fg = Colors.red.shade700;
    } else {
      icon = Icons.notifications_none_rounded;
      bg = const Color(0xFFE3F2FD);
      fg = Colors.blue.shade700;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: fg, size: 20),
    );
  }
}
