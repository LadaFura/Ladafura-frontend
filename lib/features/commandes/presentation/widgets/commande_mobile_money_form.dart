import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';

/// Formulaire de saisie du numéro et de choix de l'opérateur pour Mobile Money.
class CommandeMobileMoneyForm extends StatelessWidget {
  final List<String> operateurs;
  final String? selectedOperateur;
  final ValueChanged<String> onOperateurSelected;
  final TextEditingController telephoneController;
  final String? instructions;

  const CommandeMobileMoneyForm({
    super.key,
    required this.operateurs,
    required this.selectedOperateur,
    required this.onOperateurSelected,
    required this.telephoneController,
    this.instructions,
  });

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
            color: Colors.black.withAlpha(isDark ? 16 : 4),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Opérateur Mobile Money au Mali',
            style: (isDark ? AppTextStyles.captionDark : AppTextStyles.caption)
                .copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: operateurs.map((op) {
              final isOpSelected = selectedOperateur == op;
              return ChoiceChip(
                label: Text(op),
                selected: isOpSelected,
                selectedColor: primaryColor.withAlpha(40),
                onSelected: (selected) {
                  if (selected) {
                    onOperateurSelected(op);
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: telephoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Numéro de téléphone mobile (+223)',
              hintText: 'Ex: 70 11 22 33',
              prefixIcon: const Icon(Icons.phone),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          if (instructions != null && instructions!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              instructions!,
              style: (isDark ? AppTextStyles.captionDark : AppTextStyles.caption)
                  .copyWith(fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }
}

