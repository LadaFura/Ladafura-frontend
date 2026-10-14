import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_colors.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_dimensions.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_text_styles.dart';
import 'package:ladafura_frontend_flutter/features/agent/models/agent_source_model.dart';
import 'package:ladafura_frontend_flutter/features/agent/providers/agent_providers.dart';

/// Étape 4 du Wizard : Sélection ou enregistrement de la source d'information de terrain (Tradipraticien / Herboriste).
class StepSourceTerrainWidget extends ConsumerStatefulWidget {
  const StepSourceTerrainWidget({super.key});

  @override
  ConsumerState<StepSourceTerrainWidget> createState() =>
      _StepSourceTerrainWidgetState();
}

class _StepSourceTerrainWidgetState extends ConsumerState<StepSourceTerrainWidget> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  List<AgentSourceModel> _sources = [];
  bool _isLoading = false;

  // Formulaire d'ajout rapide
  bool _showAddForm = false;
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _telController = TextEditingController();
  final TextEditingController _adresseController = TextEditingController();
  final TextEditingController _specialiteController = TextEditingController();
  String _selectedRole = 'THERAPEUTE';
  bool _isSavingSource = false;

  @override
  void initState() {
    super.initState();
    _loadSources();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _nomController.dispose();
    _prenomController.dispose();
    _telController.dispose();
    _adresseController.dispose();
    _specialiteController.dispose();
    super.dispose();
  }

  Future<void> _loadSources([String? search]) async {
    setState(() => _isLoading = true);
    try {
      final api = ref.read(agentApiServiceProvider);
      final list = await api.getSources(search: search);
      if (mounted) {
        setState(() {
          _sources = list;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged() {
    final q = _searchController.text.trim();
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _loadSources(q.isNotEmpty ? q : null);
    });
  }

  Future<void> _handleCreateSource() async {
    final nom = _nomController.text.trim();
    if (nom.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le nom de famille est obligatoire')),
      );
      return;
    }

    setState(() => _isSavingSource = true);
    try {
      final api = ref.read(agentApiServiceProvider);
      final created = await api.createSource(
        nom: nom,
        prenom: _prenomController.text.trim().isNotEmpty
            ? _prenomController.text.trim()
            : null,
        telephone: _telController.text.trim().isNotEmpty
            ? _telController.text.trim()
            : null,
        adresse: _adresseController.text.trim().isNotEmpty
            ? _adresseController.text.trim()
            : null,
        specialite: _specialiteController.text.trim().isNotEmpty
            ? _specialiteController.text.trim()
            : null,
        role: _selectedRole,
      );

      ref.read(nouvelleCollecteWizardProvider.notifier).selectSource(created);
      setState(() {
        _showAddForm = false;
        _isSavingSource = false;
      });
      _loadSources();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Source "${created.nomComplet}" enregistrée et sélectionnée.'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      setState(() => _isSavingSource = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final draft = ref.watch(nouvelleCollecteWizardProvider);
    final selectedSource = draft.selectedSource;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // En-tête
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.person_pin_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppDimensions.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Source & Praticien de Terrain',
                      style: (isDark ? AppTextStyles.h3Dark : AppTextStyles.h3)
                          .copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Identifiez le tradipraticien ou herboriste dépositaire du savoir.',
                      style: (isDark
                              ? AppTextStyles.captionDark
                              : AppTextStyles.caption)
                          .copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.space16),

          // Source actuellement sélectionnée
          if (selectedSource != null && selectedSource.id > 0) ...[
            Container(
              padding: const EdgeInsets.all(AppDimensions.space16),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurfaceVariant
                    : Colors.green.shade50,
                borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                border: Border.all(
                  color: isDark ? AppColors.darkPrimary : AppColors.primary,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                    child: const Icon(Icons.person, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SOURCE SÉLECTIONNÉE',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          selectedSource.nomComplet,
                          style: (isDark
                                  ? AppTextStyles.bodyDark
                                  : AppTextStyles.body)
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (selectedSource.specialite != null)
                          Text(
                            selectedSource.specialite!,
                            style: (isDark
                                    ? AppTextStyles.captionDark
                                    : AppTextStyles.caption)
                                .copyWith(fontSize: 11),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.danger),
                    tooltip: 'Désélectionner',
                    onPressed: () {
                      ref
                          .read(nouvelleCollecteWizardProvider.notifier)
                          .selectSource(null);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.space16),
          ],

          // Bouton bascule Formulaire d'ajout
          Row(
            children: [
              Expanded(
                child: Text(
                  _showAddForm
                      ? 'Nouveau praticien / informateur'
                      : 'Sélectionner parmi les praticiens connus',
                  style: (isDark ? AppTextStyles.bodyDark : AppTextStyles.body)
                      .copyWith(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              TextButton.icon(
                icon: Icon(
                  _showAddForm ? Icons.list_rounded : Icons.person_add_rounded,
                  size: 18,
                ),
                label: Text(_showAddForm ? 'Liste existante' : 'Ajouter nouveau'),
                onPressed: () => setState(() => _showAddForm = !_showAddForm),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Formulaire d'ajout rapide
          if (_showAddForm) ...[
            Container(
              padding: const EdgeInsets.all(AppDimensions.space16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.inputBorder,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _prenomController,
                          decoration: const InputDecoration(
                            labelText: 'Prénom',
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _nomController,
                          decoration: const InputDecoration(
                            labelText: 'Nom *',
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _telController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Téléphone (ex: +223 70 00 00 00)',
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _adresseController,
                    decoration: const InputDecoration(
                      labelText: 'Village / Commune de résidence',
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _specialiteController,
                    decoration: const InputDecoration(
                      labelText: 'Spécialité traditionnelle',
                      hintText: 'Ex: Traitement des fièvres, os et fractures...',
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Profil : ', style: TextStyle(fontSize: 12)),
                      ChoiceChip(
                        label: const Text('Tradipraticien', style: TextStyle(fontSize: 11)),
                        selected: _selectedRole == 'THERAPEUTE',
                        onSelected: (s) => setState(() => _selectedRole = 'THERAPEUTE'),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Herboriste', style: TextStyle(fontSize: 11)),
                        selected: _selectedRole == 'HERBORISTE',
                        onSelected: (s) => setState(() => _selectedRole = 'HERBORISTE'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _isSavingSource ? null : _handleCreateSource,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    icon: _isSavingSource
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.check, size: 18),
                    label: const Text('Enregistrer et Sélectionner'),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Recherche dans les sources existantes
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher par nom ou village...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: isDark ? AppColors.darkSurface : Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_sources.isEmpty)
              Padding(
                padding: const EdgeInsets.all(AppDimensions.space20),
                child: Text(
                  'Aucune source trouvée. Utilisez "Ajouter nouveau" pour en créer une.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _sources.length,
                separatorBuilder: (ctx, i) => const SizedBox(height: 8),
                itemBuilder: (ctx, index) {
                  final s = _sources[index];
                  final isSel = selectedSource?.id == s.id;
                  return ListTile(
                    tileColor: isSel
                        ? (isDark ? AppColors.darkSurfaceVariant : Colors.green.shade50)
                        : (isDark ? AppColors.darkSurface : Colors.white),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: isSel
                            ? AppColors.primary
                            : (isDark ? AppColors.darkBorder : AppColors.inputBorder),
                      ),
                    ),
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: Text(
                        s.nom.isNotEmpty ? s.nom[0].toUpperCase() : '?',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      s.nomComplet,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      s.specialite ?? s.adresse ?? 'Tradipraticien',
                      style: const TextStyle(fontSize: 11),
                    ),
                    trailing: isSel
                        ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                        : null,
                    onTap: () {
                      ref
                          .read(nouvelleCollecteWizardProvider.notifier)
                          .selectSource(s);
                    },
                  );
                },
              ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
