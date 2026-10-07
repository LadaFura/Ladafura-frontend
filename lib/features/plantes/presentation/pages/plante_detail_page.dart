import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../shared/widgets/feedback/app_loading_indicator.dart';
import '../../../../shared/widgets/feedback/medical_disclaimer_banner.dart';
import '../../../panier/providers/panier_provider.dart';
import '../../models/plante_model.dart';
import '../../providers/plante_provider.dart';
import '../widgets/connaissances_traditionnelles_card.dart';
import '../widgets/etudes_scientifiques_card.dart';
import '../widgets/plante_audio_player_card.dart';
import '../widgets/plante_detail_hero_header.dart';
import '../widgets/plante_galerie_medias_section.dart';
import '../widgets/plante_localites_section.dart';
import '../widgets/plante_maladies_section.dart';
import '../widgets/plante_produits_associes_widget.dart';

/// Page « Détail Plante » moderne, ergonomique et immersive (UI/UX 2026).
///
/// Respecte scrupuleusement :
/// 1. Photo grand format, nom scientifique, noms vernaculaires locaux.
/// 2. Audio prioritaire placé en 2e/3e position (lecteur audio moderne avec waveform et commande Play/Pause).
/// 3. Distinction stricte entre savoirs traditionnels et études scientifiques documentées.
/// 4. Sections visuelles structurées : Savoirs traditionnels, Études scientifiques, Maladies & Symptômes,
///    Produits dérivés certifiés avec pharmacopées disponibles, Répartition géographique et Médias de terrain.
/// 5. Animations légères et fluides avec onglets de filtrage rapide.
class PlanteDetailPage extends ConsumerStatefulWidget {
  final int planteId;

  const PlanteDetailPage({
    super.key,
    required this.planteId,
  });

  @override
  ConsumerState<PlanteDetailPage> createState() => _PlanteDetailPageState();
}

