import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';

/// Lecteur audio réutilisable pour l'écoute des récits de tradipraticiens (US-15)
/// et des prononciations en langues locales maliennes (Bambara, Peul, Soninké, etc.).
class AudioPlayerWidget extends StatefulWidget {
  final String title;
  final String? audioSourceUrl;
  final Duration totalDuration;
  final VoidCallback? onPlay;
  final VoidCallback? onPause;

  const AudioPlayerWidget({
    super.key,
    required this.title,
    this.audioSourceUrl,
    this.totalDuration = const Duration(minutes: 2, seconds: 30),
    this.onPlay,
    this.onPause,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        widget.onPlay?.call();
      } else {
        widget.onPause?.call();
      }
    });
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? AppColors.darkSurface : AppColors.surface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;
    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final mutedColor = isDark ? AppColors.darkTextMuted : AppColors.textMuted;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.space12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: borderColor, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Titre de l'audio et badge vocal
          Row(
            children: [
              const Icon(Icons.mic_none_outlined,
                  size: 18, color: AppColors.accent),
              const SizedBox(width: AppDimensions.space8),
              Expanded(
                child: Text(
                  widget.title,
                  style: AppTextStyles.label.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space8),

          // Barre de contrôle et curseur
          Row(
            children: [
              // Bouton Play / Pause
              InkWell(
                onTap: _togglePlayPause,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: isDark ? AppColors.darkBackground : Colors.white,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.space12),

              // Curseur de progression
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 6),
                    trackHeight: 3.0,
                    activeTrackColor: primaryColor,
                    inactiveTrackColor: primaryColor.withValues(alpha: 0.2),
                    thumbColor: primaryColor,
                    overlayColor: primaryColor.withValues(alpha: 0.1),
                  ),
                  child: Slider(
                    value: _currentPosition.inSeconds.toDouble().clamp(
                          0.0,
                          widget.totalDuration.inSeconds.toDouble(),
                        ),
                    max: widget.totalDuration.inSeconds.toDouble() > 0
                        ? widget.totalDuration.inSeconds.toDouble()
                        : 1.0,
                    onChanged: (val) {
                      setState(() {
                        _currentPosition = Duration(seconds: val.toInt());
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.space8),

              // Chronomètre temps écoulé / total
              Text(
                '${_formatDuration(_currentPosition)} / ${_formatDuration(widget.totalDuration)}',
                style: AppTextStyles.caption.copyWith(
                  color: mutedColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
