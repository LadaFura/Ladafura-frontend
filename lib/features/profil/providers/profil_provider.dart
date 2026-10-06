import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_state_provider.dart';
import '../models/profil_model.dart';
import '../services/profil_service.dart';

final citoyenProfilProvider = FutureProvider<ProfilModel?>((ref) async {
  final authUser = ref.watch(currentUserProvider);
  if (authUser != null) {
    return ProfilModel(
      id: authUser.id,
      nom: authUser.nom,
      prenom: authUser.prenom,
      email: authUser.email,
      telephone: authUser.telephone,
      role: authUser.role,
    );
  }

  try {
    final service = ref.watch(profilServiceProvider);
    return await service.fetchMonProfil();
  } catch (_) {
    return null;
  }
});
