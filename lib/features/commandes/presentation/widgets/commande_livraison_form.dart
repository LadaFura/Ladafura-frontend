import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/services/services_providers.dart';

/// Formulaire de coordonnées de livraison avec choix du mode d'adresse (GPS ou Manuel),
/// épuré de tout encombrement visuel et sans icônes superflues.
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
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;

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
          // 1. Titre épuré (sans icône scooter)
          Text(
            'Coordonnées de livraison',
            style: (isDark ? AppTextStyles.h4Dark : AppTextStyles.h4)
                .copyWith(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 14),

          // 2. Mode de définition de l'adresse (sans icônes dans les boutons)
          Text(
            'Mode de définition de l\'adresse *',
            style: (isDark ? AppTextStyles.captionDark : AppTextStyles.caption)
                .copyWith(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Bouton Prendre auto (GPS) sans icône
              Expanded(
                child: OutlinedButton(
                  onPressed: _isLoadingGps ? null : _detecterAdresseAutomatique,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: _isAutoMode
                        ? primaryColor.withValues(alpha: 0.12)
                        : Colors.transparent,
                    side: BorderSide(
                      color: _isAutoMode
                          ? primaryColor
                          : (isDark ? AppColors.darkBorder : AppColors.border),
                      width: _isAutoMode ? 1.8 : 1,
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoadingGps
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          'Prendre auto (GPS)',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight:
                                _isAutoMode ? FontWeight.bold : FontWeight.w600,
                            color: _isAutoMode
                                ? primaryColor
                                : (isDark ? Colors.white70 : Colors.black87),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 8),
              // Bouton Saisie Manuelle sans icône
              Expanded(
                child: OutlinedButton(
                  onPressed: _isLoadingGps ? null : _basculerManuel,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: !_isAutoMode
                        ? primaryColor.withValues(alpha: 0.12)
                        : Colors.transparent,
                    side: BorderSide(
                      color: !_isAutoMode
                          ? primaryColor
                          : (isDark ? AppColors.darkBorder : AppColors.border),
                      width: !_isAutoMode ? 1.8 : 1,
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Saisie manuelle',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight:
                          !_isAutoMode ? FontWeight.bold : FontWeight.w600,
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

          // 3. Affichage / Saisie de l'adresse selon le mode
          if (_isAutoMode && _autoDetectedAddress != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Position GPS détectée automatiquement :',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.greenAccent : Colors.green[800],
                    ),
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
                    child: Text(
                      'Réactualiser la position',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: widget.adresseController,
              decoration: InputDecoration(
                labelText: 'Complément d\'adresse / Repère (optionnel)',
                hintText: 'Ex: Porte 12, près du grand marché, étage...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 2,
            ),
          ] else ...[
            TextField(
              controller: widget.adresseController,
              decoration: InputDecoration(
                labelText: 'Adresse complète de livraison *',
                hintText: 'Ex: Badalabougou, Rue 24, Porte 12, Bamako',
                errorText: widget.adresseError,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 2,
            ),
          ],
          const SizedBox(height: 16),

          // 4. Numéro de téléphone de contact (sans le tag rouge Obligatoire)
          Text(
            'Numéro de téléphone de contact *',
            style: (isDark ? AppTextStyles.captionDark : AppTextStyles.caption)
                .copyWith(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: widget.telephoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Téléphone du destinataire *',
              hintText: 'Ex: +223 70 12 34 56',
              errorText: widget.telephoneError,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 5. Instructions complémentaires (optionnel)
          TextField(
            controller: widget.notesController,
            decoration: InputDecoration(
              labelText: 'Instructions complémentaires (optionnel)',
              hintText: 'Ex: Appeler avant d\'arriver, portail vert...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}
