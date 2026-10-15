import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/image_utils.dart';

/// Composant d'image réseau optimisé avec mise en cache locale et gestion des erreurs.
class AppCachedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const AppCachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final resolved = ImageUtils.resolveImageUrl(imageUrl) ?? imageUrl;

    Widget buildDefaultFallback() =>
        errorWidget ??
        Container(
          width: width,
          height: height,
          color: isDark
              ? AppColors.darkPrimaryContainer
              : AppColors.primaryLight,
          child: Center(
            child: Icon(
              Icons.image_not_supported_outlined,
              size: 24,
              color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
            ),
          ),
        );

    Widget image;

    if (resolved.startsWith('assets/')) {
      image = Image.asset(
        resolved,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => buildDefaultFallback(),
      );
    } else {
      image = CachedNetworkImage(
        imageUrl: resolved,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) =>
            placeholder ??
            Container(
              width: width,
              height: height,
              color: isDark ? AppColors.darkSurface : AppColors.surface,
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDark ? AppColors.darkPrimary : AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
        errorWidget: (context, url, error) => buildDefaultFallback(),
      );
    }

    if (borderRadius != null) {
      image = ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }

    return image;
  }
}
