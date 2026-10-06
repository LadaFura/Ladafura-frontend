import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/commande_model.dart';
import '../services/commande_service.dart';

final mesCommandesProvider = FutureProvider<List<CommandeModel>>((ref) async {
  final service = ref.watch(commandeServiceProvider);
  try {
    return await service.fetchMesCommandes();
  } catch (_) {
    return [];
  }
});
