import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_colors.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_dimensions.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_text_styles.dart';
import 'package:ladafura_frontend_flutter/features/agent/providers/agent_providers.dart';
import 'formatting_toolbar_widget.dart';

/// Étape 3 du Wizard : Recueil des savoirs traditionnels (partie de la plante, préparation, posologie, précautions).
class StepConnaissanceTraditionnelleWidget extends ConsumerStatefulWidget {
  const StepConnaissanceTraditionnelleWidget({super.key});

  @override
  ConsumerState<StepConnaissanceTraditionnelleWidget> createState() =>
      _StepConnaissanceTraditionnelleWidgetState();
}

class _StepConnaissanceTraditionnelleWidgetState
    extends ConsumerState<StepConnaissanceTraditionnelleWidget> {
  late final TextEditingController _partieController;
  late final TextEditingController _usageController;
  late final TextEditingController _preparationController;
  late final TextEditingController _precautionController;

  final Set<String> _selectedParties = <String>{};
  bool _isUpdatingFromChips = false;

  final List<String> _partiesSuggestions = [
    'Feuilles',
    'Écorce de tronc',
    'Écorce de racine',
    'Racines entières',
    'Fleurs',
    'Fruits',
    'Graines',
    'Tiges / Rameaux',
    'Sève / Latex',
    'Bulbe / Rhizome',
    'Plante entière',
  ];

  final List<String> _preparationSuggestions = [
    'Décoction aqueuse',
    'Infusion chaude',
    'Macération à froid',
    'Poudre sèche (broyage)',
    'Cataplasme ou friction',
    'Fumigation',
    'Bain de vapeur',
  ];

  @override
  void initState() {
    super.initState();
    final draft = ref.read(nouvelleCollecteWizardProvider);
    _partieController = TextEditingController(text: draft.partieUtilisee);
    _usageController = TextEditingController(text: draft.usageRapporte);
    _preparationController = TextEditingController(text: draft.preparation);
    _precautionController = TextEditingController(text: draft.precaution);

    _syncSelectedChipsFromText(_partieController.text);

    _partieController.addListener(_onPartieControllerChanged);
    _usageController.addListener(_sync);
    _preparationController.addListener(_sync);
    _precautionController.addListener(_sync);
  }

  @override
  void dispose() {
    _partieController.dispose();
    _usageController.dispose();
    _preparationController.dispose();
    _precautionController.dispose();
    super.dispose();
  }

  void _onPartieControllerChanged() {
    if (_isUpdatingFromChips) return;
    _syncSelectedChipsFromText(_partieController.text);
    _sync();
  }

  void _syncSelectedChipsFromText(String text) {
    final lower = text.toLowerCase();
    final parts = text
        .split(',')
        .map((s) => s.trim().toLowerCase())
        .where((s) => s.isNotEmpty)
        .toSet();

    final newSelected = <String>{};
    for (final sug in _partiesSuggestions) {
      final sugLower = sug.toLowerCase();
      if (parts.contains(sugLower) || lower.contains(sugLower)) {
        newSelected.add(sug);
      }
    }

    if (!_areSetsEqual(newSelected, _selectedParties)) {
      setState(() {
        _selectedParties.clear();
        _selectedParties.addAll(newSelected);
      });
    }
  }

  bool _areSetsEqual(Set<String> a, Set<String> b) {
    if (a.length != b.length) return false;
    return a.containsAll(b);
  }

  void _togglePartie(String partie) {
    _isUpdatingFromChips = true;
    final currentText = _partieController.text.trim();
    List<String> parts = currentText.isEmpty
        ? []
        : currentText
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();

    final existingIndex =
        parts.indexWhere((p) => p.toLowerCase() == partie.toLowerCase());

    if (existingIndex >= 0) {
      parts.removeAt(existingIndex);
      _selectedParties.remove(partie);
    } else {
      parts.add(partie);
      _selectedParties.add(partie);
    }

    final newText = parts.join(', ');
    _partieController.text = newText;
    _partieController.selection = TextSelection.fromPosition(
      TextPosition(offset: newText.length),
    );
    _isUpdatingFromChips = false;
    setState(() {});
    _sync();
  }

  void _sync() {
    ref.read(nouvelleCollecteWizardProvider.notifier).setConnaissances(
          usageRapporte: _usageController.text.trim(),
          partieUtilisee: _partieController.text.trim(),
          preparation: _preparationController.text.trim(),
          precaution: _precautionController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Organes ou Parties de la plante utilisées (Choix multiple et saisie libre)
          Row(
            children: [
              Text(
                'Parties de la plante utilisées *',
                style: (isDark ? AppTextStyles.bodyDark : AppTextStyles.body)
                    .copyWith(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Choix multiple',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkPrimary : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Sélectionnez une ou plusieurs parties courantes, ou saisissez-les directement ci-dessous.',
            style: (isDark ? AppTextStyles.captionDark : AppTextStyles.caption)
                .copyWith(
              fontSize: 11,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),

          // Suggestions en FilterChips sélectionnables multiples
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _partiesSuggestions.map((partie) {
              final isSel = _selectedParties.contains(partie);
              return FilterChip(
                label: Text(partie),
                selected: isSel,
                selectedColor: AppColors.primary,
                checkmarkColor: Colors.white,
                labelStyle: TextStyle(
                  color: isSel
                      ? Colors.white
                      : (isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary),
                  fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                  fontSize: 12,
                ),
                backgroundColor:
                    isDark ? AppColors.darkSurface : Colors.grey.shade100,
                side: BorderSide(
                  color: isSel
                      ? AppColors.primary
                      : (isDark ? AppColors.darkBorder : Colors.grey.shade300),
                ),
                onSelected: (_) => _togglePartie(partie),
              );
            }).toList(),
          ),

          const SizedBox(height: 10),

          // Champ de saisie libre et directe des parties
          TextField(
            controller: _partieController,
            style: isDark ? AppTextStyles.bodyDark : AppTextStyles.body,
            decoration: InputDecoration(
              labelText: 'Partie(s) de plante saisie(s) *',
              labelStyle: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
              hintText: 'Ex: Feuilles, Écorce de racine, Sève fraîche...',
              hintStyle: (isDark ? AppTextStyles.bodyDark : AppTextStyles.body)
                  .copyWith(
                color:
                    isDark ? AppColors.darkTextMuted : AppColors.textMuted,
              ),
              filled: true,
              fillColor: isDark ? AppColors.darkSurface : Colors.white,
              prefixIcon: Icon(
                Icons.grass_rounded,
                color: isDark ? Colors.white70 : AppColors.primary,
                size: 20,
              ),
              suffixIcon: _partieController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      tooltip: 'Effacer',
                      onPressed: () {
                        _partieController.clear();
                        setState(() => _selectedParties.clear());
                        _sync();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusInput),
                borderSide: BorderSide(
                  color:
                      isDark ? AppColors.darkBorder : AppColors.inputBorder,
                ),
              ),
              helperText:
                  'Vous pouvez saisir librement vos propres parties ou modifier celles sélectionnées.',
              helperStyle: TextStyle(
                fontSize: 11,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
          ),

          const SizedBox(height: AppDimensions.space20),

          // 2. Usages rapportés
          Text(
            'Usage traditionnel rapporté *',
            style: (isDark ? AppTextStyles.bodyDark : AppTextStyles.body)
                .copyWith(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 6),
          FormattingToolbarWidget(
            controller: _usageController,
            onChanged: _sync,
            label: 'Outils de mise en forme',
          ),
          TextField(
            controller: _usageController,
            maxLines: 3,
            style: isDark ? AppTextStyles.bodyDark : AppTextStyles.body,
            decoration: InputDecoration(
              hintText: 'Décrivez l’indication principale telle que transmise par le praticien...',
              hintStyle: (isDark ? AppTextStyles.bodyDark : AppTextStyles.body)
                  .copyWith(color: isDark ? AppColors.darkTextMuted : AppColors.textMuted),
              filled: true,
              fillColor: isDark ? AppColors.darkSurface : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
                borderSide: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.inputBorder,
                ),
              ),
            ),
          ),

          const SizedBox(height: AppDimensions.space20),

          // 3. Mode de préparation
          Text(
            'Mode de préparation & Administration *',
            style: (isDark ? AppTextStyles.bodyDark : AppTextStyles.body)
                .copyWith(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 6),
          // Suggestions rapides
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _preparationSuggestions.map((prep) {
                return Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: ActionChip(
                    label: Text(prep, style: const TextStyle(fontSize: 11)),
                    backgroundColor: isDark
                        ? AppColors.darkSurfaceVariant
                        : AppColors.primary.withValues(alpha: 0.08),
                    onPressed: () {
                      _preparationController.text = prep;
                      _sync();
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          FormattingToolbarWidget(
            controller: _preparationController,
            onChanged: _sync,
            label: 'Outils de mise en forme',
          ),
          TextField(
            controller: _preparationController,
            maxLines: 2,
            style: isDark ? AppTextStyles.bodyDark : AppTextStyles.body,
            decoration: InputDecoration(
              hintText: 'Ex: Faire bouillir 1 poignée de feuilles séchées dans 1L d’eau pendant 15 min.',
              hintStyle: (isDark ? AppTextStyles.bodyDark : AppTextStyles.body)
                  .copyWith(color: isDark ? AppColors.darkTextMuted : AppColors.textMuted),
              filled: true,
              fillColor: isDark ? AppColors.darkSurface : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
                borderSide: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.inputBorder,
                ),
              ),
            ),
          ),

          const SizedBox(height: AppDimensions.space20),

          // 4. Précautions et contre-indications
          Text(
            'Précautions, posologie & contre-indications',
            style: (isDark ? AppTextStyles.bodyDark : AppTextStyles.body)
                .copyWith(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 6),
          FormattingToolbarWidget(
            controller: _precautionController,
            onChanged: _sync,
            label: 'Outils de mise en forme',
          ),
          TextField(
            controller: _precautionController,
            maxLines: 2,
            style: isDark ? AppTextStyles.bodyDark : AppTextStyles.body,
            decoration: InputDecoration(
              hintText: 'Ex: Déconseillé aux femmes enceintes et aux nourrissons. Ne pas dépasser 2 verres/jour.',
              hintStyle: (isDark ? AppTextStyles.bodyDark : AppTextStyles.body)
                  .copyWith(color: isDark ? AppColors.darkTextMuted : AppColors.textMuted),
              filled: true,
              fillColor: isDark ? AppColors.darkSurface : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
                borderSide: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.inputBorder,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
