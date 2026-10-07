import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/services/services_providers.dart';

/// Formulaire de livraison avec prise d'adresse automatique (GPS) ou manuelle,
/// et numéro de téléphone de contact obligatoire.
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
  bool _isAutoMode = false;
  bool _isLoadingGps = false;
  String? _autoDetectedAddress;

  Future<void> _detecterAdresseAutomatique() async {
    setState(() {
      _isLoadingGps = true;
      _isAutoMode = true;
    });

    try {
      final locationService = ref.read(locationServiceProvider);
      final coords = await locationService.requestPositionWithPermission();

      if (coords == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Impossible de récupérer votre position GPS. Veuillez vérifier vos autorisations ou utiliser la saisie manuelle.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
          setState(() {
            _isLoadingGps = false;
            _isAutoMode = false;
          });
        }
        return;
      }

      // Reverse-geocoding via OpenStreetMap / Mali bounds
      final resolvedAddress = await locationService.reverseGeocode(
        latitude: coords.latitude,
        longitude: coords.longitude,
      );

      if (mounted) {
        setState(() {
          _isLoadingGps = false;
          _autoDetectedAddress = resolvedAddress;
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
        setState(() {
          _isLoadingGps = false;
          _isAutoMode = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la localisation : $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _basculerManuel() {
    setState(() {
      _isAutoMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkAccent : AppColors.primary;

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
          // Titre de la section
          Row(
            children: [
              Icon(Icons.delivery_dining_rounded, color: primaryColor, size: 22),
              const SizedBox(width: 8),
              Text(
                'Coordonnées de livraison',
                style: (isDark ? AppTextStyles.h4Dark : AppTextStyles.h4)
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 1. Boutons de sélection du mode d'adresse (Automatique vs Manuelle)
          Text(
            'Mode de définition de l\'adresse *',
            style: (isDark ? AppTextStyles.captionDark : AppTextStyles.caption)
                .copyWith(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Bouton Adresse Automatique (GPS)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isLoadingGps ? null : _detecterAdresseAutomatique,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: _isAutoMode
                        ? primaryColor.withAlpha(20)
                        : Colors.transparent,
                    side: BorderSide(
                      color: _isAutoMode
                          ? primaryColor
                          : (isDark ? AppColors.darkBorder : AppColors.border),
                      width: _isAutoMode ? 2 : 1,
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: _isLoadingGps
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          Icons.my_location_rounded,
                          color: _isAutoMode
                              ? primaryColor
                              : (isDark ? Colors.white70 : Colors.black87),
                          size: 18,
                        ),
                  label: Text(
                    'Prendre auto (GPS)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: _isAutoMode ? FontWeight.bold : FontWeight.w500,
                      color: _isAutoMode
                          ? primaryColor
                          : (isDark ? Colors.white70 : Colors.black87),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Bouton Saisie Manuelle
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isLoadingGps ? null : _basculerManuel,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: !_isAutoMode
                        ? primaryColor.withAlpha(20)
                        : Colors.transparent,
                    side: BorderSide(
                      color: !_isAutoMode
                          ? primaryColor
                          : (isDark ? AppColors.darkBorder : AppColors.border),
                      width: !_isAutoMode ? 2 : 1,
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: Icon(
                    Icons.edit_note_rounded,
                    color: !_isAutoMode
                        ? primaryColor
                        : (isDark ? Colors.white70 : Colors.black87),
                    size: 20,
                  ),
                  label: Text(
                    'Saisie manuelle',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: !_isAutoMode ? FontWeight.bold : FontWeight.w500,
                      color: !_isAutoMode
                          ? primaryColor
                          : (isDark ? Colors.white70 : Colors.black87),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 2. Affichage / Saisie de l'adresse selon le mode
          if (_isAutoMode && _autoDetectedAddress != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withAlpha(15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withAlpha(80)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          color: Colors.green, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'Position GPS détectée automatiquement :',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.greenAccent : Colors.green[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _autoDetectedAddress!,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _detecterAdresseAutomatique,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.refresh_rounded, size: 14, color: primaryColor),
                        const SizedBox(width: 4),
                        Text(
                          'Réactualiser la position',
                          style: TextStyle(
                            fontSize: 11,
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Champ complément d'adresse (repère / porte)
            TextField(
              controller: widget.adresseController,
              decoration: InputDecoration(
                labelText: 'Complément d\'adresse / Repère (optionnel)',
                hintText: 'Ex: Porte 12, près du grand marché, étage...',
                prefixIcon: const Icon(Icons.pin_drop_outlined, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 2,
            ),
          ] else ...[
            // Champ Saisie manuelle classique
            TextField(
              controller: widget.adresseController,
              decoration: InputDecoration(
                labelText: 'Adresse complète de livraison *',
                hintText: 'Ex: Badalabougou, Rue 24, Porte 12, Bamako',
                prefixIcon: const Icon(Icons.location_on_outlined, size: 20),
                errorText: widget.adresseError,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 2,
            ),
          ],
          const SizedBox(height: 16),

          // 3. Numéro de téléphone de contact (OBLIGATOIRE)
          Row(
            children: [
              Text(
                'Numéro de téléphone de contact *',
                style: (isDark ? AppTextStyles.captionDark : AppTextStyles.caption)
                    .copyWith(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withAlpha(25),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Obligatoire',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: widget.telephoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Téléphone du destinataire *',
              hintText: 'Ex: +223 70 12 34 56',
              prefixIcon: const Icon(Icons.phone_outlined, size: 20),
              errorText: widget.telephoneError,
              helperText:
                  'Indispensable pour que le livreur puisse vous joindre à l\'arrivée.',
              helperStyle: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 4. Instructions complémentaires pour la livraison (Optionnel)
          TextField(
            controller: widget.notesController,
            decoration: InputDecoration(
              labelText: 'Instructions complémentaires (optionnel)',
              hintText: 'Ex: Appeler avant d\'arriver, portail vert...',
              prefixIcon: const Icon(Icons.notes_rounded, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
