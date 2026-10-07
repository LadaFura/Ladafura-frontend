import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../pharmacopees/models/pharmacopee_model.dart';
import '../../recherche/providers/recherche_provider.dart';
import '../models/carte_filter_model.dart';
import '../services/carte_service.dart';

/// Filtre actif de la carte
final carteFilterProvider = StateProvider<CarteFilterModel>((ref) {
  return const CarteFilterModel();
});

/// Pharmacopée actuellement sélectionnée sur la carte (pour afficher la bottom card)
final selectedCartePharmacopeeProvider = StateProvider<PharmacopeeModel?>((ref) {
  return null;
});

/// Terme de recherche textuel sur la carte
final carteSearchQueryProvider = StateProvider<String>((ref) {
  return '';
});

/// Données des pharmacopées filtrées pour la carte interactive
final cartePharmacopeesProvider = FutureProvider<List<PharmacopeeModel>>((ref) async {
  final service = ref.watch(carteServiceProvider);
  final filter = ref.watch(carteFilterProvider);
  final searchQuery = ref.watch(carteSearchQueryProvider).trim();

  try {
    List<PharmacopeeModel> list;

    // Si une recherche textuelle est saisie (maladie, produit, plante, pharmacopée)
    if (searchQuery.isNotEmpty) {
      final rechercheRepo = ref.watch(rechercheRepositoryProvider);
      final searchResult = await rechercheRepo.search(searchQuery);

      if (searchResult != null && searchResult.pharmacopees.isNotEmpty) {
        // Convertit les PharmacopeeSearchItem en PharmacopeeModel pour affichage sur la carte
        list = searchResult.pharmacopees.map((item) {
          return PharmacopeeModel(
            id: item.id,
            nom: item.nom,
            description: item.description,
            telephone: item.telephone,
            region: item.region,
            cercle: item.cercle,
            commune: item.commune,
            localite: item.localite,
            latitude: item.latitude ?? 12.6392,
            longitude: item.longitude ?? -8.0029,
            proposeLivraison: true,
            proposePickup: true,
            noteMoyenne: item.noteMoyenne,
            nombreAvis: item.nombreAvis,
            photoUrl: item.photoUrl,
            motifCorrespondance: item.motifCorrespondance,
            produitsDisponibles: item.produitsDisponibles,
          );
        }).toList();
      } else {
        // Filtrage local de repli si le résultat global est vide
        final all = await service.fetchPharmacopeesGeo();
        final q = searchQuery.toLowerCase();
        list = all.where((p) {
          final matchesNom = p.nom.toLowerCase().contains(q);
          final matchesDesc = p.description?.toLowerCase().contains(q) ?? false;
          final matchesAddr = p.adresseComplete.toLowerCase().contains(q);
          return matchesNom || matchesDesc || matchesAddr;
        }).toList();
      }
    } else {
      list = await service.fetchPharmacopeesGeo();
    }

    // Application des filtres professionnels
    return list.where((p) {
      if (filter.showOnlyWithDelivery && !p.proposeLivraison) return false;
      if (filter.showOnlyPickup && !p.proposePickup) return false;
      if (filter.showOnlyTopRated && p.noteMoyenne < 4.5) return false;
      if (filter.selectedRegion != null && p.region != filter.selectedRegion) {
        return false;
      }
      return true;
    }).toList();
  } catch (_) {
    return [];
  }
});
