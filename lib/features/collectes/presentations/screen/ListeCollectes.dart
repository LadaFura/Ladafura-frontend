import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ladafura_frontend_flutter/features/collectes/providers/collect_provider.dart';
import 'package:ladafura_frontend_flutter/shared/enums/statut_collecte.dart';

import '../../../../core/routing/route_names.dart';

class ListeCollectes extends StatelessWidget {
  const ListeCollectes({super.key});

  @override
  Widget build(BuildContext context) {
    return const Listecollectes();
  }
}

class Listecollectes extends ConsumerWidget {
  const Listecollectes({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final items = [
    //   _CollecteItem(
    //     name: 'Moringa alfeita',
    //     location: 'Dijon',
    //     date: '12 septembre 2025',
    //     status: 'En attente',
    //     statusColor: const Color(0xFFEFFAF1),
    //     statusTextColor: const Color(0xFF2D7A4B),
    //     iconColor: const Color(0xFF7CBF73),
    //   ),
    //   _CollecteItem(
    //     name: 'Kinkeliba',
    //     location: 'Séloua',
    //     date: '15 septembre 2025',
    //     status: 'Validée',
    //     statusColor: const Color(0xFFE2F3E8),
    //     statusTextColor: const Color(0xFF2C8C5B),
    //     iconColor: const Color(0xFF8DCB78),
    //   ),
    //   _CollecteItem(
    //     name: 'Moringa',
    //     location: 'Ségou',
    //     date: '18 septembre 2025',
    //     status: 'Brouillon',
    //     statusColor: const Color(0xFFF1F1F1),
    //     statusTextColor: const Color(0xFF6B6B6B),
    //     iconColor: const Color(0xFF88B97A),
    //   ),
    //   _CollecteItem(
    //     name: 'Moringa',
    //     location: 'Ségou',
    //     date: '18 septembre 2025',
    //     status: 'Rejeter',
    //     statusColor: const Color(0xFFFDEDED),
    //     statusTextColor: const Color(0xFFD14A4A),
    //     iconColor: const Color(0xFF7FBC62),
    //   ),
    // ];


    final items = ref.watch(collectProvider);
    const filters = ['Toutes', 'Brouillon', 'En attente', 'Validées'];


    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F3),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Mes collectes',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2629),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.search, color: Color(0xFF1F2629)),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Rechercher une collecte...',
                  hintStyle: const TextStyle(
                    color: Color(0xFF9FA7A3),
                    fontSize: 14,
                  ),
                  prefixIcon:
                      const Icon(Icons.search, color: Color(0xFF9BA4A0)),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 42,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final label = filters[index];
                  final selected = index == 0;

                  return Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: selected ? const Color(0xFFE7F6EA) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        color: selected
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFF636A69),
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
                child: Text(
                  '24 collectes',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

         

items.when(
  loading: () {
    return const Expanded(
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  },

  error: (error, stackTrace) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 12),
            Text(
              'Impossible de charger les collectes',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  },

  data: (data) {
    if (data.isEmpty) {
      return const Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.eco_outlined,
                size: 50,
                color: Colors.grey,
              ),
              SizedBox(height: 12),
              Text(
                'Aucune collecte soumise',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 84),
        itemCount: data.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = data[index];

          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // ICÔNE
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.eco_rounded,
                    color: Color(0xFF4CAF50),
                    size: 20,
                  ),
                ),

                const SizedBox(width: 12),

                // INFORMATIONS
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nom scientifique
                      Text(
                        item.nomScientifiquePlante ??
                            'Plante non renseignée',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2629),
                        ),
                      ),

                      const SizedBox(height: 4),

                      // Source
                      if (item.nomSource != null &&
                          item.nomSource!.isNotEmpty)
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                item.nomSource!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 3),

                      // Localité
                      if (item.localite != null &&
                          item.localite!.isNotEmpty)
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                item.localite!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 3),

                      // Date de soumission
                      if (item.dateSoumission != null)
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 13,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(item.dateSoumission!),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // STATUT
                _buildStatus(item.statut),
              ],
            ),
          );
        },
      ),
    );
  },
)
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 82,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 6),
          child: Row(
            children: [
              Expanded(
                child: _BottomNavItem(
                  icon: Icons.home_outlined,
                  label: 'Accueil',
                  active: false,
                  onTap: () => context.go(RouteNames.agentDashboardPath),
                ),
              ),
              Expanded(
                child: _BottomNavItem(
                  icon: Icons.list_alt_outlined,
                  label: 'Collectes',
                  active: true,
                  onTap: () => context.go(RouteNames.agentCollectesPath),
                ),
              ),
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: 42,
                    height: 42,
                    child: FloatingActionButton(
                      onPressed: () =>
                          context.go(RouteNames.agentNouvelleCollectePath),
                      backgroundColor: const Color(0xFF2E7D32),
                      elevation: 0,
                      shape: const CircleBorder(),
                      child: const Icon(
                        Icons.add,
                        size: 25,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _BottomNavItem(
                  icon: Icons.notifications_none_outlined,
                  label: 'Notif.',
                  active: false,
                  onTap: () => context.go(RouteNames.agentNotificationsPath),
                ),
              ),
              Expanded(
                child: _BottomNavItem(
                  icon: Icons.person_outline,
                  label: 'Profil',
                  active: false,
                  onTap: () => context.go(RouteNames.agentProfilPath),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  Widget _buildStatus(StatutCollecte? statut) {
    switch (statut) {
      case StatutCollecte.brouillon:
        return Text(
          'En attente',
          style: TextStyle(color: Colors.orange),
        );
      case StatutCollecte.correctionDemandee:
        return Text(
          'En cours',
          style: TextStyle(color: Colors.blue),
        );
      case StatutCollecte.soumise:
        return Text(
          'Terminée',
          style: TextStyle(color: Colors.green),
        );
      default:
        return Text('Inconnu');
    }
  } 
}

class _CollecteItem {
  final String name;
  final String location;
  final String date;
  final String status;
  final Color statusColor;
  final Color statusTextColor;
  final Color iconColor;

  const _CollecteItem({
    required this.name,
    required this.location,
    required this.date,
    required this.status,
    required this.statusColor,
    required this.statusTextColor,
    required this.iconColor,
  });
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 22,
            color: active ? const Color(0xFF2D7A4B) : const Color(0xFF7E8A86),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: active ? const Color(0xFF2D7A4B) : const Color(0xFF7E8A86),
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
