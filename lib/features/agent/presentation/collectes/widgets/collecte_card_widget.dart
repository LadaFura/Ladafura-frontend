import 'package:flutter/material.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_colors.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_dimensions.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_text_styles.dart';
import 'package:ladafura_frontend_flutter/features/collectes/models/agent_collecte_summary_response.dart';

/// Carte représentant une collecte dans la liste de l'agent.
class CollecteCardWidget extends StatelessWidget {
  final AgentCollecteSummaryResponse collecte;
  final VoidCallback onTap;

  const CollecteCardWidget({
    super.key,
    required this.collecte,
    required this.onTap,
  });

  Color _getStatusColor(dynamic statut) {
    final s = statut?.toString().toUpperCase() ?? '';
    if (s.contains('VALIDEE')) return Colors.green;
    if (s.contains('REJETEE')) return AppColors.danger;
    if (s.contains('SOUMISE') || s.contains('EXAMEN')) return Colors.amber.shade800;
    return Colors.blueGrey;
  }

  String _formatStatut(dynamic statut) {
    final s = statut?.toString().toUpperCase() ?? '';
    if (s.contains('VALIDEE')) return 'VALIDÉE';
    if (s.contains('REJETEE')) return 'REJETÉE';
    if (s.contains('SOUMISE')) return 'SOUMISE';
    if (s.contains('EXAMEN')) return 'EN EXAMEN';
    return 'BROUILLON';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = _getStatusColor(collecte.statut);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.space16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.inputBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ligne supérieure : Titre & Badge Statut
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    collecte.nomScientifiquePlante != null &&
                            collecte.nomScientifiquePlante!.isNotEmpty
                        ? collecte.nomScientifiquePlante!
                        : 'Collecte #${collecte.id}',
                    style: (isDark ? AppTextStyles.bodyDark : AppTextStyles.body)
                        .copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      fontStyle: collecte.nomScientifiquePlante != null
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    _formatStatut(collecte.statut),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),

            if (collecte.description != null && collecte.description!.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                collecte.description!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: (isDark
                        ? AppTextStyles.captionDark
                        : AppTextStyles.caption)
                    .copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],

            const SizedBox(height: 8),

            // Source & Localisation
            Row(
              children: [
                if (collecte.nomSource != null) ...[
                  const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      collecte.nomSource!,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                if (collecte.region != null) ...[
                  const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      '${collecte.region}${collecte.localite != null ? " • ${collecte.localite!}" : ""}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),

            // Médias indicators
            const SizedBox(height: 10),
            Row(
              children: [
                if (collecte.photoUrl != null && collecte.photoUrl!.isNotEmpty) ...[
                  const Icon(Icons.photo_camera, size: 14, color: AppColors.primary),
                  const SizedBox(width: 4),
                  const Text('Photo', style: TextStyle(fontSize: 11, color: AppColors.primary)),
                  const SizedBox(width: 8),
                ],
                if (collecte.audioUrl != null && collecte.audioUrl!.isNotEmpty) ...[
                  const Icon(Icons.mic, size: 14, color: Colors.green),
                  const SizedBox(width: 4),
                  const Text('Audio', style: TextStyle(fontSize: 11, color: Colors.green)),
                  const SizedBox(width: 8),
                ],
                const Spacer(),
                const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
