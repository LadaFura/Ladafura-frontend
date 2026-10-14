import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_colors.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_dimensions.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_text_styles.dart';
import 'package:ladafura_frontend_flutter/features/agent/providers/agent_providers.dart';

/// Écran listant les tradipraticiens et herboristes interrogés par les agents de collecte.
class AgentSourcesScreen extends ConsumerStatefulWidget {
  const AgentSourcesScreen({super.key});

  @override
  ConsumerState<AgentSourcesScreen> createState() => _AgentSourcesScreenState();
}

class _AgentSourcesScreenState extends ConsumerState<AgentSourcesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _filterQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddSourceModal(BuildContext context) {
    final nomCtrl = TextEditingController();
    final prenomCtrl = TextEditingController();
    final telCtrl = TextEditingController();
    final adrCtrl = TextEditingController();
    final specCtrl = TextEditingController();
    String role = 'THERAPEUTE';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Ajouter un informateur de terrain',
                  style: (isDark ? AppTextStyles.h3Dark : AppTextStyles.h3)
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: prenomCtrl,
                        decoration: const InputDecoration(labelText: 'Prénom'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: nomCtrl,
                        decoration: const InputDecoration(labelText: 'Nom *'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: telCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Téléphone'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: adrCtrl,
                  decoration: const InputDecoration(labelText: 'Village / Commune'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: specCtrl,
                  decoration: const InputDecoration(labelText: 'Spécialité traditionnelle'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    if (nomCtrl.text.trim().isEmpty) return;
                    try {
                      final api = ref.read(agentApiServiceProvider);
                      await api.createSource(
                        nom: nomCtrl.text.trim(),
                        prenom: prenomCtrl.text.trim().isNotEmpty
                            ? prenomCtrl.text.trim()
                            : null,
                        telephone: telCtrl.text.trim().isNotEmpty
                            ? telCtrl.text.trim()
                            : null,
                        adresse: adrCtrl.text.trim().isNotEmpty
                            ? adrCtrl.text.trim()
                            : null,
                        specialite: specCtrl.text.trim().isNotEmpty
                            ? specCtrl.text.trim()
                            : null,
                        role: role,
                      );
                      ref.invalidate(agentSourcesListProvider);
                      if (ctx.mounted) Navigator.pop(ctx);
                    } catch (e) {
                      if (ctx.mounted) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(content: Text('Erreur : $e')),
                        );
                      }
                    }
                  },
                  child: const Text('Enregistrer le praticien'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sourcesAsync = ref.watch(agentSourcesListProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.surface,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        elevation: 0.5,
        title: Text(
          'Tradipraticiens & Informateurs',
          style: (isDark ? AppTextStyles.h3Dark : AppTextStyles.h3).copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_rounded),
            tooltip: 'Ajouter un informateur',
            onPressed: () => _showAddSourceModal(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppDimensions.space16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Rechercher par nom, village ou spécialité...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _filterQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _filterQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: isDark ? AppColors.darkSurface : Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (val) => setState(() => _filterQuery = val.trim().toLowerCase()),
              ),
            ),
            Expanded(
              child: sourcesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.orange),
                      const SizedBox(height: 12),
                      Text('Erreur de chargement: $err'),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(agentSourcesListProvider),
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                ),
                data: (sources) {
                  final filtered = _filterQuery.isEmpty
                      ? sources
                      : sources.where((s) {
                          final nomMatch = s.nomComplet.toLowerCase().contains(_filterQuery);
                          final adrMatch = s.adresse?.toLowerCase().contains(_filterQuery) ?? false;
                          final specMatch = s.specialite?.toLowerCase().contains(_filterQuery) ?? false;
                          return nomMatch || adrMatch || specMatch;
                        }).toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline_rounded,
                            size: 56,
                            color: isDark ? AppColors.darkTextMuted : Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          const Text('Aucun praticien répertorié.'),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space16),
                    itemCount: filtered.length,
                    separatorBuilder: (ctx, i) => const SizedBox(height: 8),
                    itemBuilder: (ctx, index) {
                      final s = filtered[index];
                      return ListTile(
                        tileColor: isDark ? AppColors.darkSurface : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                          side: BorderSide(
                            color: isDark ? AppColors.darkBorder : AppColors.inputBorder,
                          ),
                        ),
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          child: const Icon(Icons.person, color: AppColors.primary),
                        ),
                        title: Text(
                          s.nomComplet,
                          style: (isDark ? AppTextStyles.bodyDark : AppTextStyles.body)
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${s.specialite ?? "Praticien"} • ${s.adresse ?? "Mali"}',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                          ),
                        ),
                        trailing: s.telephone != null
                            ? Text(
                                s.telephone!,
                                style: const TextStyle(fontSize: 11, color: AppColors.primary),
                              )
                            : null,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