class _PlanteDetailPageState extends ConsumerState<PlanteDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  void _toggleFavorite() {
    setState(() => _isFavorite = !_isFavorite);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isFavorite
              ? 'Plante ajoutée à votre herbier personnel'
              : 'Plante retirée de votre herbier',
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleShare(PopulationPlanteDetailModel plante) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Partage de la fiche de ${plante.nomScientifique}',
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final planteAsync = ref.watch(planteDetailProvider(widget.planteId));
    final panierItems = ref.watch(panierProvider);
    final nombreArticlesPanier =
        panierItems.fold<int>(0, (sum, item) => sum + item.quantite);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        top: false,
        child: planteAsync.when(
          loading: () => const Center(child: AppLoadingIndicator()),
          error: (err, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.space24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded,
                      color: AppColors.danger, size: 48),
                  const SizedBox(height: AppDimensions.space12),
                  Text(
                    'Impossible de charger la fiche de cette plante',
                    style: isDark ? AppTextStyles.h3Dark : AppTextStyles.h3,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimensions.space16),
                  ElevatedButton.icon(
                    onPressed: () =>
                        ref.refresh(planteDetailProvider(widget.planteId)),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
          ),
          data: (plante) {
            if (plante == null) {
              return const Center(child: Text('Plante introuvable'));
            }

            return _buildContent(context, plante, isDark);
          },
        ),
      ),
      floatingActionButton: nombreArticlesPanier > 0
          ? FloatingActionButton.extended(
              heroTag: 'fab_plante_panier',
              onPressed: () {
                context.push(RouteNames.citizenPanierViewPath);
              },
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: Badge(
                label: Text('$nombreArticlesPanier'),
                child: const Icon(Icons.shopping_bag_outlined),
              ),
              label: const Text(
                'Mon Panier',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          : null,
    );
  }

  Widget _buildContent(
    BuildContext context,
    PopulationPlanteDetailModel plante,
    bool isDark,
  ) {
    // 1. Détection de l'audio prioritaire : soit dans les médias (AUDIO_TERRAIN), soit dans les noms vernaculaires
    final audioMedia = plante.medias.cast<PopulationPlanteMediaModel?>().firstWhere(
          (m) =>
              m != null &&
              (m.typeMedia == 'AUDIO_TERRAIN' ||
                  m.typeMedia == 'AUDIO' ||
                  m.url.toLowerCase().endsWith('.mp3') ||
                  m.url.toLowerCase().endsWith('.m4a') ||
                  m.url.toLowerCase().endsWith('.wav') ||
                  m.url.toLowerCase().endsWith('.ogg')),
          orElse: () => null,
        );

    final vernaculaireAvecAudio =
        plante.nomsVernaculaires.cast<PopulationNomVernaculaireModel?>().firstWhere(
              (n) => n != null && n.audioUrl != null && n.audioUrl!.trim().isNotEmpty,
              orElse: () => null,
            );

    final audioUrl = audioMedia?.url ?? vernaculaireAvecAudio?.audioUrl;
    final audioTitle = vernaculaireAvecAudio != null
        ? 'Prononciation : ${vernaculaireAvecAudio.nom}'
        : 'Prononciation & Témoignage oral';
    final audioLanguage = vernaculaireAvecAudio?.langue ?? 'Mali';

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.only(
            left: AppDimensions.space16,
            right: AppDimensions.space16,
            top: MediaQuery.of(context).padding.top + AppDimensions.space12,
            bottom: AppDimensions.space32,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // 1. EN-TÊTE IMMERSIF (Photo haute définition, Nom botanique, Noms locaux)
              PlanteDetailHeroHeader(
                plante: plante,
                onBack: _handleBack,
                onShare: () => _handleShare(plante),
                onFavorite: _toggleFavorite,
                isFavorite: _isFavorite,
              ),

              const SizedBox(height: AppDimensions.space16),

              // 2. AUDIO PRIORITAIRE (2e/3e position : immédiatement sous l'en-tête)
              if (audioUrl != null && audioUrl.isNotEmpty) ...[
                PlanteAudioPlayerCard(
                  audioUrl: audioUrl,
                  title: audioTitle,
                  subtitle: audioMedia?.description ??
                      'Écouter l\'accent et l\'appellation vernaculaire authentique',
                  languageTag: audioLanguage,
                ),
                const SizedBox(height: AppDimensions.space16),
              ] else ...[
                // Si pas d'audio enregistré sur le serveur, présenter une puce d'information sobre
                _buildAudioEmptyPlaceholder(isDark),
                const SizedBox(height: AppDimensions.space16),
              ],

              // 3. AVERTISSEMENT MÉDICAL DÉONTOLOGIQUE
              const MedicalDisclaimerBanner(compact: false),

              const SizedBox(height: AppDimensions.space20),

              // 4. SÉLECTEUR D'ONGLETS STYLISÉ (Savoirs traditionnels VS Études scientifiques)
              _buildSegmentedTabSelector(plante, isDark),

              const SizedBox(height: AppDimensions.space16),

              // Contenu de l'onglet actif (animé avec AnimatedBuilder sur le TabController)
              AnimatedBuilder(
                animation: _tabController,
                builder: (context, _) {
                  if (_tabController.index == 0) {
                    return ConnaissancesTraditionnellesCard(
                      connaissances: plante.connaissancesTraditionnelles,
                    );
                  } else {
                    return EtudesScientifiquesCard(
                      etudes: plante.etudesScientifiques,
                    );
                  }
                },
              ),

              const SizedBox(height: AppDimensions.space24),

              // 5. INDICATIONS & MALADIES ASSOCIÉES
              if (plante.maladiesAssociees.isNotEmpty) ...[
                PlanteMaladiesSection(
                  maladies: plante.maladiesAssociees,
                ),
                const SizedBox(height: AppDimensions.space24),
              ],

              // 6. PRODUITS TRADITIONNELS ASSOCIÉS & DISPONIBILITÉS OFFICINES
              PlanteProduitsAssociesWidget(
                planteId: plante.id,
                nomPlante: plante.nomScientifique,
              ),

              const SizedBox(height: AppDimensions.space24),

              // 7. RÉPARTITION GÉOGRAPHIQUE AU MALI
              if (plante.localites.isNotEmpty) ...[
                PlanteLocalitesSection(
                  localites: plante.localites,
                ),
                const SizedBox(height: AppDimensions.space24),
              ],

              // 8. GALERIE & PHOTOS DE TERRAIN
              if (plante.medias.isNotEmpty) ...[
                PlanteGalerieMediasSection(
                  medias: plante.medias,
                ),
                const SizedBox(height: AppDimensions.space24),
              ],
            ]),
          ),
        ),
      ],
    );
  }

  /// Sélecteur d'onglets ergonomique en pilule pour basculer facilement entre
  /// les connaissances traditionnelles et les études scientifiques sans défilement fastidieux.
  Widget _buildSegmentedTabSelector(
    PopulationPlanteDetailModel plante,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              index: 0,
              icon: Icons.history_edu_rounded,
              label: 'Savoirs Traditionnels',
              badgeCount: plante.connaissancesTraditionnelles.length,
              isDark: isDark,
            ),
          ),
          Expanded(
            child: _buildTabButton(
              index: 1,
              icon: Icons.biotech_rounded,
              label: 'Études Scientifiques',
              badgeCount: plante.etudesScientifiques.length,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required int index,
    required IconData icon,
    required String label,
    required int badgeCount,
    required bool isDark,
  }) {
    final isSelected = _tabController.index == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _tabController.animateTo(index);
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.darkAccent : AppColors.primary)
              : Colors.transparent,
          borderRadius:
              BorderRadius.circular(AppDimensions.radiusCard - 2),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: (isDark
                            ? AppColors.darkAccent
                            : AppColors.primary)
                        .withAlpha(50),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? Colors.white
                  : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: (isDark
                        ? AppTextStyles.captionDark
                        : AppTextStyles.caption)
                    .copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  fontSize: 12,
                  color: isSelected
                      ? Colors.white
                      : (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (badgeCount > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withAlpha(60)
                      : (isDark
                              ? AppColors.darkSurfaceVariant
                              : AppColors.surface)
                          .withAlpha(200),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusBadge),
                ),
                child: Text(
                  badgeCount.toString(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? Colors.white
                        : (isDark
                            ? AppColors.darkAccent
                            : AppColors.primary),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAudioEmptyPlaceholder(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space16,
        vertical: AppDimensions.space12,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.mic_none_rounded,
            color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
            size: 22,
          ),
          const SizedBox(width: AppDimensions.space12),
          Expanded(
            child: Text(
              'Enregistrement audio en cours de numérisation par nos ethnobotanistes.',
              style: (isDark
                      ? AppTextStyles.captionDark
                      : AppTextStyles.caption)
                  .copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textMuted,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
