import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Élément d'action pour le groupe de paramètres
class ModernSettingItem {
  final IconData icon;
  final String title;
  final String? valueText;
  final Widget? trailingBadge;
  final Color? iconColor;
  final Color? titleColor;
  final VoidCallback onTap;

  const ModernSettingItem({
    required this.icon,
    required this.title,
    this.valueText,
    this.trailingBadge,
    this.iconColor,
    this.titleColor,
    required this.onTap,
  });
}

/// Carte de groupe moderne (fond blanc arrondi, bordure subtile, avec séparateurs fins)
/// fidèle au style iOS / Minimaliste de l'inspiration.
class ModernSettingSection extends StatelessWidget {
  final String? title;
  final List<ModernSettingItem> items;

  const ModernSettingSection({
    super.key,
    this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null && title!.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              title!,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : Colors.black.withAlpha(8),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(isDark ? 16 : 4),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isLast = index == items.length - 1;

              return Column(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: item.onTap,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            // Icône
                            Icon(
                              item.icon,
                              size: 21,
                              color: item.iconColor ??
                                  (isDark
                                      ? Colors.grey[300]
                                      : const Color(0xFF475569)),
                            ),
                            const SizedBox(width: 14),

                            // Titre
                            Expanded(
                              child: Text(
                                item.title,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: item.titleColor ??
                                      (isDark
                                          ? Colors.white
                                          : const Color(0xFF1E293B)),
                                ),
                              ),
                            ),

                            // Badge ou Valeur optionnelle (ex: "Français", "Clair", etc.)
                            if (item.trailingBadge != null)
                              item.trailingBadge!
                            else if (item.valueText != null)
                              Text(
                                item.valueText!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark
                                      ? Colors.grey[400]
                                      : const Color(0xFF64748B),
                                ),
                              ),

                            const SizedBox(width: 8),

                            // Flèche chevron vers la droite
                            Icon(
                              Icons.chevron_right_rounded,
                              size: 20,
                              color: isDark
                                  ? Colors.grey[600]
                                  : const Color(0xFF94A3B8),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (!isLast)
                    Divider(
                      height: 1,
                      thickness: 1,
                      indent: 51,
                      endIndent: 16,
                      color: isDark
                          ? AppColors.darkBorder
                          : Colors.grey.withAlpha(25),
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}
