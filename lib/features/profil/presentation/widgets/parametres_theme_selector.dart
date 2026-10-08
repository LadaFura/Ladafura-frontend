import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';

/// Sélecteur moderne de mode de thème (Système, Clair, Sombre) pour l'écran des paramètres.
class ParametresThemeSelector extends StatelessWidget {
  final ThemeMode currentThemeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  const ParametresThemeSelector({
    super.key,
    required this.currentThemeMode,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;

    return Container(
      width: double.infinity,
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
          Row(
            children: [
              Icon(Icons.palette_outlined, color: primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Apparence & Thème',
                style: (isDark ? AppTextStyles.h3Dark : AppTextStyles.h3)
                    .copyWith(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Choisissez le thème visuel appliqué à l\'application.',
            style: (isDark ? AppTextStyles.captionDark : AppTextStyles.caption)
                .copyWith(fontSize: 12),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<ThemeMode>(
              style: ButtonStyle(
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              segments: const [
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.system,
                  label: Text('Système', style: TextStyle(fontSize: 12)),
                  icon: Icon(Icons.brightness_auto_rounded, size: 16),
                ),
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.light,
                  label: Text('Clair', style: TextStyle(fontSize: 12)),
                  icon: Icon(Icons.light_mode_rounded, size: 16),
                ),
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.dark,
                  label: Text('Sombre', style: TextStyle(fontSize: 12)),
                  icon: Icon(Icons.dark_mode_rounded, size: 16),
                ),
              ],
              selected: {currentThemeMode},
              onSelectionChanged: (newSelection) {
                if (newSelection.isNotEmpty) {
                  onThemeChanged(newSelection.first);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

