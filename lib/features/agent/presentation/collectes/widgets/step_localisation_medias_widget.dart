import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_colors.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_dimensions.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_text_styles.dart';
import 'package:ladafura_frontend_flutter/core/services/location_service.dart';
import 'package:ladafura_frontend_flutter/features/agent/providers/agent_providers.dart';

/// Étape 5 du Wizard : Localisation géographique (Région, Cercle, GPS) et médias de terrain (Photo & Audio).
class StepLocalisationMediasWidget extends ConsumerStatefulWidget {
  const StepLocalisationMediasWidget({super.key});

  @override
  ConsumerState<StepLocalisationMediasWidget> createState() =>
      _StepLocalisationMediasWidgetState();
}

class _StepLocalisationMediasWidgetState
    extends ConsumerState<StepLocalisationMediasWidget> {
  final TextEditingController _regionController = TextEditingController();
  final TextEditingController _cercleController = TextEditingController();
  final TextEditingController _communeController = TextEditingController();
  final TextEditingController _localiteController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  bool _isGettingGps = false;

  final List<String> _regionsMali = [
    'Kayes',
    'Koulikoro',
    'Sikasso',
    'Ségou',
    'Mopti',
    'Tombouctou',
    'Gao',
    'Kidal',
    'Taoudénit',
    'Ménaka',
    'District de Bamako',
  ];

  @override
  void initState() {
    super.initState();
    final draft = ref.read(nouvelleCollecteWizardProvider);
    _regionController.text = draft.region.isNotEmpty ? draft.region : 'Sikasso';
    _cercleController.text = draft.cercle;
    _communeController.text = draft.commune;
    _localiteController.text = draft.localite;

    _regionController.addListener(_sync);
    _cercleController.addListener(_sync);
    _communeController.addListener(_sync);
    _localiteController.addListener(_sync);
  }

  @override
  void dispose() {
    _regionController.dispose();
    _cercleController.dispose();
    _communeController.dispose();
    _localiteController.dispose();
    super.dispose();
  }

  void _sync() {
    final draft = ref.read(nouvelleCollecteWizardProvider);
    ref.read(nouvelleCollecteWizardProvider.notifier).setLocalisation(
          region: _regionController.text.trim(),
          cercle: _cercleController.text.trim(),
          commune: _communeController.text.trim(),
          localite: _localiteController.text.trim(),
          latitude: draft.latitude,
          longitude: draft.longitude,
        );
  }

  Future<void> _fetchCurrentGps() async {
    setState(() => _isGettingGps = true);
    try {
      final locService = LocationService();
      final position = await locService.getCurrentPosition();
      if (position != null) {
        ref.read(nouvelleCollecteWizardProvider.notifier).setLocalisation(
              region: _regionController.text.trim(),
              cercle: _cercleController.text.trim(),
              commune: _communeController.text.trim(),
              localite: _localiteController.text.trim(),
              latitude: position.latitude,
              longitude: position.longitude,
            );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Coordonnées GPS capturées : ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}',
              ),
              backgroundColor: AppColors.primary,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Impossible de récupérer le GPS : $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGettingGps = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
      );
      if (picked != null) {
        ref
            .read(nouvelleCollecteWizardProvider.notifier)
            .setPhoto(File(picked.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur sélection image : $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _pickAudio() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'm4a', 'wav', 'aac', 'ogg'],
      );
      if (result.isNotEmpty && result.first.path != null) {
        ref
            .read(nouvelleCollecteWizardProvider.notifier)
            .setAudio(File(result.first.path!));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur sélection audio : $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final draft = ref.watch(nouvelleCollecteWizardProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // En-tête
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.pin_drop_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppDimensions.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Localisation & Médias de Terrain',
                      style: (isDark ? AppTextStyles.h3Dark : AppTextStyles.h3)
                          .copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Précisez le lieu de recueil, le point GPS et les preuves visuelles.',
                      style: (isDark
                              ? AppTextStyles.captionDark
                              : AppTextStyles.caption)
                        .copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.space20),

          // 1. Découpage territorial
          Text(
            'Région administrative *',
            style: (isDark ? AppTextStyles.bodyDark : AppTextStyles.body)
                .copyWith(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: _regionsMali.contains(_regionController.text)
                ? _regionController.text
                : _regionsMali.first,
            dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
            decoration: InputDecoration(
              filled: true,
              fillColor: isDark ? AppColors.darkSurface : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            items: _regionsMali
                .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                .toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() => _regionController.text = val);
                _sync();
              }
            },
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _cercleController,
                  decoration: const InputDecoration(
                    labelText: 'Cercle (ex: Koutiala)',
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _communeController,
                  decoration: const InputDecoration(
                    labelText: 'Commune (ex: Finkolo)',
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          TextField(
            controller: _localiteController,
            decoration: const InputDecoration(
              labelText: 'Village ou localité spécifique',
              hintText: 'Ex: Hameau de Finkolo-Sud',
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),

          const SizedBox(height: AppDimensions.space20),

          // 2. Coordonnées GPS
          Container(
            padding: const EdgeInsets.all(AppDimensions.space16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.inputBorder,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.my_location_rounded, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Coordonnées GPS de terrain',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        draft.latitude != null && draft.longitude != null
                            ? 'Lat: ${draft.latitude!.toStringAsFixed(5)}, Long: ${draft.longitude!.toStringAsFixed(5)}'
                            : 'Aucune position GPS enregistrée',
                        style: TextStyle(
                          fontSize: 12,
                          color: draft.latitude != null
                              ? Colors.green
                              : (isDark ? AppColors.darkTextMuted : AppColors.textMuted),
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isGettingGps ? null : _fetchCurrentGps,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  icon: _isGettingGps
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.gps_fixed_rounded, size: 16),
                  label: const Text('Localiser', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppDimensions.space24),

          // 3. Médias : Photo de l'échantillon
          Text(
            'Photo du spécimen ou de la préparation',
            style: (isDark ? AppTextStyles.bodyDark : AppTextStyles.body)
                .copyWith(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 8),

          if (draft.photoFile != null) ...[
            Stack(
              alignment: Alignment.topRight,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                  child: Image.file(
                    draft.photoFile!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withValues(alpha: 0.6),
                    child: IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
                      onPressed: () => ref
                          .read(nouvelleCollecteWizardProvider.notifier)
                          .setPhoto(null),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('Appareil photo'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Galerie'),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: AppDimensions.space20),

          // 4. Médias : Enregistrement Audio du récit
          Text(
            'Témoignage audio ou prononciation orale',
            style: (isDark ? AppTextStyles.bodyDark : AppTextStyles.body)
                .copyWith(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.all(AppDimensions.space12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.inputBorder,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.mic_rounded,
                  color: draft.audioFile != null ? Colors.green : AppColors.primary,
                  size: 26,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    draft.audioFile != null
                        ? 'Audio joint : ${draft.audioFile!.path.split("/").last}'
                        : 'Aucun enregistrement audio joint.',
                    style: TextStyle(
                      fontSize: 12,
                      color: draft.audioFile != null
                          ? (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)
                          : (isDark ? AppColors.darkTextMuted : AppColors.textMuted),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (draft.audioFile != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                    onPressed: () => ref
                        .read(nouvelleCollecteWizardProvider.notifier)
                        .setAudio(null),
                  )
                else
                  TextButton.icon(
                    onPressed: _pickAudio,
                    icon: const Icon(Icons.upload_file_rounded, size: 18),
                    label: const Text('Choisir'),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
