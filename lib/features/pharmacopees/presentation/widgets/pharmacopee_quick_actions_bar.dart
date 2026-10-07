import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/utils/map_navigation_utils.dart';
import '../../../../core/utils/phone_call_utils.dart';
import '../../models/pharmacopee_detail_model.dart';

/// Barre d'actions rapides moderne et ergonomique pour la fiche pharmacopée :
/// 📞 Appeler (ouvre le téléphone directement avec numéro prérempli)
/// 📍 Itinéraire (ouvre Google Maps / Plans externe avec itinéraire direct)
/// ⭐ Donner un avis (ouvre la modal d'évaluation)
class PharmacopeeQuickActionsBar extends StatelessWidget {
  final PharmacopeeDetailModel pharmacopee;
  final GeoCoordinates? userCoordinates;
  final VoidCallback onDonnerAvis;

  const PharmacopeeQuickActionsBar({
    super.key,
    required this.pharmacopee,
    this.userCoordinates,
    required this.onDonnerAvis,
  });

  void _onAppeler(BuildContext context) async {
    final phone = pharmacopee.telephone?.trim();
    if (phone == null || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucun numéro de téléphone disponible pour cette pharmacopée.'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    final success = await PhoneCallUtils.makePhoneCall(phone);
    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Impossible de lancer l\'appel vers $phone'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _onItineraire(BuildContext context) async {
    final lat = pharmacopee.latitude;
    final lng = pharmacopee.longitude;

    if (!MapNavigationUtils.areCoordinatesValid(lat, lng)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Les coordonnées GPS de cette pharmacopée ne sont pas renseignées.'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    final success = await MapNavigationUtils.openDirections(
      destLat: lat!,
      destLng: lng!,
      destName: pharmacopee.nom,
      userCoords: userCoordinates,
    );

    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d\'ouvrir l\'application de cartographie.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasPhone = pharmacopee.telephone != null && pharmacopee.telephone!.trim().isNotEmpty;
    final hasCoords = MapNavigationUtils.areCoordinatesValid(pharmacopee.latitude, pharmacopee.longitude);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.space16),
      padding: const EdgeInsets.all(AppDimensions.space12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 30 : 10),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // 1. Bouton APPELER
          Expanded(
            child: _ActionButton(
              icon: Icons.phone_in_talk_rounded,
              label: 'Appeler',
              color: hasPhone ? AppColors.primary : Colors.grey,
              bgColor: hasPhone
                  ? (isDark ? AppColors.darkPrimaryContainer.withAlpha(80) : AppColors.primaryLight)
                  : (isDark ? Colors.white10 : Colors.grey.shade100),
              isEnabled: hasPhone,
              onTap: () => _onAppeler(context),
            ),
          ),
          const SizedBox(width: 8),

          // 2. Bouton ITINÉRAIRE
          Expanded(
            child: _ActionButton(
              icon: Icons.directions_rounded,
              label: 'Itinéraire',
              color: hasCoords ? const Color(0xFF2563EB) : Colors.grey,
              bgColor: hasCoords
                  ? (isDark ? const Color(0xFF1E3A8A).withAlpha(80) : const Color(0xFFEFF6FF))
                  : (isDark ? Colors.white10 : Colors.grey.shade100),
              isEnabled: hasCoords,
              onTap: () => _onItineraire(context),
            ),
          ),
          const SizedBox(width: 8),

          // 3. Bouton DONNER UN AVIS
          Expanded(
            child: _ActionButton(
              icon: Icons.star_rate_rounded,
              label: 'Donner avis',
              color: AppColors.accent,
              bgColor: isDark ? const Color(0xFF78350F).withAlpha(80) : const Color(0xFFFEF3C7),
              isEnabled: true,
              onTap: onDonnerAvis,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
  final bool isEnabled;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
    required this.isEnabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 22, color: color),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
