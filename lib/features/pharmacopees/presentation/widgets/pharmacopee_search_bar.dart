import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

/// Barre de recherche et filtres de catégories spécifiques à la pharmacopée en cours de consultation.
/// Permet de chercher en direct parmi les remèdes vendus par cette pharmacopée.
class PharmacopeeSearchBar extends StatefulWidget {
  final String pharmacopeeNom;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final List<String> categories;
  final String? selectedCategory;
  final ValueChanged<String?> onCategorySelected;
  final bool isPinned;
  final VoidCallback? onBack;

  const PharmacopeeSearchBar({
    super.key,
    required this.pharmacopeeNom,
    this.searchQuery = '',
    required this.onSearchChanged,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
    this.isPinned = false,
    this.onBack,
  });

  @override
  State<PharmacopeeSearchBar> createState() => _PharmacopeeSearchBarState();
}

class _PharmacopeeSearchBarState extends State<PharmacopeeSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.searchQuery);
  }

  @override
  void didUpdateWidget(covariant PharmacopeeSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != oldWidget.searchQuery &&
        widget.searchQuery != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.searchQuery,
        selection: TextSelection.collapsed(offset: widget.searchQuery.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = widget.isPinned
        ? (isDark ? AppColors.darkBackground : AppColors.surface)
        : Colors.transparent;
    final topPadding = widget.isPinned
        ? (MediaQuery.paddingOf(context).top + AppDimensions.space8)
        : 0.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: bgColor,
        boxShadow: widget.isPinned
            ? [
                BoxShadow(
                  color: Colors.black.withAlpha(isDark ? 55 : 20),
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
      padding: EdgeInsets.only(
        left: AppDimensions.space16,
        right: AppDimensions.space16,
        top: topPadding,
        bottom: AppDimensions.space4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (widget.isPinned && widget.onBack != null) ...[
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 20,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                  onPressed: widget.onBack,
                  tooltip: 'Retour',
                ),
                const SizedBox(width: 8),
              ],
              // Champ de recherche contextualisé
              Expanded(
                child: AnimatedContainer(
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
                      hintText: 'Rechercher un remède...',
                      hintStyle: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: AppColors.primary, size: 20),
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
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
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.space12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Chips horizontales de catégories de produits si disponibles
          if (widget.categories.isNotEmpty) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 34,
              child: ListView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                children: [
                  _buildCategoryChip(
                    label: 'Tous',
                    isSelected: widget.selectedCategory == null,
                    isDark: isDark,
                    onTap: () => widget.onCategorySelected(null),
                  ),
                  const SizedBox(width: 8),
                  ...widget.categories.map((cat) {
                    final isSelected = widget.selectedCategory != null &&
                        widget.selectedCategory!.trim().toLowerCase() ==
                            cat.trim().toLowerCase();
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
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isDark
                  ? AppColors.darkSurface
                  : const Color(0xFFF1F5F2)),
          borderRadius: BorderRadius.circular(18),
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

