import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../shared/widgets/feedback/app_loading_indicator.dart';
import '../../../../shared/widgets/formatted_html_text.dart';
import '../../../panier/providers/panier_provider.dart';
import '../../models/plante_model.dart';
import '../../providers/plante_provider.dart';
import '../widgets/plante_audio_player_card.dart';
import '../widgets/plante_detail_hero_header.dart';
import '../widgets/plante_produits_associes_widget.dart';

/// Page « Détail Plante » côté population / citoyen.
///
/// Mise en page épurée et moderne par cartes individuelles :
/// - Pas de surcharge de conteneurs imbriqués
/// - En-tête photo & noms locaux avec actions rapides
/// - Lecteur audio prioritaire (si disponible)
/// - Avertissement médical légal positionné au-dessus de la description botanique
/// - Description botanique avec expansion fluide
/// - Sélecteur moderne des 2 options : Traditionnelle & Scientifique
/// - Répartition géographique au Mali
/// - Galerie photos de terrain
/// - Produits certifiés disponibles
class PlanteDetailPage extends ConsumerStatefulWidget {
  final int planteId;

  const PlanteDetailPage({
    super.key,
    required this.planteId,
  });

  @override
  ConsumerState<PlanteDetailPage> createState() => _PlanteDetailPageState();
}

class _PlanteDetailPageState extends ConsumerState<PlanteDetailPage> {
  bool _isFavorite = false;
  int _selectedOption = 0; // 0: Traditionnelle, 1: Scientifique

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
    // Détection de l'audio : soit dans les médias (AUDIO_TERRAIN / AUDIO), soit dans les noms vernaculaires
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

    // Photos de terrain (images uniquement)
    final imageMedias = plante.medias
        .where((m) =>
            m.typeMedia == 'IMAGE' ||
            (!m.url.toLowerCase().endsWith('.mp3') &&
                !m.url.toLowerCase().endsWith('.m4a') &&
                !m.url.toLowerCase().endsWith('.wav') &&
                !m.url.toLowerCase().endsWith('.ogg')))
        .toList();

