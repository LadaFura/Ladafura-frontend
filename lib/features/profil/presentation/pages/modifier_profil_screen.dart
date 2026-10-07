import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../providers/profil_provider.dart';
import '../widgets/modifier_profil_form.dart';

/// Page permettant à l'utilisateur de modifier son nom, son prénom et son téléphone.
class ModifierProfilScreen extends ConsumerWidget {
  const ModifierProfilScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profilState = ref.watch(profilProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.surface,
      appBar: AppBar(
        title: const Text('Modifier mon profil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.space16),
        child: ModifierProfilForm(
          profil: profilState.profil,
          isSubmitting: profilState.isUpdating,
          errorMessage: profilState.errorMessage,
          onSubmit: ({
            required String nom,
            required String prenom,
            String? telephone,
          }) async {
            final success = await ref
                .read(profilProvider.notifier)
                .modifierProfil(
                  nom: nom,
                  prenom: prenom,
                  telephone: telephone,
                );

            if (success && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Votre profil a été mis à jour avec succès !'),
                  backgroundColor: Colors.green,
                ),
              );
              context.pop();
            }
          },
        ),
      ),
    );
  }
}

