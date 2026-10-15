import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/services/services_providers.dart';

/// Formulaire de coordonnées de livraison propre, moderne et épuré.
class CommandeLivraisonForm extends ConsumerStatefulWidget {
  final TextEditingController adresseController;
  final TextEditingController telephoneController;
  final TextEditingController notesController;
  final String? adresseError;
  final String? telephoneError;

  const CommandeLivraisonForm({
    super.key,
    required this.adresseController,
    required this.telephoneController,
    required this.notesController,
    this.adresseError,
    this.telephoneError,
  });

  @override
  ConsumerState<CommandeLivraisonForm> createState() =>
      _CommandeLivraisonFormState();
}

class _CommandeLivraisonFormState extends ConsumerState<CommandeLivraisonForm> {
  bool _isLoadingGps = false;

  Future<void> _detecterAdresseAutomatique() async {
    setState(() => _isLoadingGps = true);

    try {
      final locationService = ref.read(locationServiceProvider);
      final coords = await locationService.requestPositionWithPermission();

      if (coords == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Impossible de récupérer votre position GPS. Veuillez vérifier vos autorisations.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
          setState(() => _isLoadingGps = false);
        }
        return;
      }

      final resolvedAddress = await locationService.reverseGeocode(
        latitude: coords.latitude,
        longitude: coords.longitude,
      );

      if (mounted) {
        setState(() {
          _isLoadingGps = false;
          widget.adresseController.text = resolvedAddress;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Position GPS détectée avec succès !'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingGps = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la localisation : $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.space16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusModal),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
          width: AppDimensions.cardBorderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.08 : 0.03),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre épuré sans icône scooter
          Text(
            'Coordonnées de livraison',
            style: (isDark ? AppTextStyles.h4Dark : AppTextStyles.h4)
                .copyWith(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 14),

          // 1. Champ Adresse de livraison avec bouton GPS discret intégré
          TextField(
            controller: widget.adresseController,
            decoration: InputDecoration(
              labelText: 'Adresse complète de livraison *',
              hintText: 'Ex: Badalabougou, Rue 24, Porte 12, Bamako',
              prefixIcon: const Icon(Icons.location_on_outlined, size: 20),
              suffixIcon: IconButton(
                icon: _isLoadingGps
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location_rounded, size: 20),
                tooltip: 'Détecter automatiquement par GPS',
                onPressed: _isLoadingGps ? null : _detecterAdresseAutomatique,
              ),
              errorText: widget.adresseError,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 14),

          // 2. Champ Téléphone du destinataire (propre, sans tag Obligatoire ni texte d'aide superflu)
          TextField(
            controller: widget.telephoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Téléphone du destinataire *',
              hintText: 'Ex: +223 70 12 34 56',
              prefixIcon: const Icon(Icons.phone_outlined, size: 20),
              errorText: widget.telephoneError,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 3. Instructions complémentaires (optionnel)
          TextField(
            controller: widget.notesController,
            decoration: InputDecoration(
              labelText: 'Instructions complémentaires (optionnel)',
              hintText: 'Ex: Appeler avant d\'arriver, portail vert...',
              prefixIcon: const Icon(Icons.notes_rounded, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}
