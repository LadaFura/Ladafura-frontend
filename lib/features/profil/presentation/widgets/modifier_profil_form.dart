import 'package:flutter/material.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../models/profil_model.dart';

/// Formulaire de modification des informations personnelles (Nom, Prénom, Téléphone)
/// avec validation stricte et champ Email en lecture seule sécurisée.
class ModifierProfilForm extends StatefulWidget {
  final ProfilModel? profil;
  final bool isSubmitting;
  final String? errorMessage;
  final Future<void> Function({
    required String nom,
    required String prenom,
    String? telephone,
  }) onSubmit;

  const ModifierProfilForm({
    super.key,
    required this.profil,
    required this.isSubmitting,
    this.errorMessage,
    required this.onSubmit,
  });

  @override
  State<ModifierProfilForm> createState() => _ModifierProfilFormState();
}

class _ModifierProfilFormState extends State<ModifierProfilForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomController;
  late final TextEditingController _prenomController;
  late final TextEditingController _telephoneController;

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.profil?.nom ?? '');
    _prenomController = TextEditingController(text: widget.profil?.prenom ?? '');
    _telephoneController =
        TextEditingController(text: widget.profil?.telephone ?? '');
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _telephoneController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSubmit(
        nom: _nomController.text.trim(),
        prenom: _prenomController.text.trim(),
        telephone: _telephoneController.text.trim().isNotEmpty
            ? _telephoneController.text.trim()
            : null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withAlpha(50)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Champ Prénom
          TextFormField(
            controller: _prenomController,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: 'Prénom *',
              hintText: 'Ex: Fatoumata',
              prefixIcon: const Icon(Icons.badge_rounded, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            validator: (val) {
              final text = val?.trim() ?? '';
              if (text.isEmpty) return 'Le prénom est obligatoire.';
              if (text.length < 2) return 'Le prénom doit contenir au moins 2 caractères.';
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Champ Nom
          TextFormField(
            controller: _nomController,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              labelText: 'Nom de famille *',
              hintText: 'Ex: Diarra',
              prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            validator: (val) {
              final text = val?.trim() ?? '';
              if (text.isEmpty) return 'Le nom de famille est obligatoire.';
              if (text.length < 2) return 'Le nom doit contenir au moins 2 caractères.';
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Champ Téléphone
          TextFormField(
            controller: _telephoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Numéro de téléphone',
              hintText: 'Ex: +223 70 12 34 56',
              prefixIcon: const Icon(Icons.phone_outlined, size: 20),
              helperText: 'Utilisé pour le contact des commandes et des livraisons.',
              helperStyle: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            validator: (val) {
              final text = val?.trim() ?? '';
              if (text.isNotEmpty && text.length > 25) {
                return 'Le numéro ne doit pas dépasser 25 caractères.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Champ Email (Lecture seule - géré par Firebase Auth)
          TextFormField(
            initialValue: widget.profil?.email ?? '',
            enabled: false,
            decoration: InputDecoration(
              labelText: 'Adresse email (sécurisée)',
              prefixIcon: const Icon(Icons.email_outlined, size: 20),
              suffixIcon: const Icon(Icons.lock_outline, size: 18),
              helperText: 'L\'email est lié à votre compte Firebase Authentication.',
              helperStyle: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: isDark ? Colors.white10 : Colors.grey.shade100,
            ),
          ),
          const SizedBox(height: AppDimensions.space24),

          // Bouton Enregistrer
          PrimaryButton(
            label: 'Enregistrer les modifications',
            icon: Icons.check_circle_outline_rounded,
            isLoading: widget.isSubmitting,
            onPressed: widget.isSubmitting ? null : _handleSave,
          ),
        ],
      ),
    );
  }
}
