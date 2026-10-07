import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';

/// Carte lecteur audio moderne pour l'écoute de la prononciation locale
/// et des témoignages oraux d'ethnobotanistes ou de guérisseurs traditionnels.
class PlanteAudioPlayerCard extends StatefulWidget {
  final String audioUrl;
  final String? title;
  final String? subtitle;
  final String? languageTag;

  const PlanteAudioPlayerCard({
    super.key,
    required this.audioUrl,
    this.title,
    this.subtitle,
    this.languageTag,
  });

  @override
  State<PlanteAudioPlayerCard> createState() => _PlanteAudioPlayerCardState();
}

class _PlanteAudioPlayerCardState extends State<PlanteAudioPlayerCard>
    with SingleTickerProviderStateMixin {
  AudioPlayer? _audioPlayer;
  PlayerState _playerState = PlayerState.stopped;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isLoading = false;
  String? _errorMessage;

  StreamSubscription? _stateSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _completeSubscription;

  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _initPlayer();
  }

  void _initPlayer() {
    try {
      final player = AudioPlayer();
      _audioPlayer = player;

      _stateSubscription = player.onPlayerStateChanged.listen((state) {
        if (mounted) {
          setState(() {
            _playerState = state;
            if (state == PlayerState.playing) {
              _isLoading = false;
            }
          });
        }
      }, onError: (_) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = "Module audio indisponible sans redémarrage complet.";
          });
        }
      });

      _durationSubscription = player.onDurationChanged.listen((dur) {
        if (mounted) {
          setState(() => _duration = dur);
        }
      }, onError: (_) {});

      _positionSubscription = player.onPositionChanged.listen((pos) {
        if (mounted) {
          setState(() => _position = pos);
        }
      }, onError: (_) {});

      _completeSubscription = player.onPlayerComplete.listen((_) {
        if (mounted) {
          setState(() {
            _playerState = PlayerState.completed;
            _position = Duration.zero;
          });
        }
      }, onError: (_) {});
    } catch (_) {
      _errorMessage = "Module audio indisponible (redémarrage de l'app requis).";
    }
  }

  @override
  void dispose() {
    _stateSubscription?.cancel();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _completeSubscription?.cancel();
    _pulseController.dispose();
    try {
      _audioPlayer?.dispose();
    } catch (_) {}
    super.dispose();
  }

  Future<void> _togglePlayPause() async {
    setState(() => _errorMessage = null);

    if (_audioPlayer == null) {
      _initPlayer();
    }

    final player = _audioPlayer;
    if (player == null) {
      setState(() {
        _errorMessage = "Veuillez redémarrer l'application complètement pour activer le lecteur.";
      });
      return;
    }

    try {
      if (_playerState == PlayerState.playing) {
        await player.pause();
      } else {
        setState(() => _isLoading = true);
        if (_playerState == PlayerState.completed ||
            _playerState == PlayerState.stopped) {
          await player.play(UrlSource(widget.audioUrl));
        } else {
          await player.resume();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Lecteur audio non prêt (redémarrage requis).";
        });
      }
    }
  }

  Future<void> _seek(double value) async {
    final player = _audioPlayer;
    if (player == null) return;
    try {
      final targetPosition = Duration(milliseconds: value.toInt());
      await player.seek(targetPosition);
    } catch (_) {}
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPlaying = _playerState == PlayerState.playing;

    final titleText = widget.title ?? 'Écouter la prononciation locale';
    final subtitleText =
        widget.subtitle ?? 'Témoignage oral & savoirs phonétiques';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  AppColors.darkSurface,
                  AppColors.primaryDark.withAlpha(60),
                ]
              : [
                  AppColors.primaryLight,
                  Colors.white,
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(
          color: isDark
              ? AppColors.darkBorder
              : AppColors.primary.withAlpha(50),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : AppColors.primary).withAlpha(15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppDimensions.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête : Badge + Titre + Icône onde sonore
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.space8),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkAccent.withAlpha(40)
                      : AppColors.primary.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.volume_up_rounded,
                  color: isDark ? AppColors.darkAccent : AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppDimensions.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titleText,
                      style: (isDark ? AppTextStyles.h4Dark : AppTextStyles.h4)
                          .copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitleText,
                      style: (isDark
                              ? AppTextStyles.captionDark
                              : AppTextStyles.caption)
                          .copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (widget.languageTag != null &&
                  widget.languageTag!.trim().isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.space8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.darkAccent : AppColors.primary)
                        .withAlpha(35),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusBadge),
                    border: Border.all(
                      color:
                          (isDark ? AppColors.darkAccent : AppColors.primary)
                              .withAlpha(80),
                    ),
                  ),
                  child: Text(
                    widget.languageTag!,
                    style: (isDark
                            ? AppTextStyles.captionDark
                            : AppTextStyles.caption)
                        .copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      color:
                          isDark ? AppColors.darkAccent : AppColors.primaryDark,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: AppDimensions.space12),

          // Ligne de contrôle : Bouton Play + Slider / Waveform + Chrono
          Row(
            children: [
              // Bouton Play / Pause stylisé
              GestureDetector(
                onTap: _isLoading ? null : _togglePlayPause,
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final scale = isPlaying
                        ? 1.0 + (_pulseController.value * 0.06)
                        : 1.0;
                    return Transform.scale(
                      scale: scale,
                      child: child,
                    );
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          isDark ? AppColors.darkAccent : AppColors.primary,
                          isDark
                              ? AppColors.darkAccent.withAlpha(200)
                              : AppColors.primaryDark,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isDark
                                  ? AppColors.darkAccent
                                  : AppColors.primary)
                              .withAlpha(isPlaying ? 80 : 40),
                          blurRadius: isPlaying ? 10 : 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: _isLoading
                        ? const Center(
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          )
                        : Icon(
                            isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                  ),
                ),
              ),

              const SizedBox(width: AppDimensions.space12),

              // Barre de progression
              Expanded(
                child: Column(
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 4,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 6,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 14,
                        ),
                        activeTrackColor: isDark
                            ? AppColors.darkAccent
                            : AppColors.primary,
                        inactiveTrackColor: (isDark
                                ? AppColors.darkBorder
                                : AppColors.border)
                            .withAlpha(120),
                        thumbColor: isDark
                            ? AppColors.darkAccent
                            : AppColors.primary,
                      ),
                      child: Slider(
                        value: _duration.inMilliseconds > 0
                            ? _position.inMilliseconds
                                .clamp(0, _duration.inMilliseconds)
                                .toDouble()
                            : 0.0,
                        max: _duration.inMilliseconds > 0
                            ? _duration.inMilliseconds.toDouble()
                            : 1.0,
                        onChanged: _duration.inMilliseconds > 0
                            ? (val) => _seek(val)
                            : null,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(_position),
                            style: (isDark
                                    ? AppTextStyles.captionDark
                                    : AppTextStyles.caption)
                                .copyWith(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textMuted,
                            ),
                          ),
                          Text(
                            _duration.inMilliseconds > 0
                                ? _formatDuration(_duration)
                                : '--:--',
                            style: (isDark
                                    ? AppTextStyles.captionDark
                                    : AppTextStyles.caption)
                                .copyWith(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (_errorMessage != null) ...[
            const SizedBox(height: AppDimensions.space8),
            Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: AppColors.danger, size: 14),
                const SizedBox(width: 4),
                Text(
                  _errorMessage!,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.danger,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

