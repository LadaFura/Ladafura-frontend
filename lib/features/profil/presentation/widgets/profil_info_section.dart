import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../models/profil_model.dart';

/// Section affichant les coordonnées de l'utilisateur (Nom, Prénom, Téléphone, Email)
/// et le bouton d'accès à la modification.
class ProfilInfoSection extends StatelessWidget {
  final ProfilModel? profil;
  final VoidCallback onModifier;

  const ProfilInfoSection({
    super.key,
    required this.profil,
    required this.onModifier,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.space16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.badge_outlined, color: primaryColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Mes informations',
                    style: (isDark ? AppTextStyles.h3Dark : AppTextStyles.h3)
                        .copyWith(fontSize: 16),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: onModifier,
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Modifier', style: TextStyle(fontSize: 13)),
              ),
            ],
          ),
          const Divider(height: 16),

          // Ligne Nom
          _InfoRow(
            icon: Icons.person_outline_rounded,
            label: 'Nom',
            value: profil?.nom.isNotEmpty == true ? profil!.nom : '—',
          ),
          const SizedBox(height: 10),

          // Ligne Prénom
          _InfoRow(
            icon: Icons.badge_rounded,
            label: 'Prénom',
            value: profil?.prenom.isNotEmpty == true ? profil!.prenom : '—',
          ),
          const SizedBox(height: 10),

          // Ligne Téléphone
          _InfoRow(
            icon: Icons.phone_outlined,
            label: 'Téléphone',
            value: profil?.telephone?.isNotEmpty == true
                ? profil!.telephone!
                : 'Non renseigné',
            isPlaceholder: profil?.telephone?.isNotEmpty != true,
          ),
          const SizedBox(height: 10),

          // Ligne Email
          _InfoRow(
            icon: Icons.email_outlined,
            label: 'Email',
            value: profil?.email.isNotEmpty == true ? profil!.email : '—',
          ),
          const SizedBox(height: 14),

          // Bouton d'action principal de modification
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onModifier,
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryColor,
                side: BorderSide(color: primaryColor),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusButton),
                ),
              ),
              icon: const Icon(Icons.edit_note_rounded, size: 20),
              label: const Text(
                'Modifier mon profil',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isPlaceholder;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isPlaceholder = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textMuted),
        const SizedBox(width: 8),
        SizedBox(
          width: 85,
          child: Text(
            label,
            style: (isDark ? AppTextStyles.captionDark : AppTextStyles.caption)
                .copyWith(fontSize: 13),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isPlaceholder
                  ? Colors.orange
                  : (isDark ? Colors.white : Colors.black87),
              fontStyle: isPlaceholder ? FontStyle.italic : FontStyle.normal,
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