    return Stack(
      children: [
        RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            ref.invalidate(planteDetailProvider(widget.planteId));
            ref.invalidate(produitsByPlanteProvider(plante.id));
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.only(
                  left: AppDimensions.space16,
                  right: AppDimensions.space16,
                  top: MediaQuery.of(context).padding.top + 56.0,
                  bottom: AppDimensions.space32,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // 1. En-tête immersif (Photo, nom botanique, badges langues locales)
                    PlanteDetailHeroHeader(
                      plante: plante,
                      onBack: _handleBack,
                      onShare: () => _handleShare(plante),
                      onFavorite: _toggleFavorite,
                      isFavorite: _isFavorite,
                      showDescription: false,
                    ),

                    // 2. Témoignage vocal / Audio (uniquement si disponible)
                    if (audioUrl != null && audioUrl.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      PlanteAudioPlayerCard(
                        audioUrl: audioUrl,
                        title: audioTitle,
                        subtitle: audioMedia?.description ??
                            'Écouter l\'accent et l\'appellation vernaculaire authentique',
                        languageTag: audioLanguage,
                      ),
                    ],

                    // 3. Avertissement médical déontologique (au-dessus de la description botanique)
                    const SizedBox(height: 14),
                    _buildMedicalDisclaimerBanner(isDark),

                    // 4. Description botanique (carte épurée avec expansion fluide)
                    if (plante.description.trim().isNotEmpty) ...[
                      const SizedBox(height: 14),
                      _buildModernCard(
                        isDark: isDark,
                        icon: Icons.description_outlined,
                        title: 'Description botanique',
                        child: _ExpandableDescriptionText(
                          text: plante.description,
                          isDark: isDark,
                        ),
                      ),
                    ],

                    // 5. Sélecteur des deux options : Traditionnelle & Scientifique
                    const SizedBox(height: 14),
                    _buildSectionSelector(isDark),

                    const SizedBox(height: 12),
                    if (_selectedOption == 0)
                      _buildSavoirsCard(plante, isDark)
                    else
                      _buildEtudesCard(plante.etudesScientifiques, isDark),

                    // 6. Répartition géographique au Mali
                    if (plante.localites.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      _buildLocalitesCard(plante.localites, isDark),
                    ],

                    // 7. Galerie & Photos de terrain
                    if (imageMedias.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      _buildGalerieCard(imageMedias, isDark),
                    ],

                    // 8. Produits & Formulations Associés
                    const SizedBox(height: 14),
                    PlanteProduitsAssociesWidget(
                      planteId: plante.id,
                      nomPlante: plante.nomScientifique,
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),

        // Barre supérieure flottante persistante (Retour, Partage, Favoris)
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: AppDimensions.space16,
          right: AppDimensions.space16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildFloatingTopButton(
                icon: Icons.arrow_back_ios_new_rounded,
                isDark: isDark,
                onTap: _handleBack,
                tooltip: 'Retour',
              ),
              Row(
                children: [
                  _buildFloatingTopButton(
                    icon: Icons.share_rounded,
                    isDark: isDark,
                    onTap: () => _handleShare(plante),
                    tooltip: 'Partager',
                  ),
                  const SizedBox(width: 8),
                  _buildFloatingTopButton(
                    icon: _isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    iconColor: _isFavorite ? AppColors.danger : null,
                    isDark: isDark,
                    onTap: _toggleFavorite,
                    tooltip: 'Favori',
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Bannière d'avertissement médical conforme aux exigences légales et sanitaires
  Widget _buildMedicalDisclaimerBanner(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2213) : const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF78350F) : const Color(0xFFFDE68A),
          width: 0.9,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(
              Icons.health_and_safety_outlined,
              size: 19,
              color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 12,
                  height: 1.45,
                  color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E),
                ),
                children: const [
                  TextSpan(
                    text: 'Avertissement médical : ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text:
                        'Cet article est fourni à titre informatif uniquement. Il ne remplace pas un avis médical professionnel. Consultez un médecin ou un professionnel de santé qualifié avant d\'utiliser des remèdes à base de plantes, surtout si vous êtes enceinte, allaitez, ou prenez des médicaments.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Sélecteur moderne des 2 options : Traditionnelle & Scientifique
  Widget _buildSectionSelector(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSelectorOption(
              index: 0,
              icon: Icons.history_edu_rounded,
              label: 'Traditionnelle',
              isDark: isDark,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildSelectorOption(
              index: 1,
              icon: Icons.biotech_rounded,
              label: 'Scientifique',
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectorOption({
    required int index,
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    final isSelected = _selectedOption == index;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;

    return GestureDetector(
      onTap: () {
        if (_selectedOption != index) {
          setState(() => _selectedOption = index);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.25),
                    blurRadius: 6,
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
              size: 15,
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.white70 : AppColors.textSecondary),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.white70 : AppColors.textSecondary),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Carte standardisée conforme au style de la fiche agent
  Widget _buildModernCard({
    required bool isDark,
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.space16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.035),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(icon, size: 14, color: AppColors.primary),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildSubLabel(bool isDark, String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
      ),
    );
  }

  Widget _buildInfoRow({
    required bool isDark,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 2),
        FormattedHtmlText(
          value,
          style: (isDark ? AppTextStyles.bodyDark : AppTextStyles.body).copyWith(
            fontSize: 13.5,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  /// Carte des Savoirs & Usages traditionnels
  Widget _buildSavoirsCard(PopulationPlanteDetailModel plante, bool isDark) {
    final hasNoData = plante.maladiesAssociees.isEmpty &&
        plante.connaissancesTraditionnelles.isEmpty;

    if (hasNoData) {
      return _buildModernCard(
        isDark: isDark,
        icon: Icons.history_edu_rounded,
        title: 'Savoirs traditionnels & Usages',
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 20,
                color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Aucun savoir traditionnel documenté pour cette plante pour le moment.',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Regroupement des parties utilisées
    final parties = plante.connaissancesTraditionnelles
        .map((c) => c.partieUtilisee)
        .where((p) => p != null && p.trim().isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();

    return _buildModernCard(
      isDark: isDark,
      icon: Icons.healing_rounded,
      title: 'Savoirs traditionnels & Usages',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Maladies / affections traitées (Badges ambrés)
          if (plante.maladiesAssociees.isNotEmpty) ...[
            _buildSubLabel(isDark, 'Maladies / affections traitées'),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: plante.maladiesAssociees.map((m) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    m.nom,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF92400E),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],

          // 2. Parties utilisées
          if (parties.isNotEmpty) ...[
            _buildInfoRow(
              isDark: isDark,
              label: 'Parties utilisées',
              value: parties.join(', '),
            ),
            const SizedBox(height: 10),
          ],

          // 3. Connaissances détaillées
          if (plante.connaissancesTraditionnelles.isNotEmpty) ...[
            for (int i = 0;
                i < plante.connaissancesTraditionnelles.length;
                i++) ...[
              if (i > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Divider(
                    height: 1,
                    color: isDark ? AppColors.darkBorder : AppColors.border,
                  ),
                ),
              _buildConnaissanceItem(
                plante.connaissancesTraditionnelles[i],
                isDark,
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildConnaissanceItem(
    PopulationConnaissanceTraditionnelleModel item,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (item.usageRapporte.isNotEmpty) ...[
          _buildInfoRow(
            isDark: isDark,
            label: 'Usage rapporté',
            value: item.usageRapporte,
          ),
          const SizedBox(height: 8),
        ],
        if (item.modePreparation != null &&
            item.modePreparation!.trim().isNotEmpty) ...[
          _buildInfoRow(
            isDark: isDark,
            label: 'Préparation & posologie',
            value: item.posologie != null && item.posologie!.trim().isNotEmpty
                ? '${item.modePreparation!}\nPosologie : ${item.posologie!}'
                : item.modePreparation!,
          ),
          const SizedBox(height: 8),
        ] else if (item.posologie != null &&
            item.posologie!.trim().isNotEmpty) ...[
          _buildInfoRow(
            isDark: isDark,
            label: 'Posologie',
            value: item.posologie!,
          ),
          const SizedBox(height: 8),
        ],
        if (item.precautions != null &&
            item.precautions!.trim().isNotEmpty) ...[
          _buildInfoRow(
            isDark: isDark,
            label: 'Précautions d\'usage',
            value: item.precautions!,
          ),
          const SizedBox(height: 8),
        ],
        if (item.sourceNom != null && item.sourceNom!.trim().isNotEmpty) ...[
          Text(
            'Source : ${item.sourceNom!}${item.sourceLocalite != null ? ' (${item.sourceLocalite})' : ''}',
            style: TextStyle(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
            ),
          ),
        ],
      ],
    );
  }

  /// Carte des Études scientifiques
  Widget _buildEtudesCard(
    List<PopulationEtudeScientifiqueModel> etudes,
    bool isDark,
  ) {
    return _buildModernCard(
      isDark: isDark,
      icon: Icons.biotech_rounded,
      title: 'Études & Validations scientifiques',
      child: etudes.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.biotech_outlined,
                    size: 22,
                    color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Aucune étude scientifique documentée n\'a encore été indexée pour cette plante dans la base LADAFURA. Les travaux de recherche sont en cours.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < etudes.length; i++) ...[
                  if (i > 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Divider(
                        height: 1,
                        color: isDark ? AppColors.darkBorder : AppColors.border,
                      ),
                    ),
                  _buildEtudeItem(etudes[i], isDark),
                ],
              ],
            ),
    );
  }

  Widget _buildEtudeItem(PopulationEtudeScientifiqueModel etude, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          etude.titre,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        if (etude.auteurs != null || etude.annee != null || etude.revueOuInstitution != null) ...[
          const SizedBox(height: 2),
          Text(
            [etude.auteurs, etude.annee, etude.revueOuInstitution]
                .where((s) => s != null && s.trim().isNotEmpty)
                .join(' • '),
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
            ),
          ),
        ],
        if (etude.resume != null && etude.resume!.trim().isNotEmpty) ...[
          const SizedBox(height: 6),
          FormattedHtmlText(
            etude.resume!,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
        ],
        if (etude.urlDocument != null && etude.urlDocument!.trim().isNotEmpty) ...[
          const SizedBox(height: 6),
          InkWell(
            onTap: () async {
              final uri = Uri.tryParse(etude.urlDocument!);
              if (uri != null && await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            borderRadius: BorderRadius.circular(4),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.open_in_new_rounded,
                    size: 14, color: AppColors.primary),
                SizedBox(width: 4),
                Text(
                  'Consulter la publication',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// Carte Répartition géographique
  Widget _buildLocalitesCard(
    List<PopulationPlanteLocaliteModel> localites,
    bool isDark,
  ) {
    return _buildModernCard(
      isDark: isDark,
      icon: Icons.location_on_outlined,
      title: 'Répartition géographique (Mali)',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: localites.map((loc) {
          final label = [loc.region, loc.cercle, loc.commune]
              .where((s) => s != null && s.trim().isNotEmpty)
              .join(' • ');

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBackground : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.border,
                width: 0.8,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.place_outlined,
                    size: 14, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  label.isNotEmpty ? label : 'Mali',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Carte Galerie & Médias de terrain
  Widget _buildGalerieCard(
    List<PopulationPlanteMediaModel> medias,
    bool isDark,
  ) {
    return _buildModernCard(
      isDark: isDark,
      icon: Icons.photo_library_outlined,
      title: 'Galerie & Photos de terrain',
      child: SizedBox(
        height: 105,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: medias.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            final media = medias[index];
            return GestureDetector(
              onTap: () => _showImageZoom(context, media.url),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 130,
                  height: 105,
                  child: CachedNetworkImage(
                    imageUrl: media.url,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      color: isDark
                          ? AppColors.darkSurfaceVariant
                          : AppColors.surfaceVariant,
                      child: const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: isDark
                          ? AppColors.darkSurfaceVariant
                          : AppColors.surfaceVariant,
                      child: const Icon(Icons.image_not_supported_outlined,
                          size: 24, color: AppColors.textMuted),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showImageZoom(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(12),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: InteractiveViewer(
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded,
                  color: Colors.white, size: 28),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingTopButton({
    required IconData icon,
    required bool isDark,
    required VoidCallback onTap,
    Color? iconColor,
    String? tooltip,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurface.withValues(alpha: 0.85)
                : Colors.white.withValues(alpha: 0.85),
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: 0.1),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 18,
            color: iconColor ??
                (isDark ? Colors.white : AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}

/// Widget d'expansion/réduction fluide pour les textes longs de description
class _ExpandableDescriptionText extends StatefulWidget {
  final String text;
  final bool isDark;

  const _ExpandableDescriptionText({
    required this.text,
    required this.isDark,
  });

  @override
  State<_ExpandableDescriptionText> createState() =>
      _ExpandableDescriptionTextState();
}

class _ExpandableDescriptionTextState
    extends State<_ExpandableDescriptionText> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final plainText = FormattedHtmlText.stripHtml(widget.text);
    final isLong = plainText.length > 200 || plainText.split('\n').length > 4;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormattedHtmlText(
          widget.text,
          maxLines: _isExpanded ? null : 4,
          overflow:
              _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
          style:
              (widget.isDark ? AppTextStyles.bodyDark : AppTextStyles.body)
                  .copyWith(
            height: 1.5,
            fontSize: 13.5,
          ),
        ),
        if (isLong) ...[
          const SizedBox(height: 6),
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _isExpanded ? 'Voir moins' : 'Lire toute la description',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
