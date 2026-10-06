import 'package:flutter/material.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_colors.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_dimensions.dart';

/// En-tête de section de résultat avec badge de priorité et compteur numérique.
class SearchSectionTitle extends StatelessWidget {
  final String title;
  final int count;
  final bool isPriority;
  final bool isDark;

  const SearchSectionTitle({
    super.key,
    required this.title,
    required this.count,
    this.isPriority = false,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (isPriority) ...[
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.star_rounded, size: 14, color: Colors.white),
          ),
          const SizedBox(width: AppDimensions.space8),
        ],
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isPriority
                ? AppColors.primary
                : (isDark ? Colors.white : AppColors.textPrimary),
          ),
        ),
        const SizedBox(width: AppDimensions.space8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: isPriority
                ? AppColors.primary.withValues(alpha: 0.15)
                : (isDark ? Colors.grey[800] : Colors.grey[200]),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isPriority
                  ? AppColors.primary
                  : (isDark ? Colors.white70 : Colors.black87),
            ),
          ),
        ),
      ],
    );
  }
}
