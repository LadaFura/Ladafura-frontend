import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/theme/theme_provider.dart';
import '../widgets/parametres_theme_selector.dart';

/// Page des paramètres de l'application (Thème, Langue, Informations).
class ParametresScreen extends ConsumerWidget {
  const ParametresScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentTheme = ref.watch(themeModeProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.surface,
      appBar: AppBar(
        title: const Text('Paramètres'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.space16),
        children: [
          // 1. Sélecteur de thème
          ParametresThemeSelector(
            currentThemeMode: currentTheme,
            onThemeChanged: (mode) {
              ref.read(themeModeProvider.notifier).setThemeMode(mode);
            },
          ),
          const SizedBox(height: AppDimensions.space16),

          // 2. Langue de l'application
          Container(
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
                    const Icon(Icons.language_rounded, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Langue',
                      style: (isDark ? AppTextStyles.h3Dark : AppTextStyles.h3)
                          .copyWith(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Text('🇲🇱', style: TextStyle(fontSize: 24)),
                  title: Text('Français (Mali)'),
                  subtitle: Text('Langue par défaut de l\'application'),
                  trailing: Icon(Icons.check_rounded, color: Colors.green),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.space16),

          // 3. À propos / Version
          Container(
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
                    const Icon(Icons.info_outline_rounded, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'À propos',
                      style: (isDark ? AppTextStyles.h3Dark : AppTextStyles.h3)
                          .copyWith(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Application',
                      style: isDark
                          ? AppTextStyles.bodyDark
                          : AppTextStyles.body,
                    ),
                    const Text('LADAFURA Mobile',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Version',
                      style: isDark
                          ? AppTextStyles.bodyDark
                          : AppTextStyles.body,
                    ),
                    const Text('1.0.0 (Bêta)',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
