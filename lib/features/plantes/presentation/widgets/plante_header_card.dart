import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/image_utils.dart';
import '../../../../shared/widgets/feedback/medical_disclaimer_banner.dart';
import '../../../../shared/widgets/formatted_html_text.dart';
import '../../models/plante_model.dart';

class PlanteHeaderCard extends StatelessWidget {
  final PopulationPlanteDetailModel plante;

  const PlanteHeaderCard({super.key, required this.plante});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Photo principale ou placeholder
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          child: Container(
            height: 220,
            width: double.infinity,
            color: isDark ? AppColors.darkSurface : AppColors.surfaceVariant,
            child: _buildHeaderImage(isDark),
          ),
        ),
        const SizedBox(height: AppDimensions.space16),

        // Nom scientifique (texte standard)
        Text(
          plante.nomScientifique,
          style: (isDark ? AppTextStyles.h1Dark : AppTextStyles.h1).copyWith(
            color: isDark ? AppColors.darkPrimary : AppColors.primary,
          ),
        ),

        // Noms vernaculaires
        if (plante.nomsVernaculaires.isNotEmpty) ...[
          const SizedBox(height: AppDimensions.space8),
          Wrap(
            spacing: AppDimensions.space8,
            runSpacing: AppDimensions.space4,
            children: plante.nomsVernaculaires.map((v) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.space8,
                  vertical: AppDimensions.space4,
                ),
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.darkPrimary : AppColors.primary)
                      .withAlpha(25),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusBadge),
                  border: Border.all(
                    color: (isDark ? AppColors.darkPrimary : AppColors.primary)
                        .withAlpha(60),
                  ),
                ),
                child: Text(
                  v.langue.trim().isNotEmpty
                      ? '${v.nom} (${v.langue})'
                      : v.nom,
                  style: (isDark ? AppTextStyles.captionDark : AppTextStyles.caption)
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              );
            }).toList(),
          ),
        ],

        // Description avec toggle Voir plus / Voir moins
        if (plante.description.isNotEmpty) ...[
          const SizedBox(height: AppDimensions.space12),
          _CardExpandableDescription(
            text: plante.description,
            isDark: isDark,
          ),
        ],

        // Avertissement médical officiel
        const SizedBox(height: AppDimensions.space16),
        const MedicalDisclaimerBanner(compact: false),
      ],
    );
  }

  Widget _buildHeaderImage(bool isDark) {
    final resolvedUrl = ImageUtils.resolveImageUrl(plante.photoUrl);
    if (resolvedUrl != null && resolvedUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: resolvedUrl,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          color: isDark ? AppColors.darkSurfaceVariant : Colors.grey.shade100,
          child: const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
            ),
          ),
        ),
        errorWidget: (_, __, ___) => _buildPlaceholder(isDark),
      );
    }
    return _buildPlaceholder(isDark);
  }

  Widget _buildPlaceholder(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.eco_rounded,
            size: 64,
            color: isDark ? AppColors.darkPrimary : AppColors.primary,
          ),
          const SizedBox(height: AppDimensions.space8),
          Text(
            'Flore Médicinale Malienne',
            style: (isDark ? AppTextStyles.captionDark : AppTextStyles.caption)
                .copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _CardExpandableDescription extends StatefulWidget {
  final String text;
  final bool isDark;

  const _CardExpandableDescription({
    required this.text,
    required this.isDark,
  });

  @override
  State<_CardExpandableDescription> createState() =>
      _CardExpandableDescriptionState();
}

class _CardExpandableDescriptionState
    extends State<_CardExpandableDescription> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final style =
        (widget.isDark ? AppTextStyles.bodyDark : AppTextStyles.body).copyWith(
      fontSize: 14.5,
      height: 1.55,
    );

    final bool canExpand =
        FormattedHtmlText.stripHtml(widget.text).trim().length > 120;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          alignment: Alignment.topLeft,
          child: FormattedHtmlText(
            widget.text,
            style: style,
            maxLines: (_isExpanded || !canExpand) ? null : 3,
            overflow: (_isExpanded || !canExpand)
                ? TextOverflow.visible
                : TextOverflow.ellipsis,
          ),
        ),
        if (canExpand) ...[
          const SizedBox(height: 6),
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _isExpanded ? 'Voir moins' : 'Lire la suite',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: widget.isDark
                          ? AppColors.accent
                          : AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: widget.isDark
                        ? AppColors.accent
                        : AppColors.primary,
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
