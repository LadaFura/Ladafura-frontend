import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';

/// Barre de recherche commune pour explorer les plantes, produits et pharmacopées (US-01 & US-03).
class SearchBarWidget extends StatefulWidget {
  final String hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final VoidCallback? onFilterTap;
  final bool showFilterButton;
  final bool autofocus;

  const SearchBarWidget({
    super.key,
    this.hintText = 'Rechercher une plante, maladie, remède...',
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.onFilterTap,
    this.showFilterButton = false,
    this.autofocus = false,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late final TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _hasText = _controller.text.isNotEmpty;
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_onTextChanged);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkSurface : Colors.white;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final hintColor = isDark ? AppColors.darkTextMuted : AppColors.textMuted;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
        border: Border.all(color: borderColor, width: 1.0),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        children: [
          const SizedBox(width: AppDimensions.space12),
          Icon(
            Icons.search,
            color: isDark ? AppColors.darkPrimary : AppColors.primary,
            size: 22,
          ),
          const SizedBox(width: AppDimensions.space8),
          Expanded(
            child: TextField(
              controller: _controller,
              autofocus: widget.autofocus,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              style:
                  AppTextStyles.body.copyWith(color: textColor, fontSize: 14),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle:
                    AppTextStyles.bodySecondary.copyWith(color: hintColor),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          if (_hasText)
            IconButton(
              icon: Icon(Icons.close, size: 18, color: hintColor),
              onPressed: () {
                _controller.clear();
                widget.onChanged?.call('');
                widget.onClear?.call();
              },
            ),
          if (widget.showFilterButton) ...[
            Container(
              height: 24,
              width: 1,
              color: borderColor,
              margin: const EdgeInsets.symmetric(horizontal: 4),
            ),
            IconButton(
              icon: Icon(
                Icons.tune,
                size: 20,
                color: isDark ? AppColors.darkPrimary : AppColors.primary,
              ),
              onPressed: widget.onFilterTap,
            ),
          ],
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}
