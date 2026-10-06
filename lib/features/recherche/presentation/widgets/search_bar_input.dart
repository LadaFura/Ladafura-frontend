import 'package:flutter/material.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_colors.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_dimensions.dart';

/// Barre de saisie de recherche fidèle à la maquette officielle LADAFURA.
/// Maintient une stabilité totale du focus et du clavier lors de la frappe.
class SearchBarInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;
  final VoidCallback? onBack;
  final bool isDark;

  const SearchBarInput({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
    this.onBack,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : const Color(0xFFEFF3F0),
        borderRadius: BorderRadius.circular(AppDimensions.radiusBadge),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        textAlignVertical: TextAlignVertical.center,
        onSubmitted: (val) {
          if (val.trim().isNotEmpty) {
            onSubmitted(val.trim());
          }
        },
        decoration: InputDecoration(
          hintText: 'Rechercher par une maladie, produit...',
          hintStyle: TextStyle(
            color: isDark ? AppColors.darkTextMuted : const Color(0xFF6B7B70),
            fontSize: 14,
          ),
          prefixIcon: IconButton(
            focusNode: FocusNode(skipTraversal: true, canRequestFocus: false),
            icon: const Icon(
              Icons.arrow_back,
              color: Color(0xFF2E3830),
              size: 20,
            ),
            onPressed: () {
              if (onBack != null) {
                onBack!();
              } else if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                controller.clear();
                onClear();
              }
            },
          ),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              if (value.text.isEmpty) {
                return const SizedBox(width: 0, height: 0);
              }
              return IconButton(
                focusNode:
                    FocusNode(skipTraversal: true, canRequestFocus: false),
                icon: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E3A2F),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 13,
                  ),
                ),
                onPressed: () {
                  controller.clear();
                  onClear();
                },
              );
            },
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space12,
            vertical: 10,
          ),
        ),
      ),
    );
  }
}
