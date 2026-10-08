import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/network/api_response.dart';
import '../../models/pharmacopee_avis_item_model.dart';
import '../../models/pharmacopee_eligibilite_avis_model.dart';
import '../../services/pharmacopee_service.dart';

/// Modal moderne et conviviale permettant au citoyen de noter et commenter une pharmacopée :
/// - Sélection interactive de 1 à 5 étoiles
/// - Zone de texte pour commentaire argumenté
/// - Support création ou modification d'un avis existant
/// - Messages de validation clairs
class DonnerAvisModal extends StatefulWidget {
  final int pharmacopeeId;
  final String nomPharmacopee;
  final PharmacopeeEligibiliteAvisModel? eligibilite;
  final PharmacopeeService pharmacopeeService;
  final VoidCallback onAvisSubmitted;

  const DonnerAvisModal({
    super.key,
    required this.pharmacopeeId,
    required this.nomPharmacopee,
    this.eligibilite,
    required this.pharmacopeeService,
    required this.onAvisSubmitted,
  });

  static Future<void> show(
    BuildContext context, {
    required int pharmacopeeId,
    required String nomPharmacopee,
    PharmacopeeEligibiliteAvisModel? eligibilite,
    required PharmacopeeService pharmacopeeService,
    required VoidCallback onAvisSubmitted,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DonnerAvisModal(
        pharmacopeeId: pharmacopeeId,
        nomPharmacopee: nomPharmacopee,
        eligibilite: eligibilite,
        pharmacopeeService: pharmacopeeService,
        onAvisSubmitted: onAvisSubmitted,
      ),
    );
  }

  @override
  State<DonnerAvisModal> createState() => _DonnerAvisModalState();
}

class _DonnerAvisModalState extends State<DonnerAvisModal> {
  final TextEditingController _commentaireController = TextEditingController();
  int _note = 5;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _commentaireController.dispose();
    super.dispose();
  }

  Future<void> _submitAvis() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final dejaEvalue = widget.eligibilite?.dejaEvalue == true && widget.eligibilite?.avisId != null;

    ApiResponse<PharmacopeeAvisItemModel> response;
    if (dejaEvalue) {
      response = await widget.pharmacopeeService.modifierAvis(
        avisId: widget.eligibilite!.avisId!,
        note: _note,
        commentaire: _commentaireController.text,
      );
    } else {
      response = await widget.pharmacopeeService.creerAvis(
        pharmacopeeId: widget.pharmacopeeId,
        note: _note,
        commentaire: _commentaireController.text,
      );
    }

    if (!mounted) return;

    if (response.isSuccess) {
      Navigator.of(context).pop();
      widget.onAvisSubmitted();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            dejaEvalue
                ? 'Votre avis a été mis à jour avec succès.'
                : 'Merci pour votre avis ! Il a été publié avec succès.',
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = response.message ?? 'Une erreur est survenue lors de l\'enregistrement de votre avis.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final dejaEvalue = widget.eligibilite?.dejaEvalue == true;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppDimensions.space24,
        AppDimensions.space16,
        AppDimensions.space24,
        AppDimensions.space24 + bottomInset,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusModal),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Poignée de glissement
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.space16),

            // Titre & pharmacopée
            Text(
              dejaEvalue ? 'Modifier mon avis' : 'Donner mon avis',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              widget.nomPharmacopee,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.space20),

            // Étoiles de notation interactives
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  final starValue = index + 1;
                  final isSelected = starValue <= _note;
                  return IconButton(
                    iconSize: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    icon: Icon(
                      isSelected ? Icons.star_rounded : Icons.star_border_rounded,
                      color: isSelected ? AppColors.accent : Colors.grey.shade400,
                    ),
                    onPressed: () {
                      setState(() {
                        _note = starValue;
                      });
                    },
                  );
                }),
              ),
            ),
            Center(
              child: Text(
                _getNoteLabel(_note),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accent,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.space20),

            // Champ de commentaire
            TextField(
              controller: _commentaireController,
              maxLines: 4,
              maxLength: 1000,
              decoration: InputDecoration(
                hintText: 'Partagez votre expérience sur la qualité des remèdes, l\'accueil ou la livraison...',
                hintStyle: TextStyle(
                  fontSize: 12.5,
                  color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                ),
                filled: true,
                fillColor: isDark ? Colors.white.withAlpha(8) : const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.danger.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 16, color: AppColors.danger),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(fontSize: 12, color: AppColors.danger),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: AppDimensions.space16),

            // Bouton de validation
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitAvis,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        dejaEvalue ? 'Mettre à jour mon avis' : 'Publier mon avis',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getNoteLabel(int note) {
    switch (note) {
      case 5:
        return 'Excellent ★★★★★';
      case 4:
        return 'Très bon ★★★★☆';
      case 3:
        return 'Moyen ★★★☆☆';
      case 2:
        return 'Décevant ★★☆☆☆';
      case 1:
        return 'Médiocre ★☆☆☆☆';
      default:
        return '';
    }
  }
}

