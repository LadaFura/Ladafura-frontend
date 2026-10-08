import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

/// Carte de saisie du numéro de téléphone de contact obligatoire pour le retrait au comptoir.
class CommandeContactPhoneCard extends StatelessWidget {
  final TextEditingController telephoneController;
  final String? telephoneError;

  const CommandeContactPhoneCard({
    super.key,
    required this.telephoneController,
    this.telephoneError,
  });

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
            color: Colors.black.withAlpha(isDark ? 16 : 4),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: telephoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Téléphone pour le retrait *',
              hintText: 'Ex: +223 70 12 34 56',
              prefixIcon: const Icon(Icons.phone_outlined, size: 20),
              errorText: telephoneError,
              helperText:
                  'Permet à l\'pharmacopée de vous joindre quand votre commande est prête.',
              helperStyle: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
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
