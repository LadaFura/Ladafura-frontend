import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

/// Barre de recherche et filtres de catégories spécifiques à la pharmacopée en cours de consultation.
/// Permet de chercher en direct parmi les remèdes vendus par cette pharmacopée.
class PharmacopeeSearchBar extends StatefulWidget {
  final String pharmacopeeNom;
  final ValueChanged<String> onSearchChanged;
  final List<String> categories;
  final String? selectedCategory;
  final ValueChanged<String?> onCategorySelected;
  final bool isPinned;

  const PharmacopeeSearchBar({
    super.key,
    required this.pharmacopeeNom,
    required this.onSearchChanged,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
    this.isPinned = false,
  });

  @override
  State<PharmacopeeSearchBar> createState() => _PharmacopeeSearchBarState();
}

class _PharmacopeeSearchBarState extends State<PharmacopeeSearchBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.surface;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: bgColor,
        boxShadow: widget.isPinned
            ? [
                BoxShadow(
                  color: Colors.black.withAlpha(isDark ? 45 : 20),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
        border: widget.isPinned
            ? Border(
                bottom: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.border.withAlpha(120),
                  width: 0.8,
                ),
              )
            : null,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space16,
        vertical: AppDimensions.space8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Champ de recherche contextualisé
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(
                widget.isPinned ? 12 : AppDimensions.radiusInput,
              ),
              border: Border.all(
                color: widget.isPinned
                    ? (isDark ? AppColors.darkPrimary.withAlpha(100) : AppColors.primary.withAlpha(100))
                    : (isDark ? AppColors.darkBorder : AppColors.border),
                width: widget.isPinned ? 1.2 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(widget.isPinned ? 12 : 6),
                  blurRadius: widget.isPinned ? 10 : 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _controller,
              onChanged: widget.onSearchChanged,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Rechercher un remède dans cette pharmacopée...',
                hintStyle: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                ),
                prefixIcon: const Icon(Icons.search_rounded,
                    color: AppColors.primary, size: 22),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded,
                            size: 18, color: AppColors.textMuted),
                        onPressed: () {
                          _controller.clear();
                          widget.onSearchChanged('');
                          setState(() {});
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.space16,
                  vertical: 14,
                ),
              ),
            ),
          ),

          // Chips horizontales de catégories de produits si disponibles
          if (widget.categories.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.space12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(
                children: [
                  _buildCategoryChip(
                    label: 'Tous',
                    isSelected: widget.selectedCategory == null,
                    isDark: isDark,
                    onTap: () => widget.onCategorySelected(null),
                  ),
                  const SizedBox(width: 8),
                  ...widget.categories.map((cat) {
                    final isSelected = widget.selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _buildCategoryChip(
                        label: cat,
                        isSelected: isSelected,
                        isDark: isDark,
                        onTap: () => widget.onCategorySelected(cat),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryChip({
    required String label,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isDark
                  ? AppColors.darkSurface
                  : const Color(0xFFF1F5F2)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0)),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white70 : AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}

